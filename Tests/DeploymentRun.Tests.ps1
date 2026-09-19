$repoRoot = Split-Path -Path $PSScriptRoot -Parent
Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force

Describe 'Resumable deployment run journal' {
    BeforeEach {
        $planPath = Join-Path $TestDrive 'approved-plan.json'
        $runPath = Join-Path $TestDrive 'run.json'
        [ordered]@{
            SchemaVersion='1.1'; PlanType='Win32AppDeployment'; SafetyMode='PlanOnly'; RepoRoot=$TestDrive
            TenantId='00000000-0000-0000-0000-000000000001'; InventoryAccount='operator@example.test'
            InventoryResolvedAt='2026-09-19T02:00:00Z'; Targeting=$null
            Entries=@(
                @{ Order=1; Name='MetadataApp'; SourceId='metadata-app'; DisplayName='Metadata App'; PlannedAction='UpdateMetadataInPlace'; Decision='Approved'; CanExecute=$true; IntuneObjectId='object-1' }
                @{ Order=2; Name='NoChangeApp'; SourceId='no-change-app'; DisplayName='No Change App'; PlannedAction='NoChange'; Decision='Approved'; CanExecute=$true; IntuneObjectId='object-2' }
            )
        } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $planPath
    }

    It 'creates an ordered local journal without executing a stage' {
        New-NSPAppDeploymentRun -PlanPath $planPath -OutputPath $runPath -Confirm:$false | Out-Null
        $summary = Get-NSPAppDeploymentRunSummary -RunPath $runPath
        $summary.Status | Should -Be 'Ready'
        $summary.CurrentApp | Should -Be 'MetadataApp'
        $summary.CurrentStage | Should -Be 'ValidatePlan'
        $summary.CurrentStageState | Should -Be 'Pending'
        $summary.Completed | Should -Be 0
    }

    It 'enforces app order and valid stage transitions' {
        New-NSPAppDeploymentRun -PlanPath $planPath -OutputPath $runPath -Confirm:$false | Out-Null
        { Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName 'NoChangeApp' -Stage 'ValidatePlan' -Status Running -Confirm:$false } |
            Should -Throw '*current app*'
        { Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName 'MetadataApp' -Stage 'ValidatePlan' -Status Succeeded -Confirm:$false } |
            Should -Throw '*Invalid stage transition*'
    }

    It 'persists failure and supports retry from the failed stage' {
        New-NSPAppDeploymentRun -PlanPath $planPath -OutputPath $runPath -Confirm:$false | Out-Null
        Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName 'MetadataApp' -Stage 'ValidatePlan' -Status Running -Confirm:$false | Out-Null
        $failed = Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName 'MetadataApp' -Stage 'ValidatePlan' -Status Failed -Message 'Validation did not pass.' -Confirm:$false
        $failed.Status | Should -Be 'AttentionRequired'
        $failed.Failed | Should -Be 1
        $failed.CurrentStage | Should -Be 'ValidatePlan'

        Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName 'MetadataApp' -Stage 'ValidatePlan' -Status Running -Message 'Retry after correction.' -Confirm:$false | Out-Null
        Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName 'MetadataApp' -Stage 'ValidatePlan' -Status Succeeded -Confirm:$false | Out-Null
        $document = Get-Content -LiteralPath $runPath -Raw | ConvertFrom-Json
        $document.Entries[0].Stages[0].Attempt | Should -Be 2
        $document.Entries[0].Status | Should -Be 'InProgress'
    }

    It 'advances only after every stage and completes the run' {
        New-NSPAppDeploymentRun -PlanPath $planPath -OutputPath $runPath -Confirm:$false | Out-Null
        do {
            $summary = Get-NSPAppDeploymentRunSummary -RunPath $runPath
            if ($summary.Status -eq 'Completed') { break }
            Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName $summary.CurrentApp -Stage $summary.CurrentStage -Status Running -Confirm:$false | Out-Null
            Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName $summary.CurrentApp -Stage $summary.CurrentStage -Status Succeeded -Confirm:$false | Out-Null
        } while ($true)

        $summary.Status | Should -Be 'Completed'
        $summary.Completed | Should -Be 2
        $summary.Pending | Should -Be 0
        $summary.CurrentApp | Should -BeNullOrEmpty
        $document = Get-Content -LiteralPath $runPath -Raw | ConvertFrom-Json
        @($document.Events | Where-Object Type -eq 'StageTransition').Count | Should -Be 8
    }

    It 'refuses to queue a plan with pending decisions' {
        $plan = Get-Content -LiteralPath $planPath -Raw | ConvertFrom-Json
        $plan.Entries[1].Decision = 'Pending'
        $plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $planPath
        { New-NSPAppDeploymentRun -PlanPath $planPath -OutputPath $runPath -Confirm:$false } |
            Should -Throw '*still need an Approve/Skip decision*'
    }

    It 'exports a concise report without transition messages' {
        New-NSPAppDeploymentRun -PlanPath $planPath -OutputPath $runPath -Confirm:$false | Out-Null
        Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName 'MetadataApp' -Stage 'ValidatePlan' -Status Running -Message 'private troubleshooting detail' -Confirm:$false | Out-Null
        Set-NSPAppDeploymentRunStage -RunPath $runPath -AppName 'MetadataApp' -Stage 'ValidatePlan' -Status Failed -Message 'another private detail' -Confirm:$false | Out-Null
        $reportPath = Join-Path $TestDrive 'run-report.md'
        Export-NSPAppDeploymentRunReport -RunPath $runPath -OutputPath $reportPath -Confirm:$false | Out-Null
        $report = Get-Content -LiteralPath $reportPath -Raw
        $report | Should -Match 'Attention required'
        $report | Should -Match 'MetadataApp'
        $report | Should -Match 'ValidatePlan'
        $report | Should -Not -Match 'private troubleshooting detail'
        $report | Should -Not -Match 'another private detail'
    }
}
