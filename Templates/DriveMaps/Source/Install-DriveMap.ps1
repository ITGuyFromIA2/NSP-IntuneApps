[CmdletBinding()]
param()

$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'DriveMap.config.json') -Raw | ConvertFrom-Json
$destination = Join-Path $env:ProgramData ('NSP\DriveMaps\{0}' -f $config.Id)
New-Item -ItemType Directory -Path $destination -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'DriveMap.config.json') -Destination $destination -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Invoke-DriveMap.ps1') -Destination $destination -Force

$scriptPath = Join-Path $destination 'Invoke-DriveMap.ps1'
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ('-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "{0}"' -f $scriptPath)
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -GroupId 'BUILTIN\Users' -RunLevel Limited
Register-ScheduledTask -TaskName ([string]$config.TaskName) -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
