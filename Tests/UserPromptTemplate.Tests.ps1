Describe 'Interactive user prompt template' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
    }

    It 'uses WTS discovery and per-user interactive scheduled tasks without ServiceUI or AnyBox' {
        $bridge = Get-Content -LiteralPath (Join-Path $repoRoot 'Templates\UserPrompt\Invoke-NSPUserPrompt.ps1') -Raw
        $dialog = Get-Content -LiteralPath (Join-Path $repoRoot 'Templates\UserPrompt\Show-NSPUserPrompt.ps1') -Raw
        $bridge | Should -Match 'WTSEnumerateSessions'
        $bridge | Should -Match 'LogonType Interactive'
        $bridge | Should -Match 'SecurityElement.*Escape'
        $dialog | Should -Match '\[IO\.File\]::Move'
        $dialog | Should -Not -Match '(?m)^\s*Move-Item.*-Force'
        ($bridge + $dialog) | Should -Not -Match 'ServiceUI|AnyBox|Install-Module|PSGallery'
    }

    It 'reads prompt text from JSON instead of embedding it in task arguments' {
        $bridge = Get-Content -LiteralPath (Join-Path $repoRoot 'Templates\UserPrompt\Invoke-NSPUserPrompt.ps1') -Raw
        $dialog = Get-Content -LiteralPath (Join-Path $repoRoot 'Templates\UserPrompt\Show-NSPUserPrompt.ps1') -Raw
        $bridge | Should -Match '-ConfigPath'
        $bridge | Should -Not -Match '-Title `\\"\$Title'
        $dialog | Should -Match 'ConvertFrom-Json'
    }
}
