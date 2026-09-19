$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'ManagedReboots.config.json') -Raw | ConvertFrom-Json
Stop-ScheduledTask -TaskName ([string]$config.TaskName) -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName ([string]$config.TaskName) -Confirm:$false -ErrorAction SilentlyContinue
Get-ScheduledTask -TaskName 'NSP_ManagedRebootPrompt_*' -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-ScheduledTask -TaskName $_.TaskName -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
}
Remove-Item -LiteralPath 'HKLM:\SOFTWARE\NSP\ManagedReboots' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $env:ProgramData 'NSP\ManagedReboots') -Recurse -Force -ErrorAction SilentlyContinue
