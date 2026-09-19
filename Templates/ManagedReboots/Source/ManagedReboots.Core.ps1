function Get-NSPManagedRebootTransition {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Policy,
        $State,
        [string[]]$Signals = @(),
        [object[]]$Responses = @(),
        [datetime]$NowUtc = [datetime]::UtcNow,
        [Parameter(Mandatory)][datetime]$BootTimeUtc
    )
    $now = $NowUtc.ToUniversalTime()
    $boot = $BootTimeUtc.ToUniversalTime()
    $priorBoot = if ($State -and $State.LastBootTimeUtc) { [datetime]::Parse([string]$State.LastBootTimeUtc).ToUniversalTime() } else { $null }
    $rebootOccurred = $priorBoot -and $boot -gt $priorBoot.AddMinutes(1)
    $requiredSince = if ($State -and $State.RequiredSinceUtc -and -not $rebootOccurred) { [datetime]::Parse([string]$State.RequiredSinceUtc).ToUniversalTime() } else { $null }
    $deadline = if ($State -and $State.DeadlineUtc -and -not $rebootOccurred) { [datetime]::Parse([string]$State.DeadlineUtc).ToUniversalTime() } else { $null }
    $nextPrompt = if ($State -and $State.NextPromptUtc -and -not $rebootOccurred) { [datetime]::Parse([string]$State.NextPromptUtc).ToUniversalTime() } else { $null }
    $deferrals = if ($State -and -not $rebootOccurred) { [int]$State.DeferralCount } else { 0 }
    $processed = if ($State -and $State.ProcessedResponseIds -and -not $rebootOccurred) { @($State.ProcessedResponseIds | ForEach-Object { [string]$_ }) } else { @() }
    $signals = @($Signals | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)

    if ($signals.Count -eq 0) {
        $clean = [ordered]@{ SchemaVersion=1; LastBootTimeUtc=$boot.ToString('o'); RequiredSinceUtc=$null; DeadlineUtc=$null; NextPromptUtc=$null; DeferralCount=0; ProcessedResponseIds=@(); Reasons=@(); LastEvaluatedUtc=$now.ToString('o') }
        return [pscustomobject]@{ Action='None'; State=[pscustomobject]$clean; Reason='No reboot condition is active.' }
    }
    if (-not $requiredSince) {
        $requiredSince = $now
        $deadline = $now.AddHours([double]$Policy.GraceHours)
        $nextPrompt = $now
    }

    $action = $null
    foreach ($response in @($Responses)) {
        $responseId = [string]$response.Id
        if (-not $responseId -or $responseId -in $processed) { continue }
        $responseTime = try { [datetime]::Parse([string]$response.TimestampUtc).ToUniversalTime() } catch { $null }
        if (-not $responseTime -or $responseTime -lt $requiredSince.AddMinutes(-1) -or $responseTime -gt $now.AddMinutes(5)) { continue }
        $processed += $responseId
        if ($response.Result -eq 'Accept') { $action = 'Reboot'; break }
        if ($response.Result -eq 'Defer' -and $deferrals -lt [int]$Policy.MaxDeferrals -and $now -lt $deadline) {
            $deferrals++
            $nextPrompt = $now.AddHours([double]$Policy.DeferralHours)
        }
    }
    if (-not $action) {
        if ($now -ge $deadline) { $action = 'Reboot' }
        elseif ($now -ge $nextPrompt) { $action = 'Notify' }
        else { $action = 'Wait' }
    }
    $newState = [ordered]@{
        SchemaVersion=1; LastBootTimeUtc=$boot.ToString('o'); RequiredSinceUtc=$requiredSince.ToString('o')
        DeadlineUtc=$deadline.ToString('o'); NextPromptUtc=$nextPrompt.ToString('o'); DeferralCount=$deferrals
        ProcessedResponseIds=@($processed | Sort-Object -Unique); Reasons=$signals; LastEvaluatedUtc=$now.ToString('o')
    }
    [pscustomobject]@{ Action=$action; State=[pscustomobject]$newState; Reason=($signals -join '; ') }
}

function Get-NSPManagedRebootSignal {
    param([Parameter(Mandatory)]$Policy)
    $signals = @()
    $bootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime.ToUniversalTime()
    if (([datetime]::UtcNow - $bootTime).TotalDays -ge [double]$Policy.MaxUptimeDays) { $signals += "Uptime is at least $($Policy.MaxUptimeDays) days" }
    if (Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') { $signals += 'Component Based Servicing reports RebootPending' }
    if (Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { $signals += 'Windows Update reports RebootRequired' }
    $rename = Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
    if ($rename.PendingFileRenameOperations) { $signals += 'PendingFileRenameOperations is populated' }
    [pscustomobject]@{ BootTimeUtc=$bootTime; Signals=@($signals) }
}
