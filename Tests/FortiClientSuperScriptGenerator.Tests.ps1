Describe 'FortiClient SuperScript generator' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force

        $superScriptDir = Join-Path $TestDrive 'SuperScriptSource'
        New-Item -ItemType Directory -Path $superScriptDir -Force | Out-Null
        $script:superScriptPath = Join-Path $superScriptDir 'CONTOSO_FortiClient_Upgrade.ps1'
        Set-Content -LiteralPath $script:superScriptPath -Value "param([string]`$Mode)`nWrite-Host `$Mode" -Encoding UTF8
    }

    It 'copies the superscript and writes three one-line mode-dispatch wrappers' {
        $result = New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -ClientAbbrev 'CONTOSO' -OutputRoot $TestDrive

        $result.Id | Should -Be 'FortiClient-CONTOSO'
        Test-Path -LiteralPath (Join-Path $result.Path 'Source\CONTOSO_FortiClient_Upgrade.ps1') | Should -BeTrue
        Test-Path -LiteralPath $result.SettingsPath | Should -BeTrue

        $deploy = Get-Content -LiteralPath (Join-Path $result.Path 'Source\DownloadInstall_FortiClient-CONTOSO.ps1') -Raw
        $deploy | Should -Match '-Mode IntuneDeploy'
        $deploy | Should -Match '\$LASTEXITCODE'

        $uninstall = Get-Content -LiteralPath (Join-Path $result.Path 'Source\Uninstall_FortiClient-CONTOSO.ps1') -Raw
        $uninstall | Should -Match '-Mode IntuneUninstall'

        $detect = Get-Content -LiteralPath (Join-Path $result.Path 'Detect\Detect_FortiClient-CONTOSO.ps1') -Raw
        $detect | Should -Match '-Mode IntuneDetect'
    }

    It 'defaults DisplayName from ClientAbbrev and writes PoSH_sysnative settings (WOW64 registry concern)' {
        $result = New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -ClientAbbrev 'CONTOSO' -OutputRoot $TestDrive -Force

        $settings = Get-Content -LiteralPath $result.SettingsPath -Raw
        $settings | Should -Match "DisplayName = 'FortiClient - CONTOSO'"
        $settings | Should -Match "SetupType = 'PoSH_sysnative'"
        $settings | Should -Match "RestartExperience = 'basedOnReturnCode'"
        $settings | Should -Match 'RunAs32Bit_Detection = \$false'
        $settings | Should -Match 'AssignmentColl = @\(\)'
    }

    It 'honors an explicit DisplayName' {
        $result = New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -ClientAbbrev 'CONTOSO' -DisplayName 'FortiClient - Contoso Corp' -OutputRoot $TestDrive -Force

        Get-Content -LiteralPath $result.SettingsPath -Raw | Should -Match "DisplayName = 'FortiClient - Contoso Corp'"
    }

    It 'rejects a client abbreviation with unsafe characters' {
        { New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -ClientAbbrev 'CON/TOSO' -OutputRoot $TestDrive } | Should -Throw '*letters, digits, underscore, and hyphen*'
    }

    It 'throws when the superscript path does not exist' {
        { New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath (Join-Path $TestDrive 'missing.ps1') -ClientAbbrev 'CONTOSO' -OutputRoot $TestDrive } | Should -Throw '*SuperScript not found*'
    }

    It 'refuses to overwrite an existing destination without -Force' {
        New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -ClientAbbrev 'DUPTEST' -OutputRoot $TestDrive | Out-Null
        { New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -ClientAbbrev 'DUPTEST' -OutputRoot $TestDrive } | Should -Throw '*already exists*'
    }

    It 'creates nothing under -WhatIf' {
        $target = Join-Path $TestDrive 'FortiClient-WHATIF'
        New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -ClientAbbrev 'WHATIF' -OutputRoot $TestDrive -WhatIf | Out-Null
        Test-Path -LiteralPath $target | Should -BeFalse
    }
}
