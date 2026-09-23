function Invoke-NSPAppDeploymentRunStage {
    <#
    .SYNOPSIS
        Advances a local deployment run journal by exactly one stage.
    .DESCRIPTION
        Plan-only is the default: it reports which app/stage would run and what it would do,
        without touching the journal. Use -Execute and approve ShouldProcess to actually run
        the stage, wrapped in Set-NSPAppDeploymentRunStage Running/Succeeded/Failed transitions
        so failures persist at the failed stage for retry. The Create stage list is
        ValidatePlan, Build, Sign, Package, CreateApp, RecordManagementNotes, AssignDefaultGroups:
        Package is not adjacent to Build (Sign sits between them), so it is not folded into
        Build's own transition; instead it is its own stage here that does no new work, since the
        package was already produced during Build and nothing since has changed it.
        RecordManagementNotes is the same kind of no-op after CreateApp, which patches the
        management-notes marker as part of the same tenant write that creates the app.
        AssignDefaultGroups runs last and applies either the app's own saved
        Get-NSPAppAssignmentOverride (HasOverride distinguishes an explicit empty list - "assign
        nothing" - from "nothing recorded, fall back to tenant defaults") or, when no override is
        recorded, the tenant's saved Get-NSPTenantAssignmentDefaults - it is a no-op when neither
        is configured. Both live in Config/Local, never in the app's own settings file:
        Test-NSPIntuneAppsPreflight already blocks literal group targeting embedded there (the
        retired AssignmentColl pattern), since that is exactly how a client's real group name
        would end up committed to a shared repo. It needs the app's IntuneObjectId, which the
        CreateApp stage backfills onto the run entry via Set-NSPAppDeploymentRunStage's
        -IntuneObjectId, since the plan (built before the app existed) has none recorded for a
        fresh Create. For
        UpdateContentInPlace the fold runs the other way: UploadContent does the real
        content-version write (Update-IntuneWin32AppPackageFile handles upload+commit as one
        call), so CommitContent is the no-op stage, and RecordManagementNotes does real work
        (Set-NSPAppManagementNotes) since no earlier stage in that path already touched the
        object's Notes field - content updates never re-run assignment, since Intune keeps a
        Win32 app's existing assignments across a content-only update. UpdateMetadataInPlace's
        PatchMetadata stage (Update-NSPIntuneWin32AppMetadata) PATCHes only the narrow display-
        metadata surface IntuneWin32App's Set-IntuneWin32App exposes (DisplayName, Description,
        Publisher, the Company Portal featured flag) - it does not update install experience,
        restart behavior, detection rules, or requirement rules, since this repo's action
        classifier cannot yet distinguish those build-time fields changing from true display text
        changing (both hash as UpdateMetadataInPlace). CreateSupersedingApp's AddSupersedence
        stage (Add-NSPIntuneWin32AppSupersedence) relates the just-created app (IntuneObjectId
        backfilled from CreateApp, same mechanism as AssignDefaultGroups) to the existing app it
        supersedes (planEntry.IntuneObjectId, which for this one PlannedAction means "the app
        being superseded", not "this app's own object" - it is never overwritten, since only the
        run entry's IntuneObjectId gets backfilled by CreateApp). SupersedenceType (Update/Replace)
        is an explicit operator choice recorded on the plan entry by
        Set-NSPAppDeploymentDecisions at approval time, not guessed here; it defaults to 'Update'
        only for plans approved before this field existed. RecordManagementNotes is a no-op for
        CreateSupersedingApp same as Create, since CreateApp already wrote its notes - patching
        planEntry.IntuneObjectId here would incorrectly touch the superseded app's Notes instead.
        This never advances more than one app's worth of work unattended.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$RunPath,
        [switch]$Execute
    )

    $resolvedRunPath = (Resolve-Path -LiteralPath $RunPath -ErrorAction Stop).Path
    $run = Get-Content -LiteralPath $resolvedRunPath -Raw | ConvertFrom-Json
    if ($run.RunType -ne 'Win32AppDeployment') { throw "Unsupported run type '$($run.RunType)'." }

    $currentEntry = @($run.Entries | Where-Object Status -notin @('Completed', 'Skipped') | Sort-Object Order | Select-Object -First 1)
    if ($currentEntry.Count -eq 0) { return Get-NSPAppDeploymentRunSummary -RunPath $resolvedRunPath }
    $entry = $currentEntry[0]
    $currentStage = @($entry.Stages | Where-Object Status -ne 'Succeeded' | Select-Object -First 1)
    if ($currentStage.Count -eq 0) { return Get-NSPAppDeploymentRunSummary -RunPath $resolvedRunPath }
    $stageName = $currentStage[0].Name
    $appName = $entry.Name

    if (-not $Execute) {
        return [pscustomobject]@{
            Status        = 'PlanOnly'
            App           = $appName
            Stage         = $stageName
            PlannedAction = [string]$entry.PlannedAction
            Message       = "Run again with -Execute to run stage '$stageName' for '$appName'."
        }
    }
    if (-not $PSCmdlet.ShouldProcess("$appName / $stageName", 'Advance the deployment run')) { return }

    $plan = Get-Content -LiteralPath $run.PlanPath -Raw | ConvertFrom-Json
    $planEntry = $plan.Entries | Where-Object Name -eq $appName | Select-Object -First 1
    $repoRoot = [string]$plan.RepoRoot

    $resolvePackagePath = {
        $catalogEntry = Get-NSPIntuneAppCatalog -RepoRoot $repoRoot | Where-Object Name -eq $appName
        if (-not $catalogEntry) { throw "App was not found in the catalog: $appName" }
        $VariableConfig = $null
        . $catalogEntry.SettingsPath
        $buildPlan = Resolve-NSPAppBuildPlan -Name $appName -SettingsPath $catalogEntry.SettingsPath -Path $catalogEntry.Path -VariableConfig $VariableConfig
        $packageFileName = [IO.Path]::GetFileNameWithoutExtension($buildPlan.SetupFileName) + '.intunewin'
        $packagePath = Join-Path (Join-Path $repoRoot "Config\Local\Build\$appName") $packageFileName
        if (-not (Test-Path -LiteralPath $packagePath)) { throw "Built package not found at $packagePath. Run the Build stage first." }
        $packagePath
    }
    $resolveRegistration = {
        $registrationPath = Join-Path $repoRoot 'Config\Local\GraphAppRegistration.json'
        if (-not (Test-Path -LiteralPath $registrationPath)) { throw "No tenant app registration is recorded at $registrationPath. Run Register-NSPIntuneWin32AppRegistration -Execute first." }
        $registration = Get-Content -LiteralPath $registrationPath -Raw | ConvertFrom-Json
        if ([string]$registration.TenantId -ne [string]$run.TenantId) { throw "Recorded app registration is for tenant $($registration.TenantId), but this run targets $($run.TenantId)." }
        $registration
    }
    $resolveAssignmentSpecs = {
        $override = Get-NSPAppAssignmentOverride -RepoRoot $repoRoot -TenantId ([string]$run.TenantId) -AppName $appName
        if ($override.HasOverride) {
            @($override.AssignmentOverride)
        } else {
            $defaults = Get-NSPTenantAssignmentDefaults -RepoRoot $repoRoot -TenantId ([string]$run.TenantId)
            @($defaults.DefaultAssignments)
        }
    }

    $stageIntuneObjectId = $null
    Set-NSPAppDeploymentRunStage -RunPath $resolvedRunPath -AppName $appName -Stage $stageName -Status Running -Confirm:$false | Out-Null
    try {
        $stageMessage = switch ($stageName) {
            'ValidatePlan' {
                $sourceState = Get-NSPAppSourceState -RepoRoot $repoRoot -AppName $appName
                if ($sourceState.MetadataSha256 -ne [string]$planEntry.MetadataSha256 -or $sourceState.ContentSha256 -ne [string]$planEntry.ContentSha256) {
                    throw "Source content for '$appName' has changed since planning. Re-plan before continuing."
                }
                'Source hashes match the approved plan.'
            }
            'Build' {
                $result = New-NSPAppPackage -RepoRoot $repoRoot -AppName $appName -Confirm:$false
                "Package built at $($result.PackagePath)."
            }
            'Sign' {
                $result = Set-NSPAppSignature -RepoRoot $repoRoot -AppName $appName -Confirm:$false
                "$($result.SignedFiles.Count) file(s) signed with $($result.Thumbprint)."
            }
            'Package' {
                'Packaging already completed during the Build stage; no further work is needed.'
            }
            'CreateApp' {
                $packagePath = & $resolvePackagePath
                $registration = & $resolveRegistration
                $result = New-NSPIntuneWin32App -RepoRoot $repoRoot -AppName $appName -PackagePath $packagePath -TenantId ([string]$run.TenantId) -ClientId ([string]$registration.ClientId) -Execute -Confirm:$false
                if ($result.Status -ne 'Created') { throw "New-NSPIntuneWin32App did not report a Created status for '$appName' (got '$($result.Status)')." }
                $stageIntuneObjectId = [string]$result.IntuneAppId
                "Created Intune app $($result.IntuneAppId)."
            }
            'UploadContent' {
                if (-not $planEntry.IntuneObjectId) { throw "Plan entry for '$appName' has no recorded IntuneObjectId; re-plan against a bound tenant inventory." }
                $packagePath = & $resolvePackagePath
                $registration = & $resolveRegistration
                $result = Update-NSPIntuneWin32AppContent -AppName $appName -PackagePath $packagePath -IntuneObjectId ([string]$planEntry.IntuneObjectId) -TenantId ([string]$run.TenantId) -ClientId ([string]$registration.ClientId) -Execute -Confirm:$false
                if ($result.Status -ne 'Updated') { throw "Update-NSPIntuneWin32AppContent did not report an Updated status for '$appName' (got '$($result.Status)')." }
                "Uploaded a new content version for Intune app $($result.IntuneObjectId)."
            }
            'CommitContent' {
                'Content commit already completed as part of the UploadContent stage; no further work is needed.'
            }
            'PatchMetadata' {
                if (-not $planEntry.IntuneObjectId) { throw "Plan entry for '$appName' has no recorded IntuneObjectId; re-plan against a bound tenant inventory." }
                $registration = & $resolveRegistration
                $result = Update-NSPIntuneWin32AppMetadata -RepoRoot $repoRoot -AppName $appName -IntuneObjectId ([string]$planEntry.IntuneObjectId) -TenantId ([string]$run.TenantId) -ClientId ([string]$registration.ClientId) -Execute -Confirm:$false
                if ($result.Status -ne 'Updated') { throw "Update-NSPIntuneWin32AppMetadata did not report an Updated status for '$appName' (got '$($result.Status)')." }
                "Patched display metadata for Intune app $($result.IntuneObjectId)."
            }
            'AddSupersedence' {
                if (-not $entry.IntuneObjectId) { throw "No IntuneObjectId is recorded for '$appName'; the CreateApp stage must succeed first." }
                if (-not $planEntry.IntuneObjectId) { throw "Plan entry for '$appName' has no recorded IntuneObjectId for the app being superseded; re-plan against a bound tenant inventory." }
                $registration = & $resolveRegistration
                $supersedenceType = if ([string]$entry.SupersedenceType) { [string]$entry.SupersedenceType } else { 'Update' }
                $result = Add-NSPIntuneWin32AppSupersedence -NewIntuneObjectId ([string]$entry.IntuneObjectId) -NewAppDisplayName $appName -SupersededIntuneObjectId ([string]$planEntry.IntuneObjectId) -SupersedenceType $supersedenceType -TenantId ([string]$run.TenantId) -ClientId ([string]$registration.ClientId) -Execute -Confirm:$false
                if ($result.Status -ne 'Related') { throw "Add-NSPIntuneWin32AppSupersedence did not report a Related status for '$appName' (got '$($result.Status)')." }
                "Related new Intune app $($result.NewIntuneObjectId) to superseded app $($result.SupersededIntuneObjectId) ($supersedenceType)."
            }
            'RecordManagementNotes' {
                if ([string]$planEntry.PlannedAction -in @('Create', 'CreateSupersedingApp')) {
                    'Management notes were already recorded as part of the CreateApp stage; no further work is needed.'
                } else {
                    if (-not $planEntry.IntuneObjectId) { throw "Plan entry for '$appName' has no recorded IntuneObjectId; re-plan against a bound tenant inventory." }
                    $result = Set-NSPAppManagementNotes -RepoRoot $repoRoot -AppName $appName -IntuneObjectId ([string]$planEntry.IntuneObjectId) -Execute -Confirm:$false
                    if ($result.Status -ne 'Recorded') { throw "Set-NSPAppManagementNotes did not report a Recorded status for '$appName' (got '$($result.Status)')." }
                    "Recorded management notes on Intune app $($result.IntuneObjectId)."
                }
            }
            'AssignDefaultGroups' {
                if (-not $entry.IntuneObjectId) { throw "No IntuneObjectId is recorded for '$appName'; the CreateApp stage must succeed first." }
                $registration = & $resolveRegistration
                $assignmentSpecs = @(& $resolveAssignmentSpecs)
                if ($assignmentSpecs.Count -eq 0) {
                    'No tenant default or per-app override assignments are configured; nothing was assigned.'
                } else {
                    $targetSummaries = foreach ($spec in $assignmentSpecs) {
                        $assignArgs = @{
                            IntuneObjectId = [string]$entry.IntuneObjectId
                            AppDisplayName = $appName
                            TargetType     = if ($spec.TargetType) { [string]$spec.TargetType } else { 'Group' }
                            Mode           = [string]$spec.Mode
                            Intent         = [string]$spec.Intent
                            TenantId       = [string]$run.TenantId
                            ClientId       = [string]$registration.ClientId
                        }
                        if ($spec.GroupId) { $assignArgs.GroupId = [string]$spec.GroupId }
                        if ($spec.GroupDisplayName) { $assignArgs.GroupDisplayName = [string]$spec.GroupDisplayName }
                        if ($spec.FilterDisplayName) {
                            $assignArgs.FilterDisplayName = [string]$spec.FilterDisplayName
                            $assignArgs.FilterMode = [string]$spec.FilterMode
                        }
                        $result = New-NSPIntuneWin32AppAssignment @assignArgs -Execute -Confirm:$false
                        if ($result.Status -ne 'Assigned') { throw "New-NSPIntuneWin32AppAssignment did not report an Assigned status for '$appName' (got '$($result.Status)')." }
                        $targetLabel = if ($assignArgs.GroupDisplayName) { $assignArgs.GroupDisplayName } elseif ($assignArgs.GroupId) { $assignArgs.GroupId } else { $assignArgs.TargetType }
                        "$targetLabel ($($assignArgs.Intent))"
                    }
                    "Assigned '$appName' to $(@($targetSummaries).Count) target(s): $($targetSummaries -join ', ')."
                }
            }
            default { throw "Stage '$stageName' is not recognized by this executor." }
        }
    } catch {
        Set-NSPAppDeploymentRunStage -RunPath $resolvedRunPath -AppName $appName -Stage $stageName -Status Failed -Message $_.Exception.Message -Confirm:$false | Out-Null
        throw
    }

    Set-NSPAppDeploymentRunStage -RunPath $resolvedRunPath -AppName $appName -Stage $stageName -Status Succeeded -Message $stageMessage -IntuneObjectId $stageIntuneObjectId -Confirm:$false
}
