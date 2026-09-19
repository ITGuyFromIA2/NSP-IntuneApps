$repoRoot = Split-Path -Path $PSScriptRoot -Parent

Describe 'Parallels RAS Client repair contract' {
    BeforeAll {
        $sourcePath = Join-Path $repoRoot 'Apps\ParallelsClient\Source\DownloadInstall_ParallelsClient.ps1'
        $configPath = Join-Path $repoRoot 'Apps\ParallelsClient\Source\ParallelsConnection.config.psd1.example'
        $source = Get-Content -LiteralPath $sourcePath -Raw
        $config = Import-PowerShellDataFile -LiteralPath $configPath
    }

    It 'defaults to resolving the latest vendor installer at endpoint installation time' {
        $config.SourceMode | Should -Be 'Latest'
        $config.DownloadPageUri | Should -Be 'https://www.parallels.com/products/ras/download/client/'
        $source | Should -Match 'Get-ParallelsLatestMsiUri'
    }

    It 'supports validation and download without installation' {
        $source | Should -Match 'param\(\[switch\]\$DownloadOnly\)'
        $source | Should -Match 'if \(\$DownloadOnly\)'
    }

    It 'requires HTTPS, an MSI header, a valid signature, and an approved signer' {
        $source | Should -Match "Scheme -ne 'https'"
        $source | Should -Match 'compound-file header'
        $source | Should -Match "Status -ne 'Valid'"
        $source | Should -Match 'ExpectedSignerPattern'
    }

    It 'permits pinning only with an explicit URI and SHA-256' {
        $source | Should -Match 'SourceMode must be Latest or Pinned'
        $source | Should -Match 'PinnedMsiUri'
        $source | Should -Match 'PinnedSha256'
        $source | Should -Match '64-character PinnedSha256'
    }

    It 'uses shared-device mode 1 and contains no shared credentials' {
        $source | Should -Match 'SHAREDDEVICE=`"1:import:'
        $source | Should -Not -Match 'SHAREDDEVICE=`"2:'
        $source | Should -Match '<Password dt:dt="string"/>'
        $source | Should -Match '<UserName dt:dt="string"/>'
    }
}
