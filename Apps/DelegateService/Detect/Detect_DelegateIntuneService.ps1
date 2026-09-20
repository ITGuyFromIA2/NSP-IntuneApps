$ErrorActionPreference = 'SilentlyContinue'
$serviceName = 'IntuneManagementExtension'
$delegateTo = 'Power Users'
$setAclPath = Join-Path $env:ProgramData 'NSP\Tools\SetACL\3.1.2\SetACL.exe'

if (-not (Test-Path -LiteralPath $setAclPath)) { exit 1 }

$serviceObject = "\\127.0.0.1\$serviceName"
$output = & $setAclPath -on $serviceObject -ot srv -actn list 2>&1
$escapedTrustee = [regex]::Escape($delegateTo)
if ($LASTEXITCODE -eq 0 -and ($output -join "`n") -match "$escapedTrustee\s+start_stop\s+allow") {
    Write-Output "Service start/stop is delegated to $delegateTo."
    exit 0
}

exit 1
