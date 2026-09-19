$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Removal.config.json') -Raw | ConvertFrom-Json

function Get-TargetEntry {
    $paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    @(Get-ItemProperty -Path $paths -ErrorAction SilentlyContinue | Where-Object {
        $name = [string]$_.DisplayName
        $config.DisplayNamePatterns | Where-Object { $name -like [string]$_ }
    })
}

foreach ($pattern in @($config.ProcessNamePatterns)) {
    Get-Process -ErrorAction SilentlyContinue | Where-Object ProcessName -Like ([string]$pattern) | Stop-Process -Force -ErrorAction SilentlyContinue
}

foreach ($entry in @(Get-TargetEntry)) {
    $productCode = [string]$entry.PSChildName
    if ($productCode -match '^\{[0-9A-Fa-f-]{36}\}$') {
        $process = Start-Process -FilePath "$env:SystemRoot\System32\msiexec.exe" -ArgumentList @('/x', $productCode, '/qn', '/norestart') -Wait -PassThru
    } else {
        $command = if ($entry.QuietUninstallString) { [string]$entry.QuietUninstallString } else { [string]$entry.UninstallString }
        if ([string]::IsNullOrWhiteSpace($command)) { throw "No uninstall command was registered for '$($entry.DisplayName)'." }
        $process = Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList @('/d', '/s', '/c', $command) -Wait -PassThru
    }
    if ($process.ExitCode -notin @(0, 1605, 1614, 3010)) { throw "Uninstall of '$($entry.DisplayName)' failed with exit code $($process.ExitCode)." }
}

Start-Sleep -Seconds 3
$remaining = @(Get-TargetEntry)
if ($remaining.Count -gt 0) { throw "Removal did not complete for: $($remaining.DisplayName -join ', ')" }
Write-Output 'The targeted preinstalled application is absent.'
