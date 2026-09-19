function Get-NSPActiveUserSession {
    $sessions = @()
    try {
        if (-not ('NSPIntuneApps.UserPrompt.WTSApi' -as [type])) {
            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace NSPIntuneApps.UserPrompt {
    public enum WTS_CONNECTSTATE_CLASS { Active, Connected, ConnectQuery, Shadow, Disconnected, Idle, Listen, Reset, Down, Init }
    [StructLayout(LayoutKind.Sequential)]
    public struct WTS_SESSION_INFO {
        public int SessionId;
        [MarshalAs(UnmanagedType.LPStr)] public string pWinStationName;
        public WTS_CONNECTSTATE_CLASS State;
    }
    public enum WTS_INFO_CLASS { WTSUserName = 5, WTSDomainName = 7 }
    public class WTSApi {
        [DllImport("wtsapi32.dll")]
        public static extern bool WTSEnumerateSessions(IntPtr server, int reserved, int version, out IntPtr sessionInfo, out int count);
        [DllImport("wtsapi32.dll")]
        public static extern void WTSFreeMemory(IntPtr memory);
        [DllImport("wtsapi32.dll", CharSet = CharSet.Ansi)]
        public static extern bool WTSQuerySessionInformation(IntPtr server, int sessionId, WTS_INFO_CLASS infoClass, out IntPtr buffer, out int bytesReturned);
    }
}
'@ -ErrorAction Stop
        }
        $server = [IntPtr]::Zero
        $sessionInfo = [IntPtr]::Zero
        $count = 0
        if ([NSPIntuneApps.UserPrompt.WTSApi]::WTSEnumerateSessions($server, 0, 1, [ref]$sessionInfo, [ref]$count)) {
            try {
                $size = [Runtime.InteropServices.Marshal]::SizeOf([type][NSPIntuneApps.UserPrompt.WTS_SESSION_INFO])
                for ($index = 0; $index -lt $count; $index++) {
                    $pointer = [IntPtr]::Add($sessionInfo, $index * $size)
                    $item = [Runtime.InteropServices.Marshal]::PtrToStructure($pointer, [type][NSPIntuneApps.UserPrompt.WTS_SESSION_INFO])
                    if ($item.State -ne [NSPIntuneApps.UserPrompt.WTS_CONNECTSTATE_CLASS]::Active) { continue }
                    $userPointer = [IntPtr]::Zero; $userLength = 0
                    $domainPointer = [IntPtr]::Zero; $domainLength = 0
                    $username = $null; $domain = $null
                    if ([NSPIntuneApps.UserPrompt.WTSApi]::WTSQuerySessionInformation($server, $item.SessionId, [NSPIntuneApps.UserPrompt.WTS_INFO_CLASS]::WTSUserName, [ref]$userPointer, [ref]$userLength)) {
                        try { $username = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($userPointer) } finally { [NSPIntuneApps.UserPrompt.WTSApi]::WTSFreeMemory($userPointer) }
                    }
                    if ([string]::IsNullOrWhiteSpace($username)) { continue }
                    if ([NSPIntuneApps.UserPrompt.WTSApi]::WTSQuerySessionInformation($server, $item.SessionId, [NSPIntuneApps.UserPrompt.WTS_INFO_CLASS]::WTSDomainName, [ref]$domainPointer, [ref]$domainLength)) {
                        try { $domain = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($domainPointer) } finally { [NSPIntuneApps.UserPrompt.WTSApi]::WTSFreeMemory($domainPointer) }
                    }
                    $sessions += [pscustomobject]@{
                        SessionName = $item.pWinStationName
                        Username = if ($domain) { "$domain\$username" } else { $username }
                        SessionId = $item.SessionId
                    }
                }
            } finally { [NSPIntuneApps.UserPrompt.WTSApi]::WTSFreeMemory($sessionInfo) }
        }
    } catch {
        Write-Warning "WTS active-session discovery failed: $($_.Exception.Message)"
    }
    return @($sessions | Sort-Object Username -Unique)
}

function Invoke-NSPUserPrompt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$PromptConfigPath,
        [Parameter(Mandatory)][string]$PromptScriptPath,
        [Parameter(Mandatory)][string]$WorkingDirectory,
        [string]$TaskPrefix = 'NSP_UserPrompt',
        [int]$TimeoutSeconds = 900
    )
    $activeUsers = @(Get-NSPActiveUserSession)
    if ($activeUsers.Count -eq 0) { return [pscustomobject]@{ Result='NoUser'; Username=$null; TimestampUtc=[datetime]::UtcNow.ToString('o') } }
    New-Item -ItemType Directory -Path $WorkingDirectory -Force | Out-Null
    $runId = [guid]::NewGuid().ToString('N')
    $resultPath = Join-Path $WorkingDirectory "Result-$runId.json"
    $powershell = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $taskArguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PromptScriptPath`" -ConfigPath `"$PromptConfigPath`" -ResultPath `"$resultPath`" -TimeoutSeconds $TimeoutSeconds"
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Seconds ($TimeoutSeconds + 120)) -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    $tasks = @()
    try {
        foreach ($user in $activeUsers) {
            $safeUser = ($user.Username -replace '[^A-Za-z0-9_.-]', '_')
            if ($safeUser.Length -gt 60) { $safeUser = $safeUser.Substring(0,60) }
            $taskName = "${TaskPrefix}_${safeUser}_$($runId.Substring(0,8))"
            $action = New-ScheduledTaskAction -Execute $powershell -Argument $taskArguments
            $principal = New-ScheduledTaskPrincipal -UserId $user.Username -LogonType Interactive -RunLevel Limited
            Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Settings $settings | Out-Null
            $taskXml = Get-ScheduledTask -TaskName $taskName | Export-ScheduledTask
            $taskXml = $taskXml -replace '<Hidden>false</Hidden>', '<Hidden>true</Hidden>'
            $qualifiedUser = [Security.SecurityElement]::Escape($user.Username)
            $taskXml = $taskXml -replace '(?<=<UserId>)[^<]+(?=</UserId>)', $qualifiedUser
            Register-ScheduledTask -TaskName $taskName -Xml $taskXml -Force | Out-Null
            Start-ScheduledTask -TaskName $taskName
            $tasks += $taskName
        }
        $deadline = [datetime]::UtcNow.AddSeconds($TimeoutSeconds + 30)
        while ([datetime]::UtcNow -lt $deadline -and -not (Test-Path -LiteralPath $resultPath)) { Start-Sleep -Seconds 2 }
        if (Test-Path -LiteralPath $resultPath) {
            try { return Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json } catch { return [pscustomobject]@{ Result='InvalidResult'; Username=$null; TimestampUtc=[datetime]::UtcNow.ToString('o') } }
        }
        return [pscustomobject]@{ Result='Timeout'; Username=$null; TimestampUtc=[datetime]::UtcNow.ToString('o') }
    } finally {
        foreach ($taskName in $tasks) {
            if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
                Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
            }
        }
        Remove-Item -LiteralPath $resultPath -Force -ErrorAction SilentlyContinue
    }
}
