Describe 'Vendor dependency procurement' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
    }

    It 'retrieves Bitdefender wrapper from the official host and validates its signature' {
        $install = Get-Content -LiteralPath (Join-Path $repoRoot 'Apps\BitDefender\Source\DownloadInstall_BEST.ps1') -Raw
        $install | Should -Match 'https://download\.bitdefender\.com/'
        $install | Should -Match 'Get-AuthenticodeSignature'
        $install | Should -Match "Status -ne 'Valid'"
        $install | Should -Match 'Bitdefender'
    }

    It 'does not redistribute SetACL and pins the reviewed publisher archive' {
        $helperPath = Join-Path $repoRoot 'Apps\DelegateService\Source\Get-NSPSetAcl.ps1'
        $helper = Get-Content -LiteralPath $helperPath -Raw
        $helper | Should -Match 'https://helgeklein\.com/files/SetACL/current/'
        $helper | Should -Match 'BA74399A70963C156580180455FBFC0FA68EA673A64EB89010A46273C7D478CC'
        $helper | Should -Not -Match 'REPLACE_AFTER_VM_VALIDATION'
        $helper | Should -Match '\$AuditOnly'
        $helper | Should -Match 'MaximumRedirection 0'
        $helper | Should -Match 'unsafe path'
        $helper | Should -Match 'exactly two SetACL executables'
        @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'Apps\DelegateService') -Recurse -File |
            Where-Object Extension -in @('.exe','.zip')).Count | Should -Be 0
    }

    It 'does not reintroduce ServiceUI into active app source' {
        $activeSource = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'Apps') -Recurse -File |
            Where-Object { $_.Extension -in @('.ps1','.psd1','.json') }
        @($activeSource | Select-String -Pattern 'ServiceUI\.exe').Count | Should -Be 0
    }

    It 'documents MDT retirement instead of silently procuring ServiceUI' {
        $policy = Get-Content -LiteralPath (Join-Path $repoRoot 'docs\VendorDependencyPolicy.md') -Raw
        $policy | Should -Match 'retired the Microsoft Deployment Toolkit'
        $policy | Should -Match 'no active package depends on it'
    }
}
