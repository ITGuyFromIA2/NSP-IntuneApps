$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'PrinterDriver.config.json') -Raw | ConvertFrom-Json
$archive = Join-Path $PSScriptRoot 'Driver.zip'
if (-not (Test-Path -LiteralPath $archive)) { throw "Printer driver archive is missing: $archive" }
$archiveHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
if ($archiveHash -ne [string]$config.SourceArchiveSha256) { throw 'Printer driver archive failed its recorded SHA-256 integrity check.' }

$installRoot = Join-Path $env:ProgramData ("NSP\PrinterDrivers\{0}" -f $config.Id)
if (Test-Path -LiteralPath $installRoot) { Remove-Item -LiteralPath $installRoot -Recurse -Force }
New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
Expand-Archive -LiteralPath $archive -DestinationPath $installRoot -Force

$infPath = [IO.Path]::GetFullPath((Join-Path $installRoot ([string]$config.InfRelativePath)))
$rootPath = [IO.Path]::GetFullPath($installRoot).TrimEnd('\') + '\'
if (-not $infPath.StartsWith($rootPath, [StringComparison]::OrdinalIgnoreCase)) { throw 'InfRelativePath escapes the extracted driver directory.' }
if (-not (Test-Path -LiteralPath $infPath -PathType Leaf)) { throw "Configured INF was not found in the driver archive: $($config.InfRelativePath)" }

& "$env:SystemRoot\System32\pnputil.exe" /add-driver $infPath /install
if ($LASTEXITCODE -notin @(0, 3010)) { throw "pnputil failed with exit code $LASTEXITCODE." }

if (-not (Get-PrinterDriver -Name ([string]$config.DriverName) -ErrorAction SilentlyContinue)) {
    Add-PrinterDriver -Name ([string]$config.DriverName)
}
if (-not (Get-PrinterDriver -Name ([string]$config.DriverName) -ErrorAction SilentlyContinue)) {
    throw "Windows did not expose the expected printer driver '$($config.DriverName)'. Verify the exact driver name in the INF."
}

Write-Output "Installed printer driver: $($config.DriverName)"
