$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'PrinterDriver.config.json') -Raw | ConvertFrom-Json
$driver = Get-PrinterDriver -Name ([string]$config.DriverName) -ErrorAction SilentlyContinue
if ($driver) {
    Write-Output "Detected printer driver: $($driver.Name)"
    exit 0
}
exit 1
