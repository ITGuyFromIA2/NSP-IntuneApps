$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'PrinterQueue.config.json') -Raw | ConvertFrom-Json
$printer = Get-Printer -Name ([string]$config.PrinterName) -ErrorAction SilentlyContinue
$port = Get-PrinterPort -Name ([string]$config.PortName) -ErrorAction SilentlyContinue
if ($printer -and $port -and
    $printer.DriverName -eq [string]$config.DriverName -and
    $printer.PortName -eq [string]$config.PortName -and
    [string]$port.PrinterHostAddress -eq [string]$config.HostAddress) {
    Write-Output "Detected printer queue: $($printer.Name)"
    exit 0
}
exit 1
