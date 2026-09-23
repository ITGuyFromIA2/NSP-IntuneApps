$script:intuneWin32AppAvailable = [bool](Get-Module -ListAvailable IntuneWin32App)

Describe 'Update-NSPIntuneWin32AppMetadata' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
        if ($script:intuneWin32AppAvailable) { Import-Module IntuneWin32App -Force }

        function New-FixtureCatalogApp {
            param([string]$Root, [string]$DisplayName = 'Fixture App', [bool]$IsFeatured = $false)
            $appRoot = Join-Path $Root 'Apps\Fixture'
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Source') -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Detect') -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\DownloadInstall_Fixture.ps1') -Value '# setup'
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\Uninstall_Fixture.ps1') -Value '# uninstall'
            Set-Content -LiteralPath (Join-Path $appRoot 'Detect\Detect_Fixture.ps1') -Value '# detect'
            $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = '$DisplayName'
`$VariableConfig.Description = 'Fixture description.'
`$VariableConfig.Publisher = 'Fixture Publisher'
`$VariableConfig.IsFeatured = `$$IsFeatured
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
"@
            Set-Content -LiteralPath (Join-Path $appRoot 'Fixture_SplitScriptSettings.ps1') -Value $settings
        }
    }

    It 'reports a plan without connecting to any tenant when -Execute is not passed' {
        $root = Join-Path $TestDrive 'PlanOnly'
        New-FixtureCatalogApp -Root $root

        $result = Update-NSPIntuneWin32AppMetadata -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.Fields.DisplayName | Should -Be 'Fixture App'
        $result.Message | Should -Match 'not covered by this PATCH'
    }

    It 'throws when the app is not in the catalog' {
        $root = Join-Path $TestDrive 'NoCatalog'
        New-Item -ItemType Directory -Path (Join-Path $root 'Apps') -Force | Out-Null

        { Update-NSPIntuneWin32AppMetadata -RepoRoot $root -AppName 'Missing' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw '*was not found in the catalog*'
    }

    It 'PATCHes DisplayName, Description, Publisher, and the featured flag from the settings file' -Skip:(-not $script:intuneWin32AppAvailable) {
        $root = Join-Path $TestDrive 'Patch'
        New-FixtureCatalogApp -Root $root -DisplayName 'Updated Fixture Name' -IsFeatured $true

        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Set-IntuneWin32App { } -ModuleName NSP.IntuneApps

        $result = Update-NSPIntuneWin32AppMetadata -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Updated'
        Should -Invoke Set-IntuneWin32App -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $ID -eq 'intune-app-1' -and $DisplayName -eq 'Updated Fixture Name' -and $Publisher -eq 'Fixture Publisher' -and $CompanyPortalFeaturedApp -eq $true
        }
    }

    It 'PATCHes optional Company Portal metadata only when the settings file sets it' -Skip:(-not $script:intuneWin32AppAvailable) {
        $root = Join-Path $TestDrive 'OptionalMetadata'
        New-FixtureCatalogApp -Root $root
        Add-Content -LiteralPath (Join-Path $root 'Apps\Fixture\Fixture_SplitScriptSettings.ps1') -Value @'
$VariableConfig.Developer = 'Network Systems Plus, Inc.'
$VariableConfig.Owner = 'NSP Managed Services'
$VariableConfig.InformationURL = 'https://example.invalid/info'
$VariableConfig.PrivacyURL = 'https://example.invalid/privacy'
$VariableConfig.AppVersion = '2.1.0'
$VariableConfig.AllowAvailableUninstall = $true
'@

        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Set-IntuneWin32App { } -ModuleName NSP.IntuneApps

        Update-NSPIntuneWin32AppMetadata -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false | Out-Null

        Should -Invoke Set-IntuneWin32App -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Developer -eq 'Network Systems Plus, Inc.' -and $Owner -eq 'NSP Managed Services' -and
            $InformationURL -eq 'https://example.invalid/info' -and $PrivacyURL -eq 'https://example.invalid/privacy' -and
            $AppVersion -eq '2.1.0' -and $AllowAvailableUninstall -eq $true -and -not $PSBoundParameters.ContainsKey('Notes')
        }
    }

    It 'omits the optional Company Portal fields when the settings file does not set them, preserving today''s behavior' -Skip:(-not $script:intuneWin32AppAvailable) {
        $root = Join-Path $TestDrive 'NoOptionalMetadata'
        New-FixtureCatalogApp -Root $root

        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Set-IntuneWin32App { } -ModuleName NSP.IntuneApps

        Update-NSPIntuneWin32AppMetadata -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false | Out-Null

        Should -Invoke Set-IntuneWin32App -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            -not $PSBoundParameters.ContainsKey('Developer') -and -not $PSBoundParameters.ContainsKey('AppVersion')
        }
    }

    It 'PATCHes nothing under -WhatIf' -Skip:(-not $script:intuneWin32AppAvailable) {
        $root = Join-Path $TestDrive 'WhatIf'
        New-FixtureCatalogApp -Root $root

        Mock Connect-MSIntuneGraph { throw 'should not be called' } -ModuleName NSP.IntuneApps
        Mock Set-IntuneWin32App { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $result = Update-NSPIntuneWin32AppMetadata -RepoRoot $root -AppName 'Fixture' -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -WhatIf
        $result | Should -BeNullOrEmpty
    }
}
