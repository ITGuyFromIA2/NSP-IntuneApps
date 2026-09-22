Describe 'Resolve-NSPAppBuildPlan' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force

        function New-FixtureApp {
            param(
                [string]$Root,
                [string]$SetupFileName = 'DownloadInstall_Fixture.ps1',
                [string]$UninstallFileName = 'Uninstall_Fixture.ps1',
                [string]$DetectFileName = 'Detect_Fixture.ps1',
                [switch]$WithPngIcon
            )
            New-Item -ItemType Directory -Path (Join-Path $Root 'Source') -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $Root 'Detect') -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $Root "Source\$SetupFileName") -Value '# setup'
            Set-Content -LiteralPath (Join-Path $Root "Source\$UninstallFileName") -Value '# uninstall'
            Set-Content -LiteralPath (Join-Path $Root "Detect\$DetectFileName") -Value '# detect'
            if ($WithPngIcon) {
                Set-Content -LiteralPath (Join-Path $Root 'icon.png') -Value 'fake-png'
            }
        }
    }

    It 'derives install/uninstall command lines using bare file names, not build-machine paths' {
        $root = Join-Path $TestDrive 'Basic'
        New-FixtureApp -Root $root
        $config = @{
            SetupType = 'PoSH'; DetectionStyle = 'Script'
            SetupFile_Filter = 'DownloadInstall_*.ps1'
            DetectScript_Filter = 'Detect_*.ps1'
            PoSH = @{ UninstallFile_Filter = 'Uninstall_*.ps1' }
            EnforceSignature_Detection = $true; RunAs32Bit_Detection = $false
            REQ_Architecture = 'All'; REQ_MinWindowsRelase = 'W10_1607'
        }

        $plan = InModuleScope NSP.IntuneApps -Parameters @{ root = $root; config = $config } {
            param($root, $config)
            Resolve-NSPAppBuildPlan -Name 'Fixture' -SettingsPath (Join-Path $root 'Fixture_SplitScriptSettings.ps1') -Path $root -VariableConfig $config
        }

        $plan.InstallCommandLine | Should -Be 'PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "DownloadInstall_Fixture.ps1"'
        $plan.UninstallCommandLine | Should -Be 'PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "Uninstall_Fixture.ps1"'
        $plan.DetectionScriptPath | Should -Be (Join-Path $root 'Detect\Detect_Fixture.ps1')
        $plan.RequirementArchitecture | Should -Be 'All'
        $plan.RequirementMinimumWindowsRelease | Should -Be 'W10_1607'
        $plan.IconPath | Should -Be $null
    }

    It 'falls back to the older Filter_DetectScript key when DetectScript_Filter is absent' {
        $root = Join-Path $TestDrive 'LegacyDetectKey'
        New-FixtureApp -Root $root
        $config = @{
            SetupType = 'PoSH'; DetectionStyle = 'Script'
            SetupFile_Filter = 'DownloadInstall_*.ps1'
            Filter_DetectScript = 'Detect_*.ps1'
            PoSH = @{ UninstallFile_Filter = 'Uninstall_*.ps1' }
            REQ_Architecture = 'All'; REQ_MinWindowsRelase = 'W10_1607'
        }

        $plan = InModuleScope NSP.IntuneApps -Parameters @{ root = $root; config = $config } {
            param($root, $config)
            Resolve-NSPAppBuildPlan -Name 'Fixture' -SettingsPath (Join-Path $root 'Fixture_SplitScriptSettings.ps1') -Path $root -VariableConfig $config
        }

        $plan.DetectionScriptPath | Should -Be (Join-Path $root 'Detect\Detect_Fixture.ps1')
    }

    It 'appends PoSH.Args_String when PoSH.Args is set' {
        $root = Join-Path $TestDrive 'WithArgs'
        New-FixtureApp -Root $root
        $config = @{
            SetupType = 'PoSH'; DetectionStyle = 'Script'
            SetupFile_Filter = 'DownloadInstall_*.ps1'
            DetectScript_Filter = 'Detect_*.ps1'
            PoSH = @{ UninstallFile_Filter = 'Uninstall_*.ps1'; Args = $true; Args_String = '-Silent' }
            REQ_Architecture = 'All'; REQ_MinWindowsRelase = 'W10_1607'
        }

        $plan = InModuleScope NSP.IntuneApps -Parameters @{ root = $root; config = $config } {
            param($root, $config)
            Resolve-NSPAppBuildPlan -Name 'Fixture' -SettingsPath (Join-Path $root 'Fixture_SplitScriptSettings.ps1') -Path $root -VariableConfig $config
        }

        $plan.InstallCommandLine | Should -Be 'PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "DownloadInstall_Fixture.ps1" -Silent'
        $plan.UninstallCommandLine | Should -Be 'PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "Uninstall_Fixture.ps1" -Silent'
    }

    It 'prefers a configured ImagePath that exists over the *.png fallback' {
        $root = Join-Path $TestDrive 'ConfiguredIcon'
        New-FixtureApp -Root $root -WithPngIcon
        $explicitIcon = Join-Path $root 'explicit-icon.png'
        Set-Content -LiteralPath $explicitIcon -Value 'fake-png'
        $config = @{
            SetupType = 'PoSH'; DetectionStyle = 'Script'
            SetupFile_Filter = 'DownloadInstall_*.ps1'
            DetectScript_Filter = 'Detect_*.ps1'
            PoSH = @{ UninstallFile_Filter = 'Uninstall_*.ps1' }
            REQ_Architecture = 'All'; REQ_MinWindowsRelase = 'W10_1607'
            ImagePath = $explicitIcon
        }

        $plan = InModuleScope NSP.IntuneApps -Parameters @{ root = $root; config = $config } {
            param($root, $config)
            Resolve-NSPAppBuildPlan -Name 'Fixture' -SettingsPath (Join-Path $root 'Fixture_SplitScriptSettings.ps1') -Path $root -VariableConfig $config
        }

        $plan.IconPath | Should -Be $explicitIcon
    }

    It 'falls back to the first root-level *.png when ImagePath is unset' {
        $root = Join-Path $TestDrive 'FallbackIcon'
        New-FixtureApp -Root $root -WithPngIcon
        $config = @{
            SetupType = 'PoSH'; DetectionStyle = 'Script'
            SetupFile_Filter = 'DownloadInstall_*.ps1'
            DetectScript_Filter = 'Detect_*.ps1'
            PoSH = @{ UninstallFile_Filter = 'Uninstall_*.ps1' }
            REQ_Architecture = 'All'; REQ_MinWindowsRelase = 'W10_1607'
        }

        $plan = InModuleScope NSP.IntuneApps -Parameters @{ root = $root; config = $config } {
            param($root, $config)
            Resolve-NSPAppBuildPlan -Name 'Fixture' -SettingsPath (Join-Path $root 'Fixture_SplitScriptSettings.ps1') -Path $root -VariableConfig $config
        }

        $plan.IconPath | Should -Be (Join-Path $root 'icon.png')
    }

    It 'falls back to $null when ImagePath is missing and no *.png exists' {
        $root = Join-Path $TestDrive 'NoIcon'
        New-FixtureApp -Root $root
        $config = @{
            SetupType = 'PoSH'; DetectionStyle = 'Script'
            SetupFile_Filter = 'DownloadInstall_*.ps1'
            DetectScript_Filter = 'Detect_*.ps1'
            PoSH = @{ UninstallFile_Filter = 'Uninstall_*.ps1' }
            REQ_Architecture = 'All'; REQ_MinWindowsRelase = 'W10_1607'
            ImagePath = (Join-Path $root 'missing.png')
        }

        $plan = InModuleScope NSP.IntuneApps -Parameters @{ root = $root; config = $config } {
            param($root, $config)
            Resolve-NSPAppBuildPlan -Name 'Fixture' -SettingsPath (Join-Path $root 'Fixture_SplitScriptSettings.ps1') -Path $root -VariableConfig $config
        }

        $plan.IconPath | Should -Be $null
    }

    It 'throws clearly for a SetupType this resolver does not implement' {
        $root = Join-Path $TestDrive 'UnsupportedSetupType'
        New-FixtureApp -Root $root
        $config = @{ SetupType = 'PoSH_sysnative'; DetectionStyle = 'Script' }

        { InModuleScope NSP.IntuneApps -Parameters @{ root = $root; config = $config } {
                param($root, $config)
                Resolve-NSPAppBuildPlan -Name 'Fixture' -SettingsPath (Join-Path $root 'Fixture_SplitScriptSettings.ps1') -Path $root -VariableConfig $config
            } } | Should -Throw '*does not yet support*'
    }

    It 'throws clearly for a DetectionStyle this resolver does not implement' {
        $root = Join-Path $TestDrive 'UnsupportedDetectionStyle'
        New-FixtureApp -Root $root
        $config = @{ SetupType = 'PoSH'; DetectionStyle = 'Registry_Exist' }

        { InModuleScope NSP.IntuneApps -Parameters @{ root = $root; config = $config } {
                param($root, $config)
                Resolve-NSPAppBuildPlan -Name 'Fixture' -SettingsPath (Join-Path $root 'Fixture_SplitScriptSettings.ps1') -Path $root -VariableConfig $config
            } } | Should -Throw '*does not yet support*'
    }

    It 'throws when more than one file matches the setup filter' {
        $root = Join-Path $TestDrive 'AmbiguousSetup'
        New-FixtureApp -Root $root
        Set-Content -LiteralPath (Join-Path $root 'Source\DownloadInstall_Other.ps1') -Value '# setup 2'
        $config = @{
            SetupType = 'PoSH'; DetectionStyle = 'Script'
            SetupFile_Filter = 'DownloadInstall_*.ps1'
            DetectScript_Filter = 'Detect_*.ps1'
            PoSH = @{ UninstallFile_Filter = 'Uninstall_*.ps1' }
            REQ_Architecture = 'All'; REQ_MinWindowsRelase = 'W10_1607'
        }

        { InModuleScope NSP.IntuneApps -Parameters @{ root = $root; config = $config } {
                param($root, $config)
                Resolve-NSPAppBuildPlan -Name 'Fixture' -SettingsPath (Join-Path $root 'Fixture_SplitScriptSettings.ps1') -Path $root -VariableConfig $config
            } } | Should -Throw '*expected exactly one setup file*'
    }
}
