[CmdletBinding()]
param(
    [string]$PackageId = 'REPLACE_WITH_BITDEFENDER_PACKAGE_ID'
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($PackageId) -or $PackageId -match '^(REPLACE_|PLACEHOLDER|EXAMPLE)') {
    throw 'A tenant-specific Bitdefender GravityZone package ID must be injected into the staged package before deployment.'
}

$wrapperUri = 'https://download.bitdefender.com/SMB/Hydra/release/bst_win/downloaderWrapper/BEST_downloaderWrapper.msi'
$wrapperPath = Join-Path $env:TEMP ("BEST_downloaderWrapper-{0}.msi" -f [guid]::NewGuid().ToString('N'))
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $wrapperUri -OutFile $wrapperPath -UseBasicParsing

$signature = Get-AuthenticodeSignature -LiteralPath $wrapperPath
if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch '(?i)Bitdefender') {
    Remove-Item -LiteralPath $wrapperPath -Force -ErrorAction SilentlyContinue
    throw "The downloaded Bitdefender wrapper did not have the expected valid Bitdefender signature. Status: $($signature.Status)."
}

$arguments = @(
    '/x'
    $wrapperPath
    '/qn'
    "GZ_PACKAGE_ID=$PackageId"
    'REBOOT_IF_NEEDED=1'
)

$process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
Remove-Item -LiteralPath $wrapperPath -Force -ErrorAction SilentlyContinue
if ($process.ExitCode -notin @(0, 1605, 1614, 1641, 3010)) {
    throw "Bitdefender uninstall failed with exit code $($process.ExitCode)."
}

if ($process.ExitCode -eq 3010) { exit 3010 }
if ($process.ExitCode -eq 1641) { exit 1641 }
exit 0
