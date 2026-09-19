$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'PrinterDriver.config.json') -Raw | ConvertFrom-Json
$driverName = [string]$config.DriverName
$dependentPrinters = @(Get-Printer -ErrorAction SilentlyContinue | Where-Object DriverName -eq $driverName)
if ($dependentPrinters.Count -gt 0) {
    throw "Printer driver '$driverName' is still used by: $($dependentPrinters.Name -join ', '). Remove its printer-queue apps first."
}

if (Get-PrinterDriver -Name $driverName -ErrorAction SilentlyContinue) {
    Remove-PrinterDriver -Name $driverName
}
$installRoot = Join-Path $env:ProgramData ("NSP\PrinterDrivers\{0}" -f $config.Id)
if (Test-Path -LiteralPath $installRoot) { Remove-Item -LiteralPath $installRoot -Recurse -Force }
Write-Output "Removed printer driver: $driverName"
