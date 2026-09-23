Describe 'Update-NSPIntuneWin32AppBuildProperties' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force

        function New-FixtureCatalogApp {
            param([string]$Root, [string]$ScopeTagName)
            $appRoot = Join-Path $Root 'Apps\Fixture'
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Source') -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Detect') -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\DownloadInstall_Fixture.ps1') -Value '# setup'
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\Uninstall_Fixture.ps1') -Value '# uninstall'
            Set-Content -LiteralPath (Join-Path $appRoot 'Detect\Detect_Fixture.ps1') -Value '# detect'
            $scopeTagLine = if ($ScopeTagName) { "`$VariableConfig.ScopeTagName = '$ScopeTagName'" } else { '' }
            $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = 'Fixture App'
`$VariableConfig.Description = 'Fixture description.'
`$VariableConfig.Publisher = 'Fixture Publisher'
`$VariableConfig.IsFeatured = `$false
`$VariableConfig.Category = @('Computer Management')
`$VariableConfig.SetupType = 'PoSH'
`$VariableConfig.InstallExperience = 'system'
`$VariableConfig.RestartExperience = 'basedOnReturnCode'
`$VariableConfig.REQ_Architecture = 'All'
`$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
`$VariableConfig.DetectionStyle = 'Script'
`$VariableConfig.DetectScript_Filter = 'Detect_*.ps1'
`$VariableConfig.SetupFile_Filter = 'DownloadInstall_*.ps1'
`$VariableConfig.PoSH = @{ Sign_SourceFilter = '*.ps1'; UninstallFile_Filter = 'Uninstall_*.ps1' }
`$VariableConfig.EnforceSignature_Detection = `$true
`$VariableConfig.RunAs32Bit_Detection = `$false
$scopeTagLine
"@
            Set-Content -LiteralPath (Join-Path $appRoot 'Fixture_SplitScriptSettings.ps1') -Value $settings
        }
    }

    It 'reports NoChange when the live app already matches, without patching' {
        $root = Join-Path $TestDrive 'NoChange'
        New-FixtureCatalogApp -Root $root

        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            [pscustomobject]@{ id = 'intune-app-1'; installExperience = [pscustomobject]@{ runAsAccount = 'system'; deviceRestartBehavior = 'basedOnReturnCode' }; roleScopeTagIds = @() }
        } -ModuleName NSP.IntuneApps

        $result = Update-NSPIntuneWin32AppBuildProperties -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'NoChange'
        Should -Invoke Invoke-MgGraphRequest -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter { $Method -eq 'GET' }
    }

    It 'reports a PlanOnly diff without patching when a change is detected and -Execute is not passed' {
        $root = Join-Path $TestDrive 'PlanOnly'
        New-FixtureCatalogApp -Root $root

        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            [pscustomobject]@{ id = 'intune-app-1'; installExperience = [pscustomobject]@{ runAsAccount = 'user'; deviceRestartBehavior = 'suppress' }; roleScopeTagIds = @() }
        } -ModuleName NSP.IntuneApps

        $result = Update-NSPIntuneWin32AppBuildProperties -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.Changes.installExperience.runAsAccount | Should -Be 'system'
        $result.Changes.installExperience.deviceRestartBehavior | Should -Be 'basedOnReturnCode'
        Should -Invoke Invoke-MgGraphRequest -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter { $Method -eq 'GET' }
        Should -Invoke Invoke-MgGraphRequest -Times 0 -ModuleName NSP.IntuneApps -ParameterFilter { $Method -eq 'PATCH' }
    }

    It 'PATCHes only the changed fields when -Execute is passed' {
        $root = Join-Path $TestDrive 'Execute'
        New-FixtureCatalogApp -Root $root

        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            if ($Method -eq 'GET') {
                return [pscustomobject]@{ id = 'intune-app-1'; installExperience = [pscustomobject]@{ runAsAccount = 'user'; deviceRestartBehavior = 'suppress' }; roleScopeTagIds = @() }
            }
            [pscustomobject]@{}
        } -ModuleName NSP.IntuneApps

        $result = Update-NSPIntuneWin32AppBuildProperties -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Updated'
        Should -Invoke Invoke-MgGraphRequest -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Method -eq 'PATCH' -and $Uri -eq 'https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/intune-app-1' -and $Body -match 'runAsAccount' -and $Body -notmatch 'roleScopeTagIds'
        }
    }

    It 'resolves ScopeTagName to an id via getRoleScopeTagsByResource and includes it in the PATCH' {
        $root = Join-Path $TestDrive 'ScopeTag'
        New-FixtureCatalogApp -Root $root -ScopeTagName 'Managed Services'

        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            [pscustomobject]@{ id = 'intune-app-1'; installExperience = [pscustomobject]@{ runAsAccount = 'system'; deviceRestartBehavior = 'basedOnReturnCode' }; roleScopeTagIds = @() }
        } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            @([pscustomobject]@{ id = 'scopetag-1'; displayName = 'Managed Services' })
        } -ModuleName NSP.IntuneApps

        $result = Update-NSPIntuneWin32AppBuildProperties -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.Changes.roleScopeTagIds | Should -Be @('scopetag-1')
        Should -Invoke Invoke-NSPGraphCollection -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter { $Uri -match "displayName eq 'Managed Services'" }
    }

    It 'throws when the scope tag name does not resolve to exactly one tag' {
        $root = Join-Path $TestDrive 'ScopeTagAmbiguous'
        New-FixtureCatalogApp -Root $root -ScopeTagName 'Managed Services'

        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            [pscustomobject]@{ id = 'intune-app-1'; installExperience = [pscustomobject]@{ runAsAccount = 'system'; deviceRestartBehavior = 'basedOnReturnCode' }; roleScopeTagIds = @() }
        } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection { @() } -ModuleName NSP.IntuneApps

        { Update-NSPIntuneWin32AppBuildProperties -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw '*No scope tag named*'
    }

    It 'throws when Graph returns an error payload for the PATCH without actually throwing' {
        $root = Join-Path $TestDrive 'ErrorPayload'
        New-FixtureCatalogApp -Root $root

        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            if ($Method -eq 'GET') {
                return [pscustomobject]@{ id = 'intune-app-1'; installExperience = [pscustomobject]@{ runAsAccount = 'user'; deviceRestartBehavior = 'suppress' }; roleScopeTagIds = @() }
            }
            [pscustomobject]@{ error = [pscustomobject]@{ code = 'BadRequest'; message = 'Rejected.' } }
        } -ModuleName NSP.IntuneApps

        { Update-NSPIntuneWin32AppBuildProperties -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false } |
            Should -Throw '*Graph rejected the build-properties PATCH*Rejected*'
    }

    It 'patches nothing under -WhatIf' {
        $root = Join-Path $TestDrive 'WhatIf'
        New-FixtureCatalogApp -Root $root

        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            if ($Method -eq 'GET') {
                return [pscustomobject]@{ id = 'intune-app-1'; installExperience = [pscustomobject]@{ runAsAccount = 'user'; deviceRestartBehavior = 'suppress' }; roleScopeTagIds = @() }
            }
            throw 'PATCH should not be called under -WhatIf'
        } -ModuleName NSP.IntuneApps

        $result = Update-NSPIntuneWin32AppBuildProperties -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -WhatIf
        $result | Should -BeNullOrEmpty
    }
}
