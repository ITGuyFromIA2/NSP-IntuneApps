$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'ManagedReboots.config.json') -Raw | ConvertFrom-Json
$installedVersion = (Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\NSP\ManagedReboots' -Name Version -ErrorAction SilentlyContinue).Version
$task = Get-ScheduledTask -TaskName ([string]$config.TaskName) -ErrorAction SilentlyContinue
$root = Join-Path $env:ProgramData 'NSP\ManagedReboots'
$required = @('Invoke-ManagedRebootEvaluation.ps1','ManagedReboots.Core.ps1','Invoke-NSPUserPrompt.ps1','Show-NSPUserPrompt.ps1','ManagedReboots.config.json')
$missing = @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_) -PathType Leaf) })
if ($installedVersion -eq [string]$config.Version -and $task -and $missing.Count -eq 0) { Write-Output "NSP Managed Reboots $installedVersion"; exit 0 }
exit 1
