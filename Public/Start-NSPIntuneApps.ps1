function Start-NSPIntuneApps {
    <#
    .SYNOPSIS
        Opens the guided NSP IntuneApps operator dashboard.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot
    )

    do {
        $preflight = Test-NSPIntuneAppsPreflight -RepoRoot $RepoRoot
        $catalog = @($preflight.Catalog)
        $savedPlans = @(Get-NSPAppDeploymentPlanSummary -RepoRoot $RepoRoot)
        $runRoot = Join-Path $RepoRoot '.nsp-intuneapps\runs'
        $savedRuns = if (Test-Path -LiteralPath $runRoot) {
            @(Get-ChildItem -LiteralPath $runRoot -Filter '*.json' -File | Sort-Object LastWriteTimeUtc -Descending | ForEach-Object { Get-NSPAppDeploymentRunSummary -RunPath $_.FullName })
        } else { @() }
        $planStatus = if ($savedPlans.Count -eq 0) {
            'Trackers: none saved'
        } else {
            $latestPlan = $savedPlans[0]
            "Trackers: $($savedPlans.Count) saved | latest: $($latestPlan.Approved) approved, $($latestPlan.Skipped) skipped, $($latestPlan.Pending) pending, $($latestPlan.AttentionRequired) attention"
        }
        Write-NSPDashboardHeader -Title 'NSP IntuneApps' -StatusLines @(
            "Preflight: $(if ($preflight.Passed) { 'READY' } else { 'ATTENTION REQUIRED' })"
            "Catalog: $(@($catalog | Where-Object Classification -eq 'Deployable').Count) deployable | $(@($catalog | Where-Object Classification -eq 'RequiresConfiguration').Count) needs setup | $(@($catalog | Where-Object Classification -eq 'RequiresRepair').Count) needs repair | $(@($catalog | Where-Object Classification -eq 'Legacy').Count) legacy | $(@($catalog | Where-Object Classification -like 'Retired*').Count) retired | $(@($catalog | Where-Object Classification -eq 'Blocked').Count) blocked"
            'Safety: discovery and plans are read-only; execution is always explicit'
            $planStatus
            "Runs: $($savedRuns.Count) saved | $(@($savedRuns | Where-Object Status -eq 'AttentionRequired').Count) need attention"
        )
        Write-Host '--- Discover & build ---' -ForegroundColor DarkCyan
        Write-Host '  [1] Preflight details'
        Write-Host '  [2] App catalog'
        Write-Host '  [3] Create from a guided template'
        Write-Host '--- Code signing ---' -ForegroundColor DarkCyan
        Write-Host '  [4] Code-signing certificate status'
        Write-Host '  [5] Plan certificate trust upload'
        Write-Host '--- Deployment planning ---' -ForegroundColor DarkCyan
        Write-Host '  [6] Create/review an app deployment tracker'
        Write-Host '  [7] Save a read-only Intune app inventory'
        Write-Host '  [8] Resume a saved deployment tracker'
        Write-Host '--- Deployment execution ---' -ForegroundColor DarkCyan
        Write-Host '  [9] View resumable deployment run journals'
        Write-Host '  [10] Advance the next stage of a saved run'
        Write-Host '--- Tenant administration ---' -ForegroundColor DarkCyan
        Write-Host '  [11] Register/verify the tenant app registration (one-time bootstrap)'
        Write-Host '  [12] Delete an existing Intune app (irreversible)' -ForegroundColor Red
        Write-Host '  [13] Save a read-only app assignment and filter inventory'
        Write-Host '  [14] Assign an app to a group, optionally scoped by a filter'
        Write-Host '  [15] Build and create an assignment filter'
        Write-Host '  [16] Manage master assignment groups (tenant defaults + per-app overrides)'
        Write-Host '  [17] Review and retire superseded apps (separate, explicitly approved)' -ForegroundColor Red
        Write-Host ''
        Write-Host '  [Q] Quit'
        $choice = Read-NSPMenuChoice -Prompt 'Choose an action' -Allowed @('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','Q')

        switch ($choice) {
            '1' {
                $preflight.Results | Format-Table Area, Name, Status, Detail -AutoSize
                if ($preflight.SyntaxErrors) { $preflight.SyntaxErrors | Format-Table File, Line, Message -Wrap }
            }
            '2' { $catalog | Format-Table Name, Classification, ScriptCount, PackageCount, Reason -AutoSize -Wrap }
            '3' {
                Invoke-NSPGuidedTemplateWizardMenu -RepoRoot $RepoRoot | Out-Null
            }
            '4' {
                $config = Get-NSPCodeSigningConfiguration -RepoRoot $RepoRoot
                if ([string]::IsNullOrWhiteSpace([string]$config.Current.Thumbprint)) { Write-Warning 'No active certificate generation is configured.' }
                else { $config.Current | Format-List }
                Write-Host 'Certificate creation is deliberately a separate elevated command: New-NSPCodeSigningCertificate -RepoRoot <path> -Activate'
            }
            '5' {
                Write-Host '[A] All devices (default)'
                Write-Host '[G] One selected group'
                Write-Host '[N] Create without assignment'
                $targetChoice = Read-NSPMenuChoice -Prompt 'Assignment target' -Allowed @('A','G','N') -Default 'A'
                $target = @{ A='AllDevices'; G='Group'; N='None' }[$targetChoice]
                $groupId = if ($target -eq 'Group') { Read-Host 'Enter the Microsoft Entra group object ID' } else { $null }
                $plan = Get-NSPCodeSigningTrustPlan -RepoRoot $RepoRoot -AssignmentTarget $target -GroupId $groupId -Connect
                Write-NSPDenseFieldSummary -InputObject ($plan | Select-Object ProfileName, Action, Thumbprint, CertificateExpires, AssignmentTarget, AssignmentDisplayName, TenantId, Account, MissingUris, Conflicts, CanExecute)
                if (@($plan.Conflicts).Count -gt 0) {
                    Write-Warning 'Conflicts were found. Resolve them before this plan can execute.'
                } elseif (-not $plan.CanExecute) {
                    Write-Warning 'This plan is not executable yet (check tenant authentication above).'
                } elseif ($plan.Action -eq 'NoChange') {
                    Write-Host 'The expected generation is already present in this profile. Nothing to publish.' -ForegroundColor Green
                } else {
                    $executeChoice = Read-NSPMenuChoice -Prompt "$($plan.Action) '$($plan.ProfileName)' for tenant $($plan.TenantId) now? [Y/N]" -Allowed @('Y','N') -Default 'N'
                    if ($executeChoice -eq 'Y') {
                        $result = Publish-NSPCodeSigningTrust -RepoRoot $RepoRoot -AssignmentTarget $target -GroupId $groupId -Execute -Confirm:$false
                        $result | Select-Object ProfileName, Action, Thumbprint, TenantId, AssignmentTarget | Format-List
                        Write-Host 'Trust profile published.' -ForegroundColor Green
                    } else {
                        Write-Host 'No changes were made.' -ForegroundColor Yellow
                    }
                }
            }
            '6' {
                $deployableCatalog = @($catalog | Where-Object Classification -eq 'Deployable' | Sort-Object Name)
                $selectedNames = [Collections.Generic.List[string]]::new()
                $done = $false
                do {
                    Write-NSPDashboardHeader -Title 'Build an app deployment tracker' -StatusLines @(
                        "Selected: $($selectedNames.Count) of $($deployableCatalog.Count) deployable app(s)"
                    )
                    if ($deployableCatalog.Count -eq 0) {
                        Write-Host 'No deployable catalog entries were found yet.' -ForegroundColor Yellow
                    } else {
                        $markers = @($deployableCatalog | ForEach-Object { if ($selectedNames.Contains($_.Name)) { '[x]' } else { '[ ]' } })
                        Write-NSPDenseNumberedList -Items @($deployableCatalog.Name) -Markers $markers
                    }
                    Write-Host ''
                    Write-Host 'Pick a number to toggle it on/off, one at a time.' -ForegroundColor DarkGray
                    Write-Host '  [A] Select all remaining'
                    Write-Host '  [W] Create a new app from the guided template wizard, then add it here'
                    Write-Host '  [D] Done selecting'
                    $pickAllowed = @(@(if ($deployableCatalog.Count -gt 0) { 1..$deployableCatalog.Count | ForEach-Object { [string]$_ } }) + @('A', 'W', 'D'))
                    $pick = Read-NSPMenuChoice -Prompt 'Toggle a number, or choose an action' -Allowed $pickAllowed -Default 'D'
                    switch ($pick) {
                        'D' { $done = $true }
                        'A' {
                            foreach ($item in $deployableCatalog) { if (-not $selectedNames.Contains($item.Name)) { $selectedNames.Add($item.Name) } }
                        }
                        'W' {
                            $newApp = Invoke-NSPGuidedTemplateWizardMenu -RepoRoot $RepoRoot
                            if ($newApp -and $newApp.Path) {
                                $newName = Split-Path -Path $newApp.Path -Leaf
                                $catalog = @((Test-NSPIntuneAppsPreflight -RepoRoot $RepoRoot).Catalog)
                                $deployableCatalog = @($catalog | Where-Object Classification -eq 'Deployable' | Sort-Object Name)
                                if (-not $selectedNames.Contains($newName)) { $selectedNames.Add($newName) }
                                if (@($deployableCatalog.Name) -notcontains $newName) {
                                    Write-Warning "'$newName' was created but is not classified Deployable yet (check code signing/configuration). It is still included in this selection."
                                    Read-Host 'Press Enter to continue' | Out-Null
                                }
                            }
                        }
                        default {
                            $targetName = $deployableCatalog[[int]$pick - 1].Name
                            if ($selectedNames.Contains($targetName)) { $selectedNames.Remove($targetName) | Out-Null } else { $selectedNames.Add($targetName) }
                        }
                    }
                } while (-not $done)

                if ($selectedNames.Count -eq 0) {
                    Write-Warning 'No apps were selected. No tracker was created.'
                } else {
                    Write-Host "Batch: $($selectedNames -join ', ')" -ForegroundColor Cyan
                    $planFile = New-NSPAppDeploymentPlan -RepoRoot $RepoRoot -AppName @($selectedNames)
                    Write-Host "Tracker saved to $($planFile.FullName)" -ForegroundColor Green
                    Write-Host 'Collect and bind a read-only tenant inventory before approving any app action.' -ForegroundColor Yellow
                }
            }
            '7' {
                Write-Host 'A delegated browser login may open. Requested permission: DeviceManagementApps.Read.All (read-only).' -ForegroundColor Yellow
                $inventory = Get-NSPIntuneAppInventory -RepoRoot $RepoRoot -Connect
                Write-NSPDenseFieldSummary -InputObject ($inventory | Select-Object TenantId, Account, AppCount, ManagedCount, OutputPath)
                $bindablePlans = @(Get-NSPAppDeploymentPlanSummary -RepoRoot $RepoRoot | Select-Object -First 9)
                if ($bindablePlans.Count -gt 0) {
                    Write-Host 'Bind this inventory to a tracker now? No tenant data will be changed.' -ForegroundColor Cyan
                    for ($index = 0; $index -lt $bindablePlans.Count; $index++) {
                        $planItem = $bindablePlans[$index]
                        Write-Host ("[{0}] {1} | modified {2} | {3}" -f ($index + 1), $planItem.FileName, $planItem.LastModifiedAt, (Format-NSPAppList -Names $planItem.AppNames))
                    }
                    Write-Host '[N] Save inventory only'
                    $allowedPlans = @(@(1..$bindablePlans.Count | ForEach-Object { [string]$_ }) + 'N')
                    $planChoice = Read-NSPMenuChoice -Prompt 'Tracker' -Allowed $allowedPlans -Default 'N'
                    if ($planChoice -ne 'N') {
                        $selectedPlan = $bindablePlans[[int]$planChoice - 1]
                        Update-NSPAppDeploymentPlan -PlanPath $selectedPlan.PlanPath -InventoryPath $inventory.OutputPath | Format-List PlanPath, Executable, ReviewRequired
                        $review = Get-NSPAppDeploymentPlanReview -PlanPath $selectedPlan.PlanPath
                        Write-NSPDenseFieldSummary -InputObject ($review | Select-Object TenantId, Account, SafetyMode, Targeting, CanReviewDecisions, ExecutorStatus, Blockers, Warnings)
                        $review.Entries | Format-Table Order, Name, PlannedAction, Decision, CanApprove, Effect -Wrap
                    }
                }
                Write-Host 'The inventory and any tracker resolution were read-only with respect to Intune.' -ForegroundColor DarkGray
            }
            '8' {
                $recentPlans = @($savedPlans | Select-Object -First 9)
                if ($recentPlans.Count -eq 0) {
                    Write-Warning 'No saved deployment trackers were found.'
                } else {
                    for ($index = 0; $index -lt $recentPlans.Count; $index++) {
                        $item = $recentPlans[$index]
                        Write-Host ("[{0}] {1} | modified {2} | approved {3}, skipped {4}, pending {5}, attention {6} | {7}" -f ($index + 1), $item.FileName, $item.LastModifiedAt, $item.Approved, $item.Skipped, $item.Pending, $item.AttentionRequired, (Format-NSPAppList -Names $item.AppNames))
                    }
                    $allowedPlans = @(1..$recentPlans.Count | ForEach-Object { [string]$_ })
                    $planChoice = Read-NSPMenuChoice -Prompt 'Tracker to resume' -Allowed $allowedPlans -Default '1'
                    $selectedPlan = $recentPlans[[int]$planChoice - 1]
                    $review = Get-NSPAppDeploymentPlanReview -PlanPath $selectedPlan.PlanPath
                    Write-NSPDenseFieldSummary -InputObject ($review | Select-Object TenantId, Account, SafetyMode, Targeting, CanReviewDecisions, ExecutorStatus, Blockers, Warnings)
                    $review.Entries | Format-Table Order, Name, PlannedAction, Decision, CanApprove, Effect -Wrap
                    if ($review.CanReviewDecisions) {
                        $reviewDecisions = Read-NSPMenuChoice -Prompt 'Review pending app decisions one at a time? [Y/N]' -Allowed @('Y','N') -Default 'Y'
                        if ($reviewDecisions -eq 'Y') {
                            $decisionResult = Set-NSPAppDeploymentDecisions -PlanPath $selectedPlan.PlanPath
                            $decisionResult | Format-List PlanPath, Approved, Skipped, Pending
                            if ($decisionResult.Pending -eq 0 -and $decisionResult.Approved -gt 0) {
                                $createRun = Read-NSPMenuChoice -Prompt 'Create a local resumable run journal? [Y/N]' -Allowed @('Y','N') -Default 'Y'
                                if ($createRun -eq 'Y') {
                                    $runFile = New-NSPAppDeploymentRun -PlanPath $selectedPlan.PlanPath
                                    Get-NSPAppDeploymentRunSummary -RunPath $runFile.FullName | Format-List
                                    Write-Host 'The journal queues stages only. It did not build a package or change Intune.' -ForegroundColor Yellow
                                }
                            }
                        }
                    } else {
                        Write-Warning 'Resolve every displayed blocker before app approval.'
                    }
                }
            }
            '9' {
                if ($savedRuns.Count -eq 0) {
                    Write-Warning 'No deployment run journals were found.'
                } else {
                    $savedRuns | Select-Object Status, CurrentApp, CurrentStage, CurrentStageState, Completed, Total, Failed, LastUpdatedAtUtc, RunPath | Format-Table -Wrap
                    Write-Host 'Use [10] to advance a run one stage at a time, or auto-advance every remaining stage for testing. UpdateMetadataInPlace and CreateSupersedingApp stages are not yet implemented.' -ForegroundColor Yellow
                }
            }
            '10' {
                if ($savedRuns.Count -eq 0) {
                    Write-Warning 'No deployment run journals were found.'
                } else {
                    $recentRuns = @($savedRuns | Select-Object -First 9)
                    for ($index = 0; $index -lt $recentRuns.Count; $index++) {
                        $item = $recentRuns[$index]
                        Write-Host ("[{0}] {1} | updated {2} | {3} / {4} ({5}) | {6} | {7}" -f ($index + 1), (Split-Path -Path $item.RunPath -Leaf), $item.LastUpdatedAtUtc, $item.CurrentApp, $item.CurrentStage, $item.CurrentStageState, $item.Status, (Format-NSPAppList -Names $item.AppNames))
                    }
                    $allowedRuns = @(1..$recentRuns.Count | ForEach-Object { [string]$_ })
                    $runChoice = Read-NSPMenuChoice -Prompt 'Run journal to advance' -Allowed $allowedRuns -Default '1'
                    $selectedRun = $recentRuns[[int]$runChoice - 1]
                    $preview = Invoke-NSPAppDeploymentRunStage -RunPath $selectedRun.RunPath
                    if ($preview.Status -ne 'PlanOnly') {
                        $preview | Format-List
                        Write-Warning 'This run has no pending stage to advance.'
                    } else {
                        Write-Host "Next: $($preview.Stage) for $($preview.App) (planned action: $($preview.PlannedAction))" -ForegroundColor Cyan
                        Write-Host $preview.Message
                        Write-Host '[Y] Execute this stage only'
                        Write-Host '[A] Auto-advance every remaining stage for this run without stopping to confirm each one' -ForegroundColor Yellow
                        Write-Host '[N] Cancel'
                        $executeChoice = Read-NSPMenuChoice -Prompt 'Choice' -Allowed @('Y','A','N') -Default 'N'
                        if ($executeChoice -eq 'Y') {
                            $result = Invoke-NSPAppDeploymentRunStage -RunPath $selectedRun.RunPath -Execute -Confirm:$false
                            $result | Format-List
                        } elseif ($executeChoice -eq 'A') {
                            Write-Warning 'Auto-advancing without a per-stage confirm. This still performs real tenant writes - use only against a test tenant. Press Ctrl+C to stop early.'
                            $result = $null
                            try {
                                do {
                                    $result = Invoke-NSPAppDeploymentRunStage -RunPath $selectedRun.RunPath -Execute -Confirm:$false
                                    Write-Host ("{0} / {1} ({2}) -> {3}" -f $result.CurrentApp, $result.CurrentStage, $result.CurrentStageState, $result.Status)
                                } while ($result.CurrentApp -and $result.Status -in @('Ready', 'Running'))
                            } catch {
                                Write-Warning "Auto-advance stopped: $($_.Exception.Message)"
                            }
                            if ($result) { $result | Format-List }
                        } else {
                            Write-Host 'No changes were made.' -ForegroundColor Yellow
                        }
                    }
                }
            }
            '11' {
                Write-Host 'A delegated browser login may open. Requested permissions: Application.ReadWrite.All, Directory.ReadWrite.All, DelegatedPermissionGrant.ReadWrite.All.' -ForegroundColor Yellow
                Write-Host 'This is a one-time, tenant-wide bootstrap and requires a Global/Privileged Role Administrator account.' -ForegroundColor Yellow
                $preview = Register-NSPIntuneWin32AppRegistration -RepoRoot $RepoRoot
                $preview | Format-List
                if ($preview.Status -in @('PlanOnly', 'NeedsRedirectUriRepair', 'NeedsPermissionRepair')) {
                    $actionLabel = switch ($preview.Status) {
                        'NeedsRedirectUriRepair' { 'Repair the broker redirect URI now' }
                        'NeedsPermissionRepair' { 'Grant the missing admin consent now' }
                        default { 'Create the app registration and grant admin consent now' }
                    }
                    $executeChoice = Read-NSPMenuChoice -Prompt "${actionLabel}? [Y/N]" -Allowed @('Y','N') -Default 'N'
                    if ($executeChoice -eq 'Y') {
                        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $RepoRoot -Execute -Confirm:$false
                        $result | Format-List
                    } else {
                        Write-Host 'No changes were made.' -ForegroundColor Yellow
                    }
                }
            }
            '12' {
                $inventoryRoot = Join-Path $RepoRoot '.nsp-intuneapps\inventory'
                $latestInventory = if (Test-Path -LiteralPath $inventoryRoot) { Get-ChildItem -LiteralPath $inventoryRoot -Filter '*.json' -File | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1 } else { $null }
                $registrationPath = Join-Path $RepoRoot 'Config\Local\GraphAppRegistration.json'
                if (-not $latestInventory) {
                    Write-Warning 'No saved Intune app inventory was found. Use [7] to save one first, so an app can be picked by name instead of a raw object ID.'
                } elseif (-not (Test-Path -LiteralPath $registrationPath)) {
                    Write-Warning 'No tenant app registration is recorded. Use [11] first.'
                } else {
                    $inventoryDocument = Get-Content -LiteralPath $latestInventory.FullName -Raw | ConvertFrom-Json
                    $apps = @($inventoryDocument.Apps)
                    if ($apps.Count -eq 0) {
                        Write-Warning "The most recent saved inventory ($($latestInventory.Name)) has no apps."
                    } else {
                        Write-Host "From inventory: $($latestInventory.Name) (tenant $($inventoryDocument.TenantId))" -ForegroundColor Cyan
                        for ($index = 0; $index -lt $apps.Count; $index++) {
                            Write-Host ("  [{0}] {1} | {2}" -f ($index + 1), $apps[$index].DisplayName, $apps[$index].Id)
                        }
                        $allowedApps = @(1..$apps.Count | ForEach-Object { [string]$_ })
                        $appChoice = Read-NSPMenuChoice -Prompt 'App to delete' -Allowed $allowedApps
                        $targetApp = $apps[[int]$appChoice - 1]
                        $registration = Get-Content -LiteralPath $registrationPath -Raw | ConvertFrom-Json
                        $preview = Remove-NSPIntuneWin32App -IntuneObjectId $targetApp.Id -DisplayName $targetApp.DisplayName -TenantId $inventoryDocument.TenantId -ClientId $registration.ClientId
                        $preview | Format-List
                        Write-Warning 'This permanently deletes the app object from the tenant. It cannot be undone.'
                        $confirmText = Read-Host "Type the app's exact display name to confirm deletion, or press Enter to cancel"
                        if ($confirmText -eq $targetApp.DisplayName) {
                            $result = Remove-NSPIntuneWin32App -IntuneObjectId $targetApp.Id -DisplayName $targetApp.DisplayName -TenantId $inventoryDocument.TenantId -ClientId $registration.ClientId -Execute -Confirm:$false
                            $result | Format-List
                        } else {
                            Write-Host 'No changes were made.' -ForegroundColor Yellow
                        }
                    }
                }
            }
            '13' {
                Write-Host 'A delegated browser login may open. This reads every Win32 app''s current assignments and every assignment filter in the tenant - no tenant data is changed.' -ForegroundColor Yellow
                $inventory = Get-NSPIntuneAppAssignmentInventory -RepoRoot $RepoRoot -Connect
                Write-NSPDenseFieldSummary -InputObject ($inventory | Select-Object TenantId, Account, AppCount, AssignmentCount, FilterCount, OutputPath)
                if (@($inventory.Filters).Count -gt 0) {
                    Write-Host 'Existing assignment filters:' -ForegroundColor Cyan
                    $inventory.Filters | Format-Table DisplayName, Platform, Rule -Wrap
                }
                if (@($inventory.DistinctGroups).Count -gt 0) {
                    Write-Host 'Groups already used for assignment:' -ForegroundColor Cyan
                    $inventory.DistinctGroups | Format-Table GroupDisplayName, GroupId -AutoSize
                }
                Write-Host 'This was read-only.' -ForegroundColor DarkGray
            }
            '14' {
                $registrationPath = Join-Path $RepoRoot 'Config\Local\GraphAppRegistration.json'
                $inventoryRoot = Join-Path $RepoRoot '.nsp-intuneapps\inventory'
                $latestInventory = if (Test-Path -LiteralPath $inventoryRoot) { Get-ChildItem -LiteralPath $inventoryRoot -Filter '*.json' -File | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1 } else { $null }
                if (-not (Test-Path -LiteralPath $registrationPath)) {
                    Write-Warning 'No tenant app registration is recorded. Use [11] first.'
                } elseif (-not $latestInventory) {
                    Write-Warning 'No saved Intune app inventory was found. Use [7] to save one first, so an app can be picked by name.'
                } else {
                    $registration = Get-Content -LiteralPath $registrationPath -Raw | ConvertFrom-Json
                    $inventoryDocument = Get-Content -LiteralPath $latestInventory.FullName -Raw | ConvertFrom-Json
                    $apps = @(Get-Content -LiteralPath $latestInventory.FullName -Raw | ConvertFrom-Json).Apps
                    Write-Host "From inventory: $($latestInventory.Name) (tenant $($inventoryDocument.TenantId))" -ForegroundColor Cyan
                    for ($index = 0; $index -lt $apps.Count; $index++) { Write-Host ("  [{0}] {1} | {2}" -f ($index + 1), $apps[$index].DisplayName, $apps[$index].Id) }
                    $appChoice = Read-NSPMenuChoice -Prompt 'App to assign' -Allowed @(1..$apps.Count | ForEach-Object { [string]$_ })
                    $targetApp = $apps[[int]$appChoice - 1]

                    $assignmentInventoryRoot = Join-Path $RepoRoot '.nsp-intuneapps\assignment-inventory'
                    $latestAssignmentInventory = if (Test-Path -LiteralPath $assignmentInventoryRoot) { Get-ChildItem -LiteralPath $assignmentInventoryRoot -Filter '*.json' -File | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1 } else { $null }
                    $knownGroups = if ($latestAssignmentInventory) { @((Get-Content -LiteralPath $latestAssignmentInventory.FullName -Raw | ConvertFrom-Json).DistinctGroups) } else { @() }

                    $target = Invoke-NSPAssignmentTargetPicker -TenantId $registration.TenantId -ClientId $registration.ClientId -KnownGroups $knownGroups
                    $targetType = $target.TargetType
                    $targetGroup = [pscustomobject]@{ Id = $target.Id; DisplayName = $target.DisplayName }

                    $modeAndIntent = Read-NSPAssignmentModeAndIntent -TargetType $targetType
                    $mode = $modeAndIntent.Mode
                    $intent = $modeAndIntent.Intent

                    $filterDisplayName = $null
                    $filterMode = $null
                    $knownFilters = if ($latestAssignmentInventory) { @((Get-Content -LiteralPath $latestAssignmentInventory.FullName -Raw | ConvertFrom-Json).Filters) } else { @() }
                    if ($mode -eq 'Include' -and @($knownFilters).Count -gt 0) {
                        Write-Host 'Scope by an existing assignment filter? (Build one first with [15] if you need a new one.)' -ForegroundColor Cyan
                        for ($index = 0; $index -lt $knownFilters.Count; $index++) { Write-Host ("  [{0}] {1} ({2})" -f ($index + 1), $knownFilters[$index].DisplayName, $knownFilters[$index].Platform) }
                        Write-Host '  [N] No filter'
                        $filterAllowed = @(@(1..$knownFilters.Count | ForEach-Object { [string]$_ }) + 'N')
                        $filterChoice = Read-NSPMenuChoice -Prompt 'Filter' -Allowed $filterAllowed -Default 'N'
                        if ($filterChoice -ne 'N') {
                            $filterDisplayName = $knownFilters[[int]$filterChoice - 1].DisplayName
                            Write-Host '[1] Include  [2] Exclude'
                            $filterModeChoice = Read-NSPMenuChoice -Prompt 'Filter mode' -Allowed @('1', '2') -Default '1'
                            $filterMode = if ($filterModeChoice -eq '2') { 'Exclude' } else { 'Include' }
                        }
                    }

                    $assignArgs = @{
                        IntuneObjectId = $targetApp.Id; AppDisplayName = $targetApp.DisplayName
                        TargetType = $targetType; GroupId = $targetGroup.Id; GroupDisplayName = $targetGroup.DisplayName
                        Mode = $mode; Intent = $intent; TenantId = $registration.TenantId; ClientId = $registration.ClientId
                    }
                    if ($filterDisplayName) { $assignArgs.FilterDisplayName = $filterDisplayName; $assignArgs.FilterMode = $filterMode }

                    $preview = New-NSPIntuneWin32AppAssignment @assignArgs
                    $preview | Format-List
                    $executeChoice = Read-NSPMenuChoice -Prompt 'Create this assignment now? [Y/N]' -Allowed @('Y', 'N') -Default 'N'
                    if ($executeChoice -eq 'Y') {
                        $result = New-NSPIntuneWin32AppAssignment @assignArgs -Execute -Confirm:$false
                        $result | Format-List
                    } else {
                        Write-Host 'No changes were made.' -ForegroundColor Yellow
                    }
                }
            }
            '15' {
                $registrationPath = Join-Path $RepoRoot 'Config\Local\GraphAppRegistration.json'
                if (-not (Test-Path -LiteralPath $registrationPath)) {
                    Write-Warning 'No tenant app registration is recorded. Use [11] first.'
                } else {
                    $registration = Get-Content -LiteralPath $registrationPath -Raw | ConvertFrom-Json
                    $displayName = Read-Host 'Filter display name'

                    $platforms = @('android', 'androidForWork', 'androidMobileApplicationManagement', 'iOS', 'iOSMobileApplicationManagement', 'macOS', 'windows10AndLater')
                    for ($index = 0; $index -lt $platforms.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $platforms[$index]) }
                    Write-Host '  [O] Other (type it)'
                    $platformAllowed = @(@(1..$platforms.Count | ForEach-Object { [string]$_ }) + 'O')
                    $platformChoice = Read-NSPMenuChoice -Prompt 'Platform' -Allowed $platformAllowed -Default '1'
                    $platform = if ($platformChoice -eq 'O') { Read-Host 'Platform (exact Graph value)' } else { $platforms[[int]$platformChoice - 1] }

                    $clauses = [Collections.Generic.List[object]]::new()
                    do {
                        Write-Host ("=== Clause {0} ===" -f ($clauses.Count + 1)) -ForegroundColor Cyan
                        Write-Host '  [P] Single property clause'
                        Write-Host '  [G] Group of clauses joined by OR (e.g. manufacturer is Dell OR HP)'
                        $clauseKind = Read-NSPMenuChoice -Prompt 'Clause type' -Allowed @('P', 'G') -Default 'P'
                        if ($clauseKind -eq 'G') {
                            $groupClauses = [Collections.Generic.List[object]]::new()
                            do {
                                Write-Host ("--- OR-group clause {0} ---" -f ($groupClauses.Count + 1)) -ForegroundColor DarkCyan
                                $groupClauses.Add((Read-NSPFilterClause -TenantId $registration.TenantId -ClientId $registration.ClientId -Platform $platform))
                                $addAnotherInGroup = Read-NSPMenuChoice -Prompt 'Add another clause to this OR-group? [Y/N]' -Allowed @('Y', 'N') -Default 'N'
                            } while ($addAnotherInGroup -eq 'Y')
                            $clauses.Add(@{ Operator = 'or'; Clauses = @($groupClauses) })
                        } else {
                            $clauses.Add((Read-NSPFilterClause -TenantId $registration.TenantId -ClientId $registration.ClientId -Platform $platform))
                        }

                        $addAnother = Read-NSPMenuChoice -Prompt 'Add another clause (joined with AND)? [Y/N]' -Allowed @('Y', 'N') -Default 'N'
                    } while ($addAnother -eq 'Y')

                    $filterArgs = @{ DisplayName = $displayName; Platform = $platform; Clauses = @($clauses); TenantId = $registration.TenantId; ClientId = $registration.ClientId }
                    $preview = New-NSPIntuneAssignmentFilter @filterArgs
                    $preview | Format-List
                    $executeChoice = Read-NSPMenuChoice -Prompt 'Create this filter now? [Y/N]' -Allowed @('Y', 'N') -Default 'N'
                    if ($executeChoice -eq 'Y') {
                        $result = New-NSPIntuneAssignmentFilter @filterArgs -Execute -Confirm:$false
                        $result | Format-List
                    } else {
                        Write-Host 'No changes were made.' -ForegroundColor Yellow
                    }
                }
            }
            '16' {
                $registrationPath = Join-Path $RepoRoot 'Config\Local\GraphAppRegistration.json'
                if (-not (Test-Path -LiteralPath $registrationPath)) {
                    Write-Warning 'No tenant app registration is recorded. Use [11] first.'
                } else {
                    $registration = Get-Content -LiteralPath $registrationPath -Raw | ConvertFrom-Json
                    $assignmentInventoryRoot = Join-Path $RepoRoot '.nsp-intuneapps\assignment-inventory'
                    $latestAssignmentInventory = if (Test-Path -LiteralPath $assignmentInventoryRoot) { Get-ChildItem -LiteralPath $assignmentInventoryRoot -Filter '*.json' -File | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1 } else { $null }
                    $knownGroups = if ($latestAssignmentInventory) { @((Get-Content -LiteralPath $latestAssignmentInventory.FullName -Raw | ConvertFrom-Json).DistinctGroups) } else { @() }

                    Write-Host '[1] View/edit the tenant''s master default groups (applied to every newly created app)' -ForegroundColor Cyan
                    Write-Host '[2] View/edit one app''s assignment override'
                    $sub = Read-NSPMenuChoice -Prompt 'Action' -Allowed @('1', '2') -Default '1'

                    if ($sub -eq '1') {
                        $current = Get-NSPTenantAssignmentDefaults -RepoRoot $RepoRoot -TenantId $registration.TenantId
                        Write-Host "Current master assignment groups for tenant $($registration.TenantId):" -ForegroundColor Cyan
                        if (@($current.DefaultAssignments).Count -eq 0) {
                            Write-Host '  (none configured - newly created apps get no automatic assignment)' -ForegroundColor DarkGray
                        } else {
                            $current.DefaultAssignments | Format-Table TargetType, GroupDisplayName, Mode, Intent, FilterDisplayName -AutoSize
                        }
                        $editChoice = Read-NSPMenuChoice -Prompt 'Replace this list now? [Y/N]' -Allowed @('Y', 'N') -Default 'N'
                        if ($editChoice -eq 'Y') {
                            $entries = [Collections.Generic.List[object]]::new()
                            do {
                                Write-Host ("=== Master group {0} ===" -f ($entries.Count + 1)) -ForegroundColor Cyan
                                $target = Invoke-NSPAssignmentTargetPicker -TenantId $registration.TenantId -ClientId $registration.ClientId -KnownGroups $knownGroups
                                $modeAndIntent = Read-NSPAssignmentModeAndIntent -TargetType $target.TargetType
                                $entries.Add(@{ TargetType = $target.TargetType; GroupId = $target.Id; GroupDisplayName = $target.DisplayName; Mode = $modeAndIntent.Mode; Intent = $modeAndIntent.Intent })
                                $addAnother = Read-NSPMenuChoice -Prompt 'Add another master group? [Y/N]' -Allowed @('Y', 'N') -Default 'N'
                            } while ($addAnother -eq 'Y')

                            $saveResult = Set-NSPTenantAssignmentDefaults -RepoRoot $RepoRoot -TenantId $registration.TenantId -DefaultAssignments @($entries) -Confirm:$false
                            Write-Host "Saved $($saveResult.Count) master assignment group(s) for tenant $($registration.TenantId)." -ForegroundColor Green
                            Write-Host 'These apply to every newly created app unless it has its own override (option 2 above).' -ForegroundColor DarkGray
                        }
                    } else {
                        $deployableCatalog = @($catalog | Where-Object Classification -eq 'Deployable' | Sort-Object Name)
                        if ($deployableCatalog.Count -eq 0) {
                            Write-Warning 'No deployable catalog entries were found.'
                        } else {
                            for ($index = 0; $index -lt $deployableCatalog.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $deployableCatalog[$index].Name) }
                            $appChoice = Read-NSPMenuChoice -Prompt 'App' -Allowed @(1..$deployableCatalog.Count | ForEach-Object { [string]$_ })
                            $targetAppName = $deployableCatalog[[int]$appChoice - 1].Name

                            $existingOverride = Get-NSPAppAssignmentOverride -RepoRoot $RepoRoot -TenantId $registration.TenantId -AppName $targetAppName
                            if (-not $existingOverride.HasOverride) {
                                Write-Host "'$targetAppName' has no override recorded; it currently falls back to the tenant's master groups." -ForegroundColor DarkGray
                            } elseif (@($existingOverride.AssignmentOverride).Count -eq 0) {
                                Write-Host "'$targetAppName' has an override recorded that assigns it to nothing." -ForegroundColor DarkGray
                            } else {
                                Write-Host "Current override for '$targetAppName':" -ForegroundColor Cyan
                                $existingOverride.AssignmentOverride | Format-Table TargetType, GroupDisplayName, Mode, Intent, FilterDisplayName -AutoSize
                            }

                            Write-Host '[1] Replace the override with a new list' -ForegroundColor Cyan
                            Write-Host '[2] Set the override to "assign nothing"'
                            Write-Host '[3] Clear the override (fall back to the tenant''s master groups)'
                            Write-Host '[N] No change'
                            $overrideAction = Read-NSPMenuChoice -Prompt 'Action' -Allowed @('1', '2', '3', 'N') -Default 'N'
                            if ($overrideAction -eq '3') {
                                Set-NSPAppAssignmentOverride -RepoRoot $RepoRoot -TenantId $registration.TenantId -AppName $targetAppName -Clear -Confirm:$false | Out-Null
                                Write-Host "Cleared the override for '$targetAppName'." -ForegroundColor Green
                            } elseif ($overrideAction -eq '2') {
                                Set-NSPAppAssignmentOverride -RepoRoot $RepoRoot -TenantId $registration.TenantId -AppName $targetAppName -AssignmentOverride @() -Confirm:$false | Out-Null
                                Write-Host "'$targetAppName' will now be assigned to nothing, regardless of the tenant's master groups." -ForegroundColor Green
                            } elseif ($overrideAction -eq '1') {
                                $entries = [Collections.Generic.List[object]]::new()
                                do {
                                    Write-Host ("=== Override group {0} ===" -f ($entries.Count + 1)) -ForegroundColor Cyan
                                    $target = Invoke-NSPAssignmentTargetPicker -TenantId $registration.TenantId -ClientId $registration.ClientId -KnownGroups $knownGroups
                                    $modeAndIntent = Read-NSPAssignmentModeAndIntent -TargetType $target.TargetType
                                    $entries.Add(@{ TargetType = $target.TargetType; GroupId = $target.Id; GroupDisplayName = $target.DisplayName; Mode = $modeAndIntent.Mode; Intent = $modeAndIntent.Intent })
                                    $addAnother = Read-NSPMenuChoice -Prompt "Add another group to this app's override? [Y/N]" -Allowed @('Y', 'N') -Default 'N'
                                } while ($addAnother -eq 'Y')

                                $saveResult = Set-NSPAppAssignmentOverride -RepoRoot $RepoRoot -TenantId $registration.TenantId -AppName $targetAppName -AssignmentOverride @($entries) -Confirm:$false
                                Write-Host "Saved $($saveResult.Count) override entry/entries for '$targetAppName'." -ForegroundColor Green
                            } else {
                                Write-Host 'No changes were made.' -ForegroundColor Yellow
                            }
                        }
                    }
                }
            }
            '17' {
                $registrationPath = Join-Path $RepoRoot 'Config\Local\GraphAppRegistration.json'
                if (-not (Test-Path -LiteralPath $registrationPath)) {
                    Write-Warning 'No tenant app registration is recorded. Use [11] first.'
                } else {
                    $registration = Get-Content -LiteralPath $registrationPath -Raw | ConvertFrom-Json
                    Write-Host 'A delegated browser login may open. This reads every Win32 app''s supersedence relationships - no tenant data is changed.' -ForegroundColor Yellow
                    $candidates = Get-NSPIntuneAppRetirementCandidates -RepoRoot $RepoRoot -Connect
                    $candidateList = @($candidates.Candidates)
                    if ($candidateList.Count -eq 0) {
                        Write-Host 'No retirement candidates were found (no NSP-managed app currently supersedes another NSP-managed app).' -ForegroundColor DarkGray
                    } else {
                        Write-Host 'Superseded apps eligible for retirement:' -ForegroundColor Cyan
                        for ($index = 0; $index -lt $candidateList.Count; $index++) {
                            $candidate = $candidateList[$index]
                            Write-Host ("  [{0}] {1} -> superseded by {2} ({3})" -f ($index + 1), $candidate.SupersededDisplayName, $candidate.SupersedingDisplayName, $candidate.SupersedenceType)
                        }
                        Write-Host '  [N] None - do not retire anything now'
                        $retireAllowed = @(@(1..$candidateList.Count | ForEach-Object { [string]$_ }) + 'N')
                        $retireChoice = Read-NSPMenuChoice -Prompt 'Retire which superseded app' -Allowed $retireAllowed -Default 'N'
                        if ($retireChoice -ne 'N') {
                            $target = $candidateList[[int]$retireChoice - 1]
                            $preview = Remove-NSPIntuneWin32App -IntuneObjectId $target.SupersededAppId -DisplayName $target.SupersededDisplayName -TenantId $candidates.TenantId -ClientId $registration.ClientId
                            $preview | Format-List
                            Write-Warning "This permanently deletes '$($target.SupersededDisplayName)', which was superseded by '$($target.SupersedingDisplayName)' ($($target.SupersedenceType)). It cannot be undone."
                            $confirmText = Read-Host "Type the app's exact display name to confirm retirement, or press Enter to cancel"
                            if ($confirmText -eq $target.SupersededDisplayName) {
                                $result = Remove-NSPIntuneWin32App -IntuneObjectId $target.SupersededAppId -DisplayName $target.SupersededDisplayName -TenantId $candidates.TenantId -ClientId $registration.ClientId -Execute -Confirm:$false
                                $result | Format-List
                            } else {
                                Write-Host 'No changes were made.' -ForegroundColor Yellow
                            }
                        }
                    }
                }
            }
        }
        if ($choice -ne 'Q') { Read-Host 'Press Enter to return to the dashboard' | Out-Null }
    } while ($choice -ne 'Q')
}
