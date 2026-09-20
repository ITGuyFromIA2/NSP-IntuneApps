[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$ServiceName,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$DelegateTo
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Get-NSPSetAcl.ps1')

$setAclPath = Join-Path $env:ProgramData 'NSP\Tools\SetACL\3.1.2\SetACL.exe'
if (-not (Test-Path -LiteralPath $setAclPath)) {
    $setAclPath = (Get-NSPSetAcl).FullName
}

$serviceObject = "\\127.0.0.1\$ServiceName"
$trustee = "n1:.\$DelegateTo;ta:remtrst"
$output = & $setAclPath -on $serviceObject -ot srv -actn trustee -trst $trustee 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "SetACL failed to remove service delegation (exit $LASTEXITCODE): $($output -join ' ')"
}

$verification = & $setAclPath -on $serviceObject -ot srv -actn list 2>&1
$escapedTrustee = [regex]::Escape($DelegateTo)
if ($LASTEXITCODE -ne 0 -or ($verification -join "`n") -match "$escapedTrustee\s+start_stop\s+allow") {
    throw "Service delegation still exists for '$DelegateTo'."
}

exit 0
