[CmdletBinding()]
param()

$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'DriveMap.config.json') -Raw | ConvertFrom-Json
$destination = Join-Path $env:ProgramData ('NSP\DriveMaps\{0}' -f $config.Id)
Unregister-ScheduledTask -TaskName ([string]$config.TaskName) -Confirm:$false -ErrorAction SilentlyContinue
if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Recurse -Force }
