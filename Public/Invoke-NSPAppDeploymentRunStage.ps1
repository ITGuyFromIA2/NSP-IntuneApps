function Invoke-NSPAppDeploymentRunStage {
    <#
    .SYNOPSIS
        Advances a local deployment run journal by exactly one stage.
    .DESCRIPTION
        Plan-only is the default: it reports which app/stage would run and what it would do,
        without touching the journal. Use -Execute and approve ShouldProcess to actually run
        the stage, wrapped in Set-NSPAppDeploymentRunStage Running/Succeeded/Failed transitions
        so failures persist at the failed stage for retry. The Create stage list is
        ValidatePlan, Build, Sign, Package, CreateApp, RecordManagementNotes: Package is not
        adjacent to Build (Sign sits between them), so it is not folded into Build's own
        transition; instead it is its own stage here that does no new work, since the package
        was already produced during Build and nothing since has changed it. RecordManagementNotes
        is the same kind of no-op after CreateApp, which patches the management-notes marker as
        part of the same tenant write that creates the app. For UpdateContentInPlace the fold
        runs the other way: UploadContent does the real content-version write
        (Update-IntuneWin32AppPackageFile handles upload+commit as one call), so CommitContent
        is the no-op stage, and RecordManagementNotes does real work (Set-NSPAppManagementNotes)
        since no earlier stage in that path already touched the object's Notes field. Stages
        belonging to UpdateMetadataInPlace or CreateSupersedingApp are not yet implemented and
        fail clearly rather than being guessed at. This never advances more than one app's
        worth of work unattended.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$RunPath,
        [switch]$Execute
    )

    $unimplementedStages = @('PatchMetadata', 'AddSupersedence')

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

    if ($stageName -in $unimplementedStages) {
        Set-NSPAppDeploymentRunStage -RunPath $resolvedRunPath -AppName $appName -Stage $stageName -Status Running -Confirm:$false | Out-Null
        return Set-NSPAppDeploymentRunStage -RunPath $resolvedRunPath -AppName $appName -Stage $stageName -Status Failed -Message "$stageName is not yet implemented in this executor." -Confirm:$false
    }

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
            'RecordManagementNotes' {
                if ([string]$planEntry.PlannedAction -eq 'Create') {
                    'Management notes were already recorded as part of the CreateApp stage; no further work is needed.'
                } else {
                    if (-not $planEntry.IntuneObjectId) { throw "Plan entry for '$appName' has no recorded IntuneObjectId; re-plan against a bound tenant inventory." }
                    $result = Set-NSPAppManagementNotes -RepoRoot $repoRoot -AppName $appName -IntuneObjectId ([string]$planEntry.IntuneObjectId) -Execute -Confirm:$false
                    if ($result.Status -ne 'Recorded') { throw "Set-NSPAppManagementNotes did not report a Recorded status for '$appName' (got '$($result.Status)')." }
                    "Recorded management notes on Intune app $($result.IntuneObjectId)."
                }
            }
            default { throw "Stage '$stageName' is not recognized by this executor." }
        }
    } catch {
        Set-NSPAppDeploymentRunStage -RunPath $resolvedRunPath -AppName $appName -Stage $stageName -Status Failed -Message $_.Exception.Message -Confirm:$false | Out-Null
        throw
    }

    Set-NSPAppDeploymentRunStage -RunPath $resolvedRunPath -AppName $appName -Stage $stageName -Status Succeeded -Message $stageMessage -Confirm:$false
}
