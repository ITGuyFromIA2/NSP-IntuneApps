$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Adobe.config.json') -Raw | ConvertFrom-Json
$registryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$apps = @(Get-ItemProperty -Path $registryPaths -ErrorAction SilentlyContinue | Where-Object DisplayName -Like ([string]$config.DisplayNamePattern))
if ($apps.Count -eq 0) { exit 0 }

$failures = @()
foreach ($app in $apps) {
    $productCode = if ([string]$app.PSChildName -match '^\{[0-9A-Fa-f-]{36}\}$') { [string]$app.PSChildName } elseif ([string]$app.UninstallString -match '\{[0-9A-Fa-f-]{36}\}') { $Matches[0] } else { $null }
    if (-not $productCode) {
        $failures += "No MSI product code was available for '$($app.DisplayName)'."
        continue
    }
    $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList @('/x', $productCode, '/qn', '/norestart') -Wait -PassThru
    if ($process.ExitCode -notin @(0,1605,1614,1641,3010)) { $failures += "'$($app.DisplayName)' returned $($process.ExitCode)." }
}
if ($failures.Count -gt 0) { throw ($failures -join ' ') }
