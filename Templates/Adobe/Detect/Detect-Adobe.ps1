$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Adobe.config.json') -Raw | ConvertFrom-Json
$registryPaths = if ($config.Architecture -eq 'x86') {
    @('HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
} else {
    @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
}
$apps = @(Get-ItemProperty -Path $registryPaths -ErrorAction SilentlyContinue | Where-Object DisplayName -Like ([string]$config.DisplayNamePattern))
if ($config.Version) {
    $minimum = try { [version]$config.Version } catch { $null }
    if ($minimum) { $apps = @($apps | Where-Object { try { [version]$_.DisplayVersion -ge $minimum } catch { $false } }) }
}
if ($apps.Count -gt 0) {
    Write-Output ($apps | Select-Object -First 1 -ExpandProperty DisplayName)
    exit 0
}
exit 1
