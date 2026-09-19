[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'VCred.Runtime.ps1')
$configuration = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'VCred.config.json') -Raw | ConvertFrom-Json
$programs = Get-VCredInstalledPrograms
$missing = @(Get-VCredSelection -Configuration $configuration | Where-Object { -not (Test-VCredEntry -Entry $_ -InstalledPrograms $programs) })
if ($missing.Count -eq 0) {
    Write-Output 'All configured Microsoft Visual C++ Redistributables are installed.'
    exit 0
}
Write-Output ("Missing: {0}" -f (($missing | ForEach-Object { "$($_.Version) $($_.Architecture)" }) -join ', '))
exit 1
