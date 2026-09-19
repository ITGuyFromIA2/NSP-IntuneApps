[CmdletBinding()]
param(
    [string]$PackageId = 'REPLACE_WITH_BITDEFENDER_PACKAGE_ID',
    [switch]$DownloadOnly
)

$ErrorActionPreference = 'Stop'

$wrapperUri = 'https://download.bitdefender.com/SMB/Hydra/release/bst_win/downloaderWrapper/BEST_downloaderWrapper.msi'
$wrapperPath = Join-Path $env:TEMP ("BEST_downloaderWrapper-{0}.msi" -f [guid]::NewGuid().ToString('N'))
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $wrapperUri -OutFile $wrapperPath -UseBasicParsing

$signature = Get-AuthenticodeSignature -LiteralPath $wrapperPath
if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch '(?i)Bitdefender') {
    Remove-Item -LiteralPath $wrapperPath -Force -ErrorAction SilentlyContinue
    throw "The downloaded Bitdefender wrapper did not have the expected valid Bitdefender signature. Status: $($signature.Status)."
}

if ($DownloadOnly) {
    $result = [pscustomobject]@{
        Uri = $wrapperUri
        Length = (Get-Item -LiteralPath $wrapperPath).Length
        Sha256 = (Get-FileHash -LiteralPath $wrapperPath -Algorithm SHA256).Hash
        SignatureStatus = $signature.Status.ToString()
        SignerSubject = $signature.SignerCertificate.Subject
    }
    Remove-Item -LiteralPath $wrapperPath -Force -ErrorAction SilentlyContinue
    return $result
}

if ([string]::IsNullOrWhiteSpace($PackageId) -or $PackageId -match '^(REPLACE_|PLACEHOLDER|EXAMPLE)') {
    Remove-Item -LiteralPath $wrapperPath -Force -ErrorAction SilentlyContinue
    throw 'A tenant-specific Bitdefender GravityZone package ID must be injected into the staged package before deployment.'
}

$arguments = @(
    '/i'
    $wrapperPath
    '/qn'
    "GZ_PACKAGE_ID=$PackageId"
    'REBOOT_IF_NEEDED=1'
)

$process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
Remove-Item -LiteralPath $wrapperPath -Force -ErrorAction SilentlyContinue
if ($process.ExitCode -notin @(0, 1641, 3010)) {
    throw "Bitdefender installer failed with exit code $($process.ExitCode)."
}

if ($process.ExitCode -eq 3010) { exit 3010 }
if ($process.ExitCode -eq 1641) { exit 1641 }
exit 0
