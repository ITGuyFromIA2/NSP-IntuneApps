$ErrorActionPreference = 'Stop'
$installRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$config = Get-Content -LiteralPath (Join-Path $installRoot 'ManagedReboots.config.json') -Raw | ConvertFrom-Json
. (Join-Path $installRoot 'ManagedReboots.Core.ps1')
. (Join-Path $installRoot 'Invoke-NSPUserPrompt.ps1')
$statePath = Join-Path $installRoot 'State.json'
$state = if (Test-Path -LiteralPath $statePath) { Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json } else { $null }
$signal = Get-NSPManagedRebootSignal -Policy $config
$transition = Get-NSPManagedRebootTransition -Policy $config -State $state -Signals $signal.Signals -BootTimeUtc $signal.BootTimeUtc
$transition.State | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statePath -Encoding UTF8

if ($transition.Action -eq 'Notify') {
    $promptConfig = [ordered]@{
        Title=[string]$config.PromptTitle
        Message=([string]$config.PromptMessage + "`r`n`r`nReason: " + $transition.Reason + "`r`nFinal deadline: " + ([datetime]$transition.State.DeadlineUtc).ToLocalTime().ToString('g') + "`r`nDeferrals used: $($transition.State.DeferralCount) of $($config.MaxDeferrals)")
        AcceptLabel='Reboot now'
        DeferLabel=if ($transition.State.DeferralCount -lt $config.MaxDeferrals) { 'Defer' } else { 'Close' }
    }
    $promptConfigPath = Join-Path $installRoot 'Prompt\CurrentPrompt.json'
    $promptConfig | ConvertTo-Json | Set-Content -LiteralPath $promptConfigPath -Encoding UTF8
    $response = Invoke-NSPUserPrompt -PromptConfigPath $promptConfigPath -PromptScriptPath (Join-Path $installRoot 'Show-NSPUserPrompt.ps1') -WorkingDirectory (Join-Path $installRoot 'Prompt') -TaskPrefix 'NSP_ManagedRebootPrompt' -TimeoutSeconds ([int]$config.PromptTimeoutSeconds)
    if ($response.Result -in @('Accept','Defer')) {
        $record = [pscustomobject]@{ Id=[guid]::NewGuid().ToString('N'); Result=[string]$response.Result; TimestampUtc=[string]$response.TimestampUtc; Username=[string]$response.Username }
        $transition = Get-NSPManagedRebootTransition -Policy $config -State $transition.State -Signals $signal.Signals -Responses @($record) -BootTimeUtc $signal.BootTimeUtc
        $transition.State | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statePath -Encoding UTF8
    }
}
if ($transition.Action -eq 'Reboot') {
    & shutdown.exe /r /t ([int]$config.RebootCountdownSeconds) /d p:4:1 /c 'A managed reboot deadline has been reached. Save your work.'
}
