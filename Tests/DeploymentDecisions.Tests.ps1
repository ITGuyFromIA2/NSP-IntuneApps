Describe 'Set-NSPAppDeploymentDecisions -Decisions (non-interactive)' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force

        function New-FixturePlan {
            param([string]$Path, [object[]]$Entries)
            [ordered]@{
                SchemaVersion = '1.1'; PlanType = 'Win32AppDeployment'; SafetyMode = 'PlanOnly'
                TenantId = '00000000-0000-0000-0000-000000000001'; InventoryAccount = 'operator@example.test'
                InventoryResolvedAt = '2026-09-19T01:00:00Z'; Targeting = $null
                Entries = $Entries
            } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $Path
        }
    }

    It 'applies a provided decision without any interactive prompt' {
        $planPath = Join-Path $TestDrive 'plan1.json'
        New-FixturePlan -Path $planPath -Entries @(
            @{ Order = 1; Name = 'Example'; DisplayName = 'Example'; PlannedAction = 'UpdateContentInPlace'; Decision = 'Pending'; CanExecute = $true; IntuneObjectId = 'app-id'; ReviewedAt = $null }
        )

        $result = Set-NSPAppDeploymentDecisions -PlanPath $planPath -Decisions @(@{ Name = 'Example'; Decision = 'Approved' }) -Confirm:$false

        $result.Approved | Should -Be 1
        $result.Pending | Should -Be 0
        $document = Get-Content -LiteralPath $planPath -Raw | ConvertFrom-Json
        $document.Entries[0].Decision | Should -Be 'Approved'
        $document.Entries[0].ReviewedAt | Should -Not -BeNullOrEmpty
    }

    It 'applies a Skipped decision' {
        $planPath = Join-Path $TestDrive 'plan2.json'
        New-FixturePlan -Path $planPath -Entries @(
            @{ Order = 1; Name = 'Example'; DisplayName = 'Example'; PlannedAction = 'UpdateContentInPlace'; Decision = 'Pending'; CanExecute = $true; IntuneObjectId = 'app-id'; ReviewedAt = $null }
        )

        $result = Set-NSPAppDeploymentDecisions -PlanPath $planPath -Decisions @(@{ Name = 'Example'; Decision = 'Skipped' }) -Confirm:$false

        $result.Skipped | Should -Be 1
    }

    It 'throws when a pending entry has no matching decision' {
        $planPath = Join-Path $TestDrive 'plan3.json'
        New-FixturePlan -Path $planPath -Entries @(
            @{ Order = 1; Name = 'Example'; DisplayName = 'Example'; PlannedAction = 'UpdateContentInPlace'; Decision = 'Pending'; CanExecute = $true; IntuneObjectId = 'app-id'; ReviewedAt = $null }
        )

        { Set-NSPAppDeploymentDecisions -PlanPath $planPath -Decisions @(@{ Name = 'SomeOtherApp'; Decision = 'Approved' }) -Confirm:$false } |
            Should -Throw '*No decision was provided*'
    }

    It 'throws on an invalid Decision value' {
        $planPath = Join-Path $TestDrive 'plan4.json'
        New-FixturePlan -Path $planPath -Entries @(
            @{ Order = 1; Name = 'Example'; DisplayName = 'Example'; PlannedAction = 'UpdateContentInPlace'; Decision = 'Pending'; CanExecute = $true; IntuneObjectId = 'app-id'; ReviewedAt = $null }
        )

        { Set-NSPAppDeploymentDecisions -PlanPath $planPath -Decisions @(@{ Name = 'Example'; Decision = 'Maybe' }) -Confirm:$false } |
            Should -Throw "*must be 'Approved' or 'Skipped'*"
    }

    It 'requires SupersedenceType when approving a CreateSupersedingApp entry' {
        $planPath = Join-Path $TestDrive 'plan5.json'
        New-FixturePlan -Path $planPath -Entries @(
            @{ Order = 1; Name = 'Example'; DisplayName = 'Example'; PlannedAction = 'CreateSupersedingApp'; Decision = 'Pending'; CanExecute = $true; IntuneObjectId = 'old-app-id'; ReviewedAt = $null }
        )

        { Set-NSPAppDeploymentDecisions -PlanPath $planPath -Decisions @(@{ Name = 'Example'; Decision = 'Approved' }) -Confirm:$false } |
            Should -Throw '*needs SupersedenceType*'
    }

    It 'records SupersedenceType Replace on the plan entry when provided' {
        $planPath = Join-Path $TestDrive 'plan6.json'
        New-FixturePlan -Path $planPath -Entries @(
            @{ Order = 1; Name = 'Example'; DisplayName = 'Example'; PlannedAction = 'CreateSupersedingApp'; Decision = 'Pending'; CanExecute = $true; IntuneObjectId = 'old-app-id'; ReviewedAt = $null }
        )

        Set-NSPAppDeploymentDecisions -PlanPath $planPath -Decisions @(@{ Name = 'Example'; Decision = 'Approved'; SupersedenceType = 'Replace' }) -Confirm:$false | Out-Null

        $document = Get-Content -LiteralPath $planPath -Raw | ConvertFrom-Json
        $document.Entries[0].SupersedenceType | Should -Be 'Replace'
    }

    It 'does not require a decision for an entry that is not Pending' {
        $planPath = Join-Path $TestDrive 'plan7.json'
        New-FixturePlan -Path $planPath -Entries @(
            @{ Order = 1; Name = 'AlreadyDone'; DisplayName = 'AlreadyDone'; PlannedAction = 'NoChange'; Decision = 'Approved'; CanExecute = $true; ReviewedAt = $null }
            @{ Order = 2; Name = 'Example'; DisplayName = 'Example'; PlannedAction = 'UpdateContentInPlace'; Decision = 'Pending'; CanExecute = $true; IntuneObjectId = 'app-id'; ReviewedAt = $null }
        )

        $result = Set-NSPAppDeploymentDecisions -PlanPath $planPath -Decisions @(@{ Name = 'Example'; Decision = 'Approved' }) -Confirm:$false

        $result.Approved | Should -Be 2
    }

    It 'writes nothing under -WhatIf' {
        $planPath = Join-Path $TestDrive 'plan8.json'
        New-FixturePlan -Path $planPath -Entries @(
            @{ Order = 1; Name = 'Example'; DisplayName = 'Example'; PlannedAction = 'UpdateContentInPlace'; Decision = 'Pending'; CanExecute = $true; IntuneObjectId = 'app-id'; ReviewedAt = $null }
        )
        $before = Get-Content -LiteralPath $planPath -Raw

        Set-NSPAppDeploymentDecisions -PlanPath $planPath -Decisions @(@{ Name = 'Example'; Decision = 'Approved' }) -WhatIf | Out-Null

        (Get-Content -LiteralPath $planPath -Raw) | Should -Be $before
    }
}
