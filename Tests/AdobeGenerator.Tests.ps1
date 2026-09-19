Describe 'Adobe app generator' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
        $packageRoot = Join-Path $TestDrive 'AdobePackage'
        New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $packageRoot 'Setup.exe') -Value 'disposable Adobe setup placeholder'
    }

    It 'generates a self-contained unified app with hash-recorded payload and no endpoint Evergreen dependency' {
        $result = New-NSPAdobeApp -RepoRoot $repoRoot -PackageKind UnifiedBootstrapper -Architecture x64 -PackagePath $packageRoot -Version '25.1.2' -OutputRoot (Join-Path $TestDrive 'generated')
        $config = Get-Content -LiteralPath (Join-Path $result.Path 'Source\Adobe.config.json') -Raw | ConvertFrom-Json
        $install = Get-Content -LiteralPath (Join-Path $result.Path 'Source\Install-Adobe.ps1') -Raw
        $settings = Get-Content -LiteralPath $result.SettingsPath -Raw
        $config.PackageKind | Should -Be 'UnifiedBootstrapper'
        $config.Architecture | Should -Be 'x64'
        $config.PayloadManifest.Count | Should -Be 1
        $config.PayloadManifest[0].Sha256 | Should -Be (Get-FileHash -LiteralPath (Join-Path $packageRoot 'Setup.exe') -Algorithm SHA256).Hash
        $install | Should -Not -Match 'Install-Module|Get-EvergreenApp|PSGallery'
        $settings | Should -Match 'AssignmentColl = @\(\)'
    }

    It 'rejects a 32-bit unified package because the modern unified installer is 64-bit' {
        { New-NSPAdobeApp -RepoRoot $repoRoot -PackageKind UnifiedBootstrapper -Architecture x86 -PackagePath $packageRoot -OutputRoot (Join-Path $TestDrive 'invalid') } | Should -Throw
    }

    It 'requires an explicit installer when a package contains ambiguous setup executables' {
        $ambiguous = Join-Path $TestDrive 'AmbiguousAdobe'
        New-Item -ItemType Directory -Path (Join-Path $ambiguous 'one'),(Join-Path $ambiguous 'two') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $ambiguous 'one\Setup.exe') -Value one
        Set-Content -LiteralPath (Join-Path $ambiguous 'two\Setup.exe') -Value two
        { New-NSPAdobeApp -RepoRoot $repoRoot -PackageKind AdminConsole -PackagePath $ambiguous -OutputRoot (Join-Path $TestDrive 'ambiguous') } | Should -Throw
    }

    It 'does not reproduce the obsolete six-app edition and architecture matrix' {
        $readme = Get-Content -LiteralPath (Join-Path $repoRoot 'Templates\Adobe\README.md') -Raw
        $readme | Should -Match 'unified installation model'
        $readme | Should -Match 'Do not create separate Standard and Pro apps'
    }
}
