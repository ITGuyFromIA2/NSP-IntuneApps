Describe 'FortiClient SuperScript generator' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force

        $superScriptDir = Join-Path $TestDrive 'SuperScriptSource'
        New-Item -ItemType Directory -Path $superScriptDir -Force | Out-Null
        $script:superScriptPath = Join-Path $superScriptDir 'CONTOSO_FortiClient_Upgrade.ps1'
        Set-Content -LiteralPath $script:superScriptPath -Value "param([string]`$Mode)`n`$SuperScriptBuiltUtc = '2026-10-01T00:00:00Z'`nWrite-Host `$Mode" -Encoding UTF8
        foreach ($abbrev in 'CONTOSO', 'DUPTEST', 'WHATIF') {
            Set-Content -LiteralPath (Join-Path $superScriptDir "Detect_${abbrev}_FortiClientVPN.ps1") -Value "`$SuperScriptBuiltUtc = '2026-10-01T00:00:00Z'`nWrite-Output 'Detected'" -Encoding UTF8
        }
    }

    It 'copies the superscript, writes install/uninstall mode-dispatch wrappers, and uses the companion detection script' {
        $result = New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -ClientAbbrev 'CONTOSO' -OutputRoot $TestDrive

        $result.Id | Should -Be 'FortiClient-CONTOSO'
        Test-Path -LiteralPath (Join-Path $result.Path 'Source\CONTOSO_FortiClient_Upgrade.ps1') | Should -BeTrue
        Test-Path -LiteralPath $result.SettingsPath | Should -BeTrue

        $deploy = Get-Content -LiteralPath (Join-Path $result.Path 'Source\DownloadInstall_FortiClient-CONTOSO.ps1') -Raw
        $deploy | Should -Match '-Mode IntuneDeploy'
        $deploy | Should -Match '\$LASTEXITCODE'

        $uninstall = Get-Content -LiteralPath (Join-Path $result.Path 'Source\Uninstall_FortiClient-CONTOSO.ps1') -Raw
        $uninstall | Should -Match '-Mode IntuneUninstall'

        $detectFiles = @(Get-ChildItem -LiteralPath (Join-Path $result.Path 'Detect') -File)
        $detectFiles.Name | Should -Be @('Detect_CONTOSO_FortiClientVPN.ps1')
        Get-Content -LiteralPath $detectFiles[0].FullName -Raw | Should -Not -Match 'PSScriptRoot'
    }

    It 'finds the companion detection script in a staged INTUNE-FortiClient-<Abbrev>\Detect folder' {
        $dir = Join-Path $TestDrive 'StagedLayout'
        $detectDir = Join-Path $dir 'INTUNE-FortiClient-STAGED\Detect'
        New-Item -ItemType Directory -Path $detectDir -Force | Out-Null
        Copy-Item -LiteralPath $script:superScriptPath -Destination (Join-Path $dir 'STAGED_FortiClient_Upgrade.ps1')
        Set-Content -LiteralPath (Join-Path $detectDir 'Detect_STAGED_FortiClientVPN.ps1') -Value "`$SuperScriptBuiltUtc = '2026-10-01T00:00:00Z'" -Encoding UTF8

        $result = New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath (Join-Path $dir 'STAGED_FortiClient_Upgrade.ps1') -ClientAbbrev 'STAGED' -OutputRoot (Join-Path $TestDrive 'StagedOut')

        Test-Path -LiteralPath (Join-Path $result.Path 'Detect\Detect_STAGED_FortiClientVPN.ps1') | Should -BeTrue
    }

    It 'throws when no companion detection script can be found' {
        { New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -ClientAbbrev 'NODETECT' -OutputRoot $TestDrive } | Should -Throw '*Companion detection script*'
    }

    It 'throws when the detection script is from a different build than the superscript' {
        $staleDetect = Join-Path $TestDrive 'Detect_Stale.ps1'
        Set-Content -LiteralPath $staleDetect -Value "`$SuperScriptBuiltUtc = '2026-09-01T00:00:00Z'" -Encoding UTF8
        { New-NSPFortiClientSuperScriptApp -RepoRoot $repoRoot -SuperScriptPath $script:superScriptPath -DetectScriptPath $staleDetect -ClientAbbrev 'CONTOSO' -OutputRoot $TestDrive -Force } | Should -Throw '*same build*'
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
