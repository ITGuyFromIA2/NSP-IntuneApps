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
        Write-Host ''
        Write-Host '  [Q] Quit'
        $choice = Read-NSPMenuChoice -Prompt 'Choose an action' -Allowed @('1','2','3','4','5','6','7','8','9','10','11','12','Q')

        switch ($choice) {
            '1' {
                $preflight.Results | Format-Table Area, Name, Status, Detail -AutoSize
                if ($preflight.SyntaxErrors) { $preflight.SyntaxErrors | Format-Table File, Line, Message -Wrap }
            }
            '2' { $catalog | Format-Table Name, Classification, ScriptCount, PackageCount, Reason -AutoSize -Wrap }
            '3' {
                Write-Host '[A] Drive map' -ForegroundColor Cyan
                Write-Host '[B] RDP / RemoteApp'
                Write-Host '[C] Printer driver / queue'
                Write-Host '[D] Capture an interactive installer sequence'
                Write-Host '[E] FortiClient VPN configuration'
                Write-Host '[F] Web / file shortcut'
                Write-Host '[G] Adobe Acrobat / Reader package'
                Write-Host '[H] Managed Reboots policy'
                $template = Read-NSPMenuChoice -Prompt 'Template' -Allowed @('A','B','C','D','E','F','G','H') -Default 'A'
                if ($template -eq 'A') { New-NSPDriveMapApp -RepoRoot $RepoRoot -Interactive }
                elseif ($template -eq 'B') { New-NSPRdpApp -RepoRoot $RepoRoot -Interactive }
                elseif ($template -eq 'C') { New-NSPPrinterApp -RepoRoot $RepoRoot -Interactive }
                elseif ($template -eq 'D') {
                    Write-Host 'Example: C:\Temp\VendorSetup.exe' -ForegroundColor DarkGray
                    $installerPath = Read-Host 'Installer path'
                    Start-NSPInstallerCapture -InstallerPath $installerPath
                }
                elseif ($template -eq 'E') { New-NSPFortiClientVpnConfigApp -RepoRoot $RepoRoot -Interactive }
                elseif ($template -eq 'F') { New-NSPShortcutApp -RepoRoot $RepoRoot -Interactive }
                elseif ($template -eq 'G') { New-NSPAdobeApp -RepoRoot $RepoRoot -Interactive }
                elseif ($template -eq 'H') { New-NSPManagedRebootsApp -RepoRoot $RepoRoot -Interactive }
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
                $plan | Select-Object ProfileName, Action, Thumbprint, CertificateExpires, AssignmentTarget, AssignmentDisplayName, TenantId, Account, MissingUris, Conflicts, CanExecute | Format-List
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
                if ($deployableCatalog.Count -eq 0) {
                    Write-Warning 'No deployable catalog entries were found.'
                } else {
                    for ($index = 0; $index -lt $deployableCatalog.Count; $index++) {
                        Write-Host ("[{0}] {1}" -f ($index + 1), $deployableCatalog[$index].Name)
                    }
                    Write-Host 'Build a batch by number (e.g. 1,3,5), by name, or press Enter to include every deployable app above.'
                    $picked = Read-Host 'Apps'
                    $selection = if ([string]::IsNullOrWhiteSpace($picked)) {
                        $null
                    } else {
                        $tokens = @($picked -split ',' | ForEach-Object Trim | Where-Object { $_ })
                        @($tokens | ForEach-Object {
                            if ($_ -match '^\d+$' -and [int]$_ -ge 1 -and [int]$_ -le $deployableCatalog.Count) {
                                $deployableCatalog[[int]$_ - 1].Name
                            } else {
                                $_
                            }
                        })
                    }
                    if ($selection) { Write-Host "Batch: $($selection -join ', ')" -ForegroundColor Cyan }
                    $planFile = New-NSPAppDeploymentPlan -RepoRoot $RepoRoot -AppName $selection
                    Write-Host "Tracker saved to $($planFile.FullName)" -ForegroundColor Green
                    Write-Host 'Collect and bind a read-only tenant inventory before approving any app action.' -ForegroundColor Yellow
                }
            }
            '7' {
                Write-Host 'A delegated browser login may open. Requested permission: DeviceManagementApps.Read.All (read-only).' -ForegroundColor Yellow
                $inventory = Get-NSPIntuneAppInventory -RepoRoot $RepoRoot -Connect
                $inventory | Select-Object TenantId, Account, AppCount, ManagedCount, OutputPath | Format-List
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
                        $review | Select-Object TenantId, Account, SafetyMode, Targeting, CanReviewDecisions, ExecutorStatus, Blockers, Warnings | Format-List
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
                    $review | Select-Object TenantId, Account, SafetyMode, Targeting, CanReviewDecisions, ExecutorStatus, Blockers, Warnings | Format-List
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
                if ($preview.Status -in @('PlanOnly', 'NeedsRedirectUriRepair')) {
                    $actionLabel = if ($preview.Status -eq 'NeedsRedirectUriRepair') { 'Repair the broker redirect URI now' } else { 'Create the app registration and grant admin consent now' }
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
        }
        if ($choice -ne 'Q') { Read-Host 'Press Enter to return to the dashboard' | Out-Null }
    } while ($choice -ne 'Q')
}
