Describe 'Printer generator' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
        $payload = Join-Path $TestDrive 'payload'
        New-Item -ItemType Directory -Path (Join-Path $payload 'Driver\x64') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $payload 'Driver\x64\example.inf') -Value '; disposable test INF'
        $archive = Join-Path $TestDrive 'ExampleDriver.zip'
        Compress-Archive -Path (Join-Path $payload '*') -DestinationPath $archive
    }

    It 'creates a self-contained driver app with a recorded archive hash' {
        $result = New-NSPPrinterApp -RepoRoot $repoRoot -Mode Driver -Name 'Example Printer Driver' -DriverName 'Example Universal Driver' -InfRelativePath 'Driver\x64\example.inf' -DriverArchivePath $archive -OutputRoot (Join-Path $TestDrive 'drivers')
        $config = Get-Content -LiteralPath (Join-Path $result.Path 'Source\PrinterDriver.config.json') -Raw | ConvertFrom-Json
        Test-Path -LiteralPath (Join-Path $result.Path 'Source\Driver.zip') | Should -BeTrue
        $config.DriverName | Should -Be 'Example Universal Driver'
        $config.SourceArchiveSha256 | Should -Be (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
    }

    It 'creates a queue app with an Intune driver dependency' {
        $result = New-NSPPrinterApp -RepoRoot $repoRoot -Mode Queue -Name 'Example Office Printer' -DriverName 'Example Universal Driver' -DriverAppName 'Example Printer Driver' -HostAddress 'printer.example.invalid' -Color Monochrome -Duplex TwoSidedLongEdge -OutputRoot (Join-Path $TestDrive 'queues')
        $config = Get-Content -LiteralPath (Join-Path $result.Path 'Source\PrinterQueue.config.json') -Raw | ConvertFrom-Json
        $settings = Get-Content -LiteralPath $result.SettingsPath -Raw
        $config.PortName | Should -Be 'TCP_printer.example.invalid'
        $settings | Should -Match "AppName='Example Printer Driver'"
        $settings | Should -Match "DependencyType='AutoInstall'"
    }

    It 'rejects an INF path that escapes the archive' {
        { New-NSPPrinterApp -RepoRoot $repoRoot -Mode Driver -Name 'Unsafe Driver' -DriverName 'Unsafe' -InfRelativePath '..\outside.inf' -DriverArchivePath $archive -OutputRoot (Join-Path $TestDrive 'unsafe') } | Should -Throw
    }
}
