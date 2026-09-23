Describe 'Parallels RAS Client configuration generator' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
    }

    It 'creates a self-contained connection app without modifying the reference implementation' {
        $detectHashBefore = (Get-FileHash -LiteralPath (Join-Path $repoRoot 'Apps\ParallelsClient\Detect\Detect_ParallelsClient.ps1') -Algorithm SHA256).Hash
        $installHashBefore = (Get-FileHash -LiteralPath (Join-Path $repoRoot 'Apps\ParallelsClient\Source\DownloadInstall_ParallelsClient.ps1') -Algorithm SHA256).Hash

        $result = New-NSPParallelsClientApp -RepoRoot $repoRoot -Alias 'Example RAS' -Server 'ras.example.invalid' -Port 443 -OutputRoot $TestDrive

        Test-Path -LiteralPath $result.SettingsPath | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $result.Path 'Detect\Detect_ParallelsClient.ps1') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $result.Path 'Source\Uninstall_ParallelsClient.ps1') | Should -BeTrue

        $config = Import-PowerShellDataFile -LiteralPath (Join-Path $result.Path 'Source\ParallelsConnection.config.psd1')
        $config.Alias | Should -Be 'Example RAS'
        $config.Server | Should -Be 'ras.example.invalid'
        $config.Port | Should -Be 443
        $config.SourceMode | Should -Be 'Latest'
        [string]$config.Alias | Should -Not -Match '^REPLACE_WITH_'

        $detectHashAfter = (Get-FileHash -LiteralPath (Join-Path $result.Path 'Detect\Detect_ParallelsClient.ps1') -Algorithm SHA256).Hash
        $detectHashAfter | Should -Be $detectHashBefore

        (Get-FileHash -LiteralPath (Join-Path $repoRoot 'Apps\ParallelsClient\Detect\Detect_ParallelsClient.ps1') -Algorithm SHA256).Hash | Should -Be $detectHashBefore
        (Get-FileHash -LiteralPath (Join-Path $repoRoot 'Apps\ParallelsClient\Source\DownloadInstall_ParallelsClient.ps1') -Algorithm SHA256).Hash | Should -Be $installHashBefore
    }

    It 'writes PinnedMsiUri/PinnedSha256 when SourceMode is Pinned' {
        $sha = '0' * 64
        $result = New-NSPParallelsClientApp -RepoRoot $repoRoot -Alias 'Pinned RAS' -Server 'ras.example.invalid' -SourceMode Pinned -PinnedMsiUri 'https://download.parallels.com/ras/x/RASClient-x64.msi' -PinnedSha256 $sha -OutputRoot $TestDrive

        $config = Import-PowerShellDataFile -LiteralPath (Join-Path $result.Path 'Source\ParallelsConnection.config.psd1')
        $config.SourceMode | Should -Be 'Pinned'
        $config.PinnedMsiUri | Should -Be 'https://download.parallels.com/ras/x/RASClient-x64.msi'
        $config.PinnedSha256 | Should -Be $sha
    }

    It 'requires PinnedMsiUri and PinnedSha256 when SourceMode is Pinned' {
        { New-NSPParallelsClientApp -RepoRoot $repoRoot -Alias 'Missing Pin' -Server 'ras.example.invalid' -SourceMode Pinned -OutputRoot $TestDrive } | Should -Throw '*PinnedMsiUri is required*'
    }

    It 'rejects a malformed PinnedSha256' {
        { New-NSPParallelsClientApp -RepoRoot $repoRoot -Alias 'Bad Hash' -Server 'ras.example.invalid' -SourceMode Pinned -PinnedMsiUri 'https://download.parallels.com/x.msi' -PinnedSha256 'not-a-hash' -OutputRoot $TestDrive } | Should -Throw '*64-character hexadecimal SHA-256*'
    }

    It 'rejects aliases that can break the settings file or config' {
        { New-NSPParallelsClientApp -RepoRoot $repoRoot -Alias 'Bad]Alias' -Server 'ras.example.invalid' -OutputRoot $TestDrive } | Should -Throw '*cannot contain*'
    }

    It 'rejects an out-of-range port' {
        { New-NSPParallelsClientApp -RepoRoot $repoRoot -Alias 'Bad Port' -Server 'ras.example.invalid' -Port 70000 -OutputRoot $TestDrive } | Should -Throw '*Port must be between*'
    }

    It 'requires Force to overwrite an existing destination' {
        New-NSPParallelsClientApp -RepoRoot $repoRoot -Alias 'Dup RAS' -Server 'ras.example.invalid' -OutputRoot $TestDrive | Out-Null
        { New-NSPParallelsClientApp -RepoRoot $repoRoot -Alias 'Dup RAS' -Server 'ras.example.invalid' -OutputRoot $TestDrive } | Should -Throw '*already exists*'
    }
}
