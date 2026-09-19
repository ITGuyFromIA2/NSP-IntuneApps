$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'PrinterQueue.config.json') -Raw | ConvertFrom-Json
$printerName = [string]$config.PrinterName
$portName = [string]$config.PortName
if (Get-Printer -Name $printerName -ErrorAction SilentlyContinue) { Remove-Printer -Name $printerName }
$otherUsers = @(Get-Printer -ErrorAction SilentlyContinue | Where-Object PortName -eq $portName)
if ($otherUsers.Count -eq 0 -and (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {
    Remove-PrinterPort -Name $portName
}
Write-Output "Removed printer queue: $printerName"
