Describe 'Get-NSPIntuneAppRetirementCandidates' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'flags a superseded app only when both sides carry an NSP-IntuneApps marker' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            if ($Uri -match 'mobileApps\?') {
                return @(
                    [pscustomobject]@{ id = 'new-app-1'; displayName = 'Fixture v2'; notes = "[NSP-IntuneApps:Fixture]`n[NSP-Metadata-SHA256:AA]`n[NSP-Content-SHA256:BB]" }
                    [pscustomobject]@{ id = 'old-app-1'; displayName = 'Fixture v1'; notes = "[NSP-IntuneApps:Fixture]`n[NSP-Metadata-SHA256:CC]`n[NSP-Content-SHA256:DD]" }
                    [pscustomobject]@{ id = 'unmanaged-app-1'; displayName = 'Some Vendor App'; notes = '' }
                )
            }
            if ($Uri -match 'mobileApps/new-app-1/relationships') {
                return @([pscustomobject]@{ '@odata.type' = '#microsoft.graph.mobileAppSupersedence'; supersedenceType = 'update'; targetId = 'old-app-1' })
            }
            return @()
        } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'Candidates'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null

        $result = Get-NSPIntuneAppRetirementCandidates -RepoRoot $repoRoot -Connect

        $result.Count | Should -Be 1
        $result.Candidates[0].SupersededAppId | Should -Be 'old-app-1'
        $result.Candidates[0].SupersedingAppId | Should -Be 'new-app-1'
        $result.Candidates[0].SupersedenceType | Should -Be 'update'
        $result.Candidates[0].SupersededSourceId | Should -Be 'Fixture'
    }

    It 'ignores a relationship pointing at an app with no NSP-IntuneApps marker' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            if ($Uri -match 'mobileApps\?') {
                return @(
                    [pscustomobject]@{ id = 'new-app-1'; displayName = 'Fixture v2'; notes = '[NSP-IntuneApps:Fixture]' }
                    [pscustomobject]@{ id = 'vendor-app-1'; displayName = 'Vendor App'; notes = '' }
                )
            }
            if ($Uri -match 'mobileApps/new-app-1/relationships') {
                return @([pscustomobject]@{ '@odata.type' = '#microsoft.graph.mobileAppSupersedence'; supersedenceType = 'replace'; targetId = 'vendor-app-1' })
            }
            return @()
        } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'NoMarker'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null

        $result = Get-NSPIntuneAppRetirementCandidates -RepoRoot $repoRoot -Connect

        $result.Count | Should -Be 0
    }

    It 'reports zero candidates when no app has any supersedence relationship' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            if ($Uri -match 'mobileApps\?') {
                return @([pscustomobject]@{ id = 'app-1'; displayName = 'Fixture'; notes = '[NSP-IntuneApps:Fixture]' })
            }
            return @()
        } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'NoRelationships'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null

        $result = Get-NSPIntuneAppRetirementCandidates -RepoRoot $repoRoot -Connect

        $result.Count | Should -Be 0
        $null -eq $result.Candidates | Should -BeFalse
    }
}
