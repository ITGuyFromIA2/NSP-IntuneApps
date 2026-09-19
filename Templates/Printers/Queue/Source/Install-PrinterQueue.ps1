$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'PrinterQueue.config.json') -Raw | ConvertFrom-Json

if (-not (Get-PrinterDriver -Name ([string]$config.DriverName) -ErrorAction SilentlyContinue)) {
    throw "Required printer driver is not installed: $($config.DriverName)"
}

$port = Get-PrinterPort -Name ([string]$config.PortName) -ErrorAction SilentlyContinue
if ($port -and [string]$port.PrinterHostAddress -ne [string]$config.HostAddress) {
    throw "Port '$($config.PortName)' already points to '$($port.PrinterHostAddress)', not '$($config.HostAddress)'."
}
if (-not $port) {
    Add-PrinterPort -Name ([string]$config.PortName) -PrinterHostAddress ([string]$config.HostAddress)
}

$printer = Get-Printer -Name ([string]$config.PrinterName) -ErrorAction SilentlyContinue
if ($printer -and ($printer.DriverName -ne [string]$config.DriverName -or $printer.PortName -ne [string]$config.PortName)) {
    throw "Printer '$($config.PrinterName)' already exists with a different driver or port."
}
if (-not $printer) {
    Add-Printer -Name ([string]$config.PrinterName) -DriverName ([string]$config.DriverName) -PortName ([string]$config.PortName)
}

$printConfig = @{}
if ([string]$config.Color -ne 'Unchanged') { $printConfig.Color = [string]$config.Color -eq 'Color' }
if ([string]$config.Duplex -ne 'Unchanged') { $printConfig.DuplexingMode = [string]$config.Duplex }
if ($printConfig.Count -gt 0) { Set-PrintConfiguration -PrinterName ([string]$config.PrinterName) @printConfig }
Write-Output "Installed printer queue: $($config.PrinterName)"
