[CmdletBinding()]
param(
    [string]$ConfigurationPath = (Join-Path $PSScriptRoot 'DriveMap.config.json'),
    [switch]$Remove
)

$config = Get-Content -LiteralPath $ConfigurationPath -Raw | ConvertFrom-Json
$drive = ('{0}:' -f ([string]$config.DriveLetter).TrimEnd(':').ToUpperInvariant())

if ($Remove) {
    & $env:SystemRoot\System32\net.exe use $drive /delete /y | Out-Null
    exit 0
}

& $env:SystemRoot\System32\net.exe use $drive /delete /y | Out-Null
$persistent = if ($config.Persistent) { 'yes' } else { 'no' }
& $env:SystemRoot\System32\net.exe use $drive ([string]$config.Path) "/persistent:$persistent" | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Unable to map $drive to $($config.Path). net.exe returned $LASTEXITCODE." }
