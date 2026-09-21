Describe 'Deterministic app source state' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'returns stable management markers and hashes' {
        $state = Get-NSPAppSourceState -RepoRoot (Split-Path -Path $PSScriptRoot -Parent) -AppName 'VCred'
        $state.MetadataSha256 | Should -Match '^[A-F0-9]{64}$'
        $state.ContentSha256 | Should -Match '^[A-F0-9]{64}$'
        $state.ContentFileCount | Should -BeGreaterThan 0
        $state.ManagementNotes | Should -Match '\[NSP-IntuneApps:VCred\]'
    }

    It 'places fingerprints into new deployment plans' {
        $planPath = Join-Path $TestDrive 'plan.json'
        New-NSPAppDeploymentPlan -RepoRoot (Split-Path -Path $PSScriptRoot -Parent) -AppName VCred -OutputPath $planPath | Out-Null
        $plan = Get-Content -LiteralPath $planPath -Raw | ConvertFrom-Json
        $plan.SchemaVersion | Should -Be '1.1'
        $plan.Entries[0].SourceId | Should -Be 'VCred'
        $plan.Entries[0].DisplayName | Should -Be 'Microsoft Visual C++ Redistributable (v14)'
        $plan.Entries[0].Publisher | Should -Be 'Microsoft Corporation'
        $plan.Entries[0].ContentSha256 | Should -Match '^[A-F0-9]{64}$'
        $plan.Entries[0].PlannedAction | Should -Be 'DiscoveryRequired'
    }

    It 'resolves a saved plan against a read-only inventory' {
        $planPath = Join-Path $TestDrive 'resolve-plan.json'
        New-NSPAppDeploymentPlan -RepoRoot (Split-Path -Path $PSScriptRoot -Parent) -AppName VCred -OutputPath $planPath | Out-Null
        $plan = Get-Content -LiteralPath $planPath -Raw | ConvertFrom-Json
        $entry = $plan.Entries[0]
        $inventoryPath = Join-Path $TestDrive 'inventory.json'
        @([ordered]@{
            Id='existing-vcred'
            DisplayName=$entry.DisplayName
            Publisher=$entry.Publisher
            Notes="[NSP-IntuneApps:$($entry.SourceId)]`n[NSP-Metadata-SHA256:$($entry.MetadataSha256)]`n[NSP-Content-SHA256:$($entry.ContentSha256)]"
        }) | ConvertTo-Json | Set-Content -LiteralPath $inventoryPath -Encoding UTF8
        $result = Update-NSPAppDeploymentPlan -PlanPath $planPath -InventoryPath $inventoryPath
        $result.Entries[0].PlannedAction | Should -Be 'NoChange'
        $result.Entries[0].IntuneObjectId | Should -Be 'existing-vcred'
    }
}
