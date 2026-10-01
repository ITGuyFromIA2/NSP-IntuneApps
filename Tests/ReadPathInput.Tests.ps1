Describe 'Read-NSPPathInput' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
    }

    It 'strips Explorer "Copy as path" quoting from <Typed>' -ForEach @(
        @{ Typed = '"C:\Some Folder\file.ps1"'; Expected = 'C:\Some Folder\file.ps1' }
        @{ Typed = "  'C:\Some Folder\file.ps1'  "; Expected = 'C:\Some Folder\file.ps1' }
        @{ Typed = 'C:\Plain\file.ps1'; Expected = 'C:\Plain\file.ps1' }
        @{ Typed = '"'; Expected = '"' }
        @{ Typed = ''; Expected = '' }
    ) {
        InModuleScope NSP.IntuneApps -Parameters @{ Typed = $Typed } {
            param($Typed)
            Mock Read-Host { $Typed }
            Read-NSPPathInput -Prompt 'Path'
        } | Should -Be $Expected
    }
}
