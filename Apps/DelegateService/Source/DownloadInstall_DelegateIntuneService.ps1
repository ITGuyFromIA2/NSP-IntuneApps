[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$ServiceName,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$DelegateTo
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Get-NSPSetAcl.ps1')

if (-not (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
    throw "Service '$ServiceName' was not found."
}

$setAcl = (Get-NSPSetAcl).FullName
$serviceObject = "\\127.0.0.1\$ServiceName"
$ace = "n:.\$DelegateTo;p:start_stop"

$output = & $setAcl -on $serviceObject -ot srv -actn ace -ace $ace 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "SetACL failed to delegate service control (exit $LASTEXITCODE): $($output -join ' ')"
}

$verification = & $setAcl -on $serviceObject -ot srv -actn list 2>&1
$escapedTrustee = [regex]::Escape($DelegateTo)
if ($LASTEXITCODE -ne 0 -or ($verification -join "`n") -notmatch "$escapedTrustee\s+start_stop\s+allow") {
    throw "Service delegation could not be verified for '$DelegateTo'."
}

exit 0
