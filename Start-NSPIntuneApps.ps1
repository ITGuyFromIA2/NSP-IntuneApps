[CmdletBinding()]
param(
    [string]$RepoRoot = $PSScriptRoot
)

$manifest = Join-Path $PSScriptRoot 'NSP.IntuneApps.psd1'
Import-Module $manifest -Force -ErrorAction Stop
Start-NSPIntuneApps -RepoRoot $RepoRoot
