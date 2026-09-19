$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Removal.config.json') -Raw | ConvertFrom-Json
$paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$found = @(Get-ItemProperty -Path $paths -ErrorAction SilentlyContinue | Where-Object {
    $name = [string]$_.DisplayName
    $config.DisplayNamePatterns | Where-Object { $name -like [string]$_ }
})
if ($found.Count -eq 0) {
    Write-Output 'The targeted preinstalled application is absent.'
    exit 0
}
exit 1
