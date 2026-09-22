$script:intuneWin32AppAvailable = [bool](Get-Module -ListAvailable IntuneWin32App)

Describe 'New-NSPAppPackage' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
        if ($script:intuneWin32AppAvailable) { Import-Module IntuneWin32App -Force }

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

    It 'builds the package into the default per-app Build output path' -Skip:(-not $script:intuneWin32AppAvailable) {
        $repoRoot = Join-Path $TestDrive 'DefaultOutput'
        New-FixtureRepo -Root $repoRoot
        $expectedOutput = Join-Path $repoRoot 'Config\Local\Build\Fixture'
        $expectedSourceFolder = Join-Path $repoRoot 'Apps\Fixture\Source'

        Mock New-IntuneWin32AppPackage {
            $packagePath = Join-Path $OutputFolder 'DownloadInstall_Fixture.intunewin'
            New-Item -ItemType File -Path $packagePath -Force | Out-Null
            [pscustomobject]@{ Name = 'Fixture'; FileName = 'DownloadInstall_Fixture.intunewin'; Path = $packagePath }
        } -ModuleName NSP.IntuneApps
        Mock Get-IntuneWin32AppMetaData { [pscustomobject]@{ ApplicationInfo = [pscustomobject]@{ Name = 'Fixture' } } } -ModuleName NSP.IntuneApps

        $result = New-NSPAppPackage -RepoRoot $repoRoot -AppName 'Fixture' -Confirm:$false

        $result.AppName | Should -Be 'Fixture'
        $result.PackagePath | Should -Be (Join-Path $expectedOutput 'DownloadInstall_Fixture.intunewin')
        $result.BuildPlan.SourceFolder | Should -Be $expectedSourceFolder
        $result.BuildPlan.SetupFileName | Should -Be 'DownloadInstall_Fixture.ps1'
        Test-Path -LiteralPath $expectedOutput | Should -BeTrue
        Should -Invoke New-IntuneWin32AppPackage -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $SourceFolder -eq $expectedSourceFolder -and $SetupFile -eq 'DownloadInstall_Fixture.ps1' -and $OutputFolder -eq $expectedOutput
        }
    }

    It 'honors an explicit OutputPath instead of the default' -Skip:(-not $script:intuneWin32AppAvailable) {
        $repoRoot = Join-Path $TestDrive 'CustomOutput'
        New-FixtureRepo -Root $repoRoot
        $customOutput = Join-Path $TestDrive 'CustomOutput\Elsewhere'

        Mock New-IntuneWin32AppPackage {
            $packagePath = Join-Path $OutputFolder 'DownloadInstall_Fixture.intunewin'
            New-Item -ItemType File -Path $packagePath -Force | Out-Null
            [pscustomobject]@{ Name = 'Fixture'; FileName = 'DownloadInstall_Fixture.intunewin'; Path = $packagePath }
        } -ModuleName NSP.IntuneApps
        Mock Get-IntuneWin32AppMetaData { [pscustomobject]@{ ApplicationInfo = [pscustomobject]@{ Name = 'Fixture' } } } -ModuleName NSP.IntuneApps

        $result = New-NSPAppPackage -RepoRoot $repoRoot -AppName 'Fixture' -OutputPath $customOutput -Confirm:$false

        $result.PackagePath | Should -Be (Join-Path $customOutput 'DownloadInstall_Fixture.intunewin')
        Test-Path -LiteralPath $customOutput | Should -BeTrue
    }

    It 'does not build or touch the output folder under WhatIf' -Skip:(-not $script:intuneWin32AppAvailable) {
        $repoRoot = Join-Path $TestDrive 'WhatIfOutput'
        New-FixtureRepo -Root $repoRoot
        $expectedOutput = Join-Path $repoRoot 'Config\Local\Build\Fixture'

        Mock New-IntuneWin32AppPackage { throw 'should not be called' } -ModuleName NSP.IntuneApps

        New-NSPAppPackage -RepoRoot $repoRoot -AppName 'Fixture' -WhatIf | Should -BeNullOrEmpty
        Test-Path -LiteralPath $expectedOutput | Should -BeFalse
        Should -Invoke New-IntuneWin32AppPackage -Times 0 -ModuleName NSP.IntuneApps
    }

    It 'throws clearly when packaging fails to produce a result' -Skip:(-not $script:intuneWin32AppAvailable) {
        $repoRoot = Join-Path $TestDrive 'PackagingFailure'
        New-FixtureRepo -Root $repoRoot

        Mock New-IntuneWin32AppPackage { $null } -ModuleName NSP.IntuneApps

        { New-NSPAppPackage -RepoRoot $repoRoot -AppName 'Fixture' -Confirm:$false } | Should -Throw '*Packaging failed*'
    }
}
