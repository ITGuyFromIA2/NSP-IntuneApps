Describe 'Shortcut generator' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
    }

    It 'generates a default-browser web shortcut app' {
        $result = New-NSPShortcutApp -RepoRoot $repoRoot -Mode WebDefault -Name 'Example Portal' -Target 'https://portal.example.invalid' -OutputRoot $TestDrive
        $config = Get-Content -LiteralPath (Join-Path $result.Path 'Source\Shortcut.config.json') -Raw | ConvertFrom-Json
        $config.Mode | Should -Be 'WebDefault'
        $config.FileName | Should -Be 'Example Portal.url'
        $config.Target | Should -Be 'https://portal.example.invalid/'
        Test-Path -LiteralPath (Join-Path $result.Path 'Detect\Detect-Shortcut.ps1') | Should -BeTrue
    }

    It 'keeps a browser executable separate from its URL argument' {
        $result = New-NSPShortcutApp -RepoRoot $repoRoot -Mode WebBrowser -Browser Edge -Name 'Edge Portal' -Target 'https://portal.example.invalid/path' -OutputRoot $TestDrive
        $config = Get-Content -LiteralPath (Join-Path $result.Path 'Source\Shortcut.config.json') -Raw | ConvertFrom-Json
        $config.Browser | Should -Be 'Edge'
        $config.Target | Should -Be 'https://portal.example.invalid/path'
        (Get-Content -LiteralPath (Join-Path $result.Path 'Source\Install-Shortcut.ps1') -Raw) | Should -Match '\$shortcut\.Arguments'
    }

    It 'generates a file shortcut with arguments' {
        $result = New-NSPShortcutApp -RepoRoot $repoRoot -Mode File -Name 'Vendor Tool' -Target '%ProgramFiles%\Vendor\Tool.exe' -Arguments '--managed' -Destination StartMenu -OutputRoot $TestDrive
        $config = Get-Content -LiteralPath (Join-Path $result.Path 'Source\Shortcut.config.json') -Raw | ConvertFrom-Json
        $config.Mode | Should -Be 'File'
        $config.Arguments | Should -Be '--managed'
        $config.Destination | Should -Be 'StartMenu'
    }

    It 'rejects non-web URLs in a web shortcut' {
        { New-NSPShortcutApp -RepoRoot $repoRoot -Mode WebDefault -Name 'Bad Link' -Target 'file:///C:/Windows' -OutputRoot $TestDrive } | Should -Throw '*absolute HTTP or HTTPS*'
    }
}
