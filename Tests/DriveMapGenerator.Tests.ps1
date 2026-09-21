Describe 'DriveMap generator' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
    }

    It 'creates one self-contained app from configuration' {
        $result = New-NSPDriveMapApp -RepoRoot $repoRoot -Name 'Example Shared Drive' -DriveLetter S -Path '\\files.example.invalid\Shared' -OutputRoot $TestDrive
        Test-Path -LiteralPath $result.SettingsPath | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $result.Path 'Source\DriveMap.config.json') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $result.Path 'Detect\DriveMap.config.json') | Should -BeTrue
        (Get-Content -LiteralPath (Join-Path $result.Path 'Source\DriveMap.config.json') -Raw | ConvertFrom-Json).DriveLetter | Should -Be 'S'
    }
}
