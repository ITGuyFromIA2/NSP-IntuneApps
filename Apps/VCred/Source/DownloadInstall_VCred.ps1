[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'VCred.Runtime.ps1')
$configuration = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'VCred.config.json') -Raw | ConvertFrom-Json
Install-VCredSelection -Configuration $configuration
