$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'ManagedReboots.config.json') -Raw | ConvertFrom-Json
$installRoot = Join-Path $env:ProgramData 'NSP\ManagedReboots'
New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
Get-ChildItem -LiteralPath $PSScriptRoot -File | Where-Object Name -NotLike 'Install-*' | Copy-Item -Destination $installRoot -Force
$promptRoot = Join-Path $installRoot 'Prompt'
New-Item -ItemType Directory -Path $promptRoot -Force | Out-Null
& icacls.exe $promptRoot /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)(F)' '*S-1-5-32-545:(OI)(CI)(M)' | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Failed to grant the local Users group access to the managed prompt exchange directory.' }

$taskName = [string]$config.TaskName
$powershell = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$action = New-ScheduledTaskAction -Execute $powershell -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$(Join-Path $installRoot 'Invoke-ManagedRebootEvaluation.ps1')`""
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes ([math]::Ceiling($config.PromptTimeoutSeconds / 60) + 5)) -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$repeat = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
$startup = New-ScheduledTaskTrigger -AtStartup
$logon = New-ScheduledTaskTrigger -AtLogOn
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Settings $settings -Trigger @($repeat,$startup,$logon) -Description 'NSP managed reboot evaluator and user notification coordinator.' | Out-Null
$xml = Get-ScheduledTask -TaskName $taskName | Export-ScheduledTask
$interval = [int]$config.EvaluationIntervalMinutes
$xml = $xml -replace '(<Triggers>[\s\S]*?<Once>[\s\S]*?)(</Once>)', ('$1<Repetition><Interval>PT' + $interval + 'M</Interval><StopAtDurationEnd>false</StopAtDurationEnd></Repetition>$2')
Register-ScheduledTask -TaskName $taskName -Xml $xml -Force | Out-Null
New-Item -Path 'HKLM:\SOFTWARE\NSP\ManagedReboots' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\NSP\ManagedReboots' -Name Version -Value ([string]$config.Version) -Type String
