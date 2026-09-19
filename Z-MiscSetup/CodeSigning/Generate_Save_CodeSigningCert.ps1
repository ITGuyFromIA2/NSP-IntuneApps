<#
.SYNOPSIS
    Compatibility launcher for the current NSP code-signing workflow.
.DESCRIPTION
    The former Gen1 script used a hard-coded password and selected certificates by
    subject. This launcher delegates to the repository module, which generates a
    strong password through NSP.Bootstrap and activates an exact thumbprint.
#>
[CmdletBinding()]
param(
    [ValidateRange(1, 5)][int]$ValidityYears = 1,
    [switch]$WhatIf
)

$repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$manifest = Join-Path $repoRoot 'NSP.IntuneApps.psd1'
Import-Module $manifest -Force -ErrorAction Stop
New-NSPCodeSigningCertificate -RepoRoot $repoRoot -ValidityYears $ValidityYears -Activate -WhatIf:$WhatIf
