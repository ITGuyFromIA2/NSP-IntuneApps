$repoRoot = Split-Path -Path $PSScriptRoot -Parent
Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force

Describe 'Deployment plan summary' {
    It 'summarizes review, execution, inventory, and attention state' {
        $planPath = Join-Path $TestDrive 'plan.json'
        [ordered]@{
            SchemaVersion='1.1'; PlanType='Win32AppDeployment'; CreatedAt='2026-09-18T12:00:00-05:00'
            TenantId='tenant-id'; SafetyMode='PlanOnly'; InventoryResolvedAt='2026-09-18T12:05:00-05:00'
            Entries=@(
                @{ Decision='Approved'; ExecutionStatus='Completed'; PlannedAction='NoChange' }
                @{ Decision='Skipped'; ExecutionStatus='NotStarted'; PlannedAction='AdoptOrReview' }
                @{ Decision='Pending'; ExecutionStatus='Failed'; PlannedAction='UpdateContentInPlace' }
            )
        } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $planPath

        $summary = Get-NSPAppDeploymentPlanSummary -RepoRoot $repoRoot -PlanPath $planPath
        $summary.Total | Should -Be 3
        $summary.Approved | Should -Be 1
        $summary.Skipped | Should -Be 1
        $summary.Pending | Should -Be 1
        $summary.Completed | Should -Be 1
        $summary.Failed | Should -Be 1
        $summary.AttentionRequired | Should -Be 2
        $summary.InventoryResolved | Should -BeTrue
    }

    It 'returns no records when the default tracker folder is absent' {
        $emptyRepo = Join-Path $TestDrive 'empty'
        New-Item -ItemType Directory -Path $emptyRepo | Out-Null
        @(Get-NSPAppDeploymentPlanSummary -RepoRoot $emptyRepo).Count | Should -Be 0
    }

    It 'blocks decision review until inventory and tenant identity are resolved' {
        $planPath = Join-Path $TestDrive 'unresolved-plan.json'
        [ordered]@{
            SchemaVersion='1.1'; PlanType='Win32AppDeployment'; SafetyMode='PlanOnly'; TenantId=$null; Targeting=$null
            Entries=@(@{ Order=1; Name='Example'; DisplayName='Example'; PlannedAction='DiscoveryRequired'; Decision='Pending'; CanExecute=$false })
        } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $planPath

        $review = Get-NSPAppDeploymentPlanReview -PlanPath $planPath
        $review.CanReviewDecisions | Should -BeFalse
        $review.CanExecute | Should -BeFalse
        $review.ExecutorStatus | Should -Be 'NotImplemented'
        $review.Blockers -join ' ' | Should -Match 'inventory'
        $review.Blockers -join ' ' | Should -Match 'tenant ID'
    }

    It 'shows resolved action effects, targeting warning, and the bound account' {
        $planPath = Join-Path $TestDrive 'resolved-plan.json'
        [ordered]@{
            SchemaVersion='1.1'; PlanType='Win32AppDeployment'; SafetyMode='PlanOnly'
            TenantId='00000000-0000-0000-0000-000000000001'; InventoryAccount='operator@example.test'
            InventoryResolvedAt='2026-09-19T01:00:00Z'; Targeting=$null
            Entries=@(
                @{ Order=1; Name='Example'; DisplayName='Example'; PlannedAction='UpdateContentInPlace'; Decision='Pending'; CanExecute=$true; IntuneObjectId='app-id' }
            )
        } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $planPath

        $review = Get-NSPAppDeploymentPlanReview -PlanPath $planPath
        $review.CanReviewDecisions | Should -BeTrue
        $review.Account | Should -Be 'operator@example.test'
        $review.Warnings -join ' ' | Should -Match 'No assignment target'
        $review.Entries[0].CanApprove | Should -BeTrue
        $review.Entries[0].Effect | Should -Match 'preserving the Intune object ID'
    }

    It 'refuses to bind an inventory from a different tenant' {
        $planPath = Join-Path $TestDrive 'tenant-plan.json'
        $inventoryPath = Join-Path $TestDrive 'tenant-inventory.json'
        [ordered]@{
            SchemaVersion='1.1'; PlanType='Win32AppDeployment'; SafetyMode='PlanOnly'; TenantId='tenant-a'
            Entries=@()
        } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $planPath
        [ordered]@{ SchemaVersion='1.0'; TenantId='tenant-b'; Account='operator@example.test'; Apps=@() } |
            ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $inventoryPath

        { Update-NSPAppDeploymentPlan -PlanPath $planPath -InventoryPath $inventoryPath -Confirm:$false } |
            Should -Throw '*does not match inventory tenant*'
    }
}
