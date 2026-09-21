Describe 'Disposable test environment contract' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
    }

    It 'ships a VM runbook with clean checkpoint, Defender, Parallels, and interactive-installer checks' {
        $runbook = Get-Content -LiteralPath (Join-Path $repoRoot 'docs\TestVM.md') -Raw
        $runbook | Should -Match 'clean checkpoint'
        $runbook | Should -Match 'Microsoft Defender'
        $runbook | Should -Match 'latest-by-default'
        $runbook | Should -Match 'interpreted `\.au3`'
        $runbook | Should -Match 'compiled `\.exe`'
    }

    It 'keeps generated VM and Sandbox evidence out of source control' {
        $ignore = Get-Content -LiteralPath (Join-Path $repoRoot '.gitignore')
        $ignore | Should -Contain 'Config/Local/'
    }

    It 'generates an offline Sandbox configuration by default with a read-only repository mapping' {
        $generator = Get-Content -LiteralPath (Join-Path $repoRoot 'tools\Sandbox\New-NSPWindowsSandboxFile.ps1') -Raw
        $generator | Should -Match "\[string\]\`$Mode = 'Offline'"
        $generator | Should -Match '<ReadOnly>true</ReadOnly>'
        $generator | Should -Match "if \(\`$Mode -eq 'Networked'\)"
    }

    It 'does not disable Defender policy in the VM helper scripts' {
        $source = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'tools\VM') -Filter '*.ps1' -File |
            ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
        $source | Should -Not -Match 'Set-MpPreference'
        $source | Should -Not -Match 'Add-MpPreference'
        $source | Should -Match '-DisableRemediation'
    }
}

