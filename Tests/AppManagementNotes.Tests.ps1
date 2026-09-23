Describe 'Set-NSPAppManagementNotes' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force

        function New-FixtureRepo {
            param([string]$Root)
            $appRoot = Join-Path $Root 'Apps\Fixture'
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Source') -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Detect') -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\DownloadInstall_Fixture.ps1') -Value '# setup'
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\Uninstall_Fixture.ps1') -Value '# uninstall'
            Set-Content -LiteralPath (Join-Path $appRoot 'Detect\Detect_Fixture.ps1') -Value '# detect'
            $settings = @'
$VariableConfig = @{}
$VariableConfig.DisplayName = 'Fixture App'
$VariableConfig.Publisher = 'Fixture Publisher'
$VariableConfig.SetupType = 'PoSH'
$VariableConfig.DetectionStyle = 'Script'
$VariableConfig.DetectScript_Filter = 'Detect_*.ps1'
$VariableConfig.SetupFile_Filter = 'DownloadInstall_*.ps1'
$VariableConfig.PoSH = @{ Sign_SourceFilter = '*.ps1'; UninstallFile_Filter = 'Uninstall_*.ps1' }
$VariableConfig.REQ_Architecture = 'All'
$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
'@
            Set-Content -LiteralPath (Join-Path $appRoot 'Fixture_SplitScriptSettings.ps1') -Value $settings
        }
    }

    It 'reports a plan without connecting to any tenant when -Execute is not passed' {
        $repoRoot = Join-Path $TestDrive 'PlanOnly'
        New-FixtureRepo -Root $repoRoot

        $result = Set-NSPAppManagementNotes -RepoRoot $repoRoot -AppName 'Fixture' -IntuneObjectId 'intune-app-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.ManagementNotes | Should -Match '\[NSP-IntuneApps:Fixture\]'
    }

    It 'patches the notes field with the current source hashes' {
        $repoRoot = Join-Path $TestDrive 'Patch'
        New-FixtureRepo -Root $repoRoot

        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { [pscustomobject]@{} } -ModuleName NSP.IntuneApps

        $result = Set-NSPAppManagementNotes -RepoRoot $repoRoot -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Recorded'
        $result.TenantId | Should -Be 'tenant-1'
        Should -Invoke Invoke-MgGraphRequest -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Method -eq 'PATCH' -and $Uri -eq 'https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/intune-app-1'
        }
    }

    It 'throws when Graph returns an error payload without actually throwing' {
        $repoRoot = Join-Path $TestDrive 'ErrorPayload'
        New-FixtureRepo -Root $repoRoot

        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { [pscustomobject]@{ error = [pscustomobject]@{ code = 'BadRequest'; message = 'Something was rejected.' } } } -ModuleName NSP.IntuneApps

        { Set-NSPAppManagementNotes -RepoRoot $repoRoot -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -Execute -Confirm:$false } |
            Should -Throw '*Graph rejected the management-notes PATCH*Something was rejected*'
    }

    It 'patches nothing under -WhatIf' {
        $repoRoot = Join-Path $TestDrive 'WhatIf'
        New-FixtureRepo -Root $repoRoot

        Mock Connect-NSPGraph { throw 'should not be called' } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $result = Set-NSPAppManagementNotes -RepoRoot $repoRoot -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -Execute -WhatIf
        $result | Should -BeNullOrEmpty
    }
}
