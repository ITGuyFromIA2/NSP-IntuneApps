function Get-NSPSetAcl {
    <#
    .SYNOPSIS
        Retrieves SetACL directly from its publisher and selects the requested architecture.
    .DESCRIPTION
        SetACL is not redistributed in this repository or the Intune package. The fixed-version
        archive is downloaded over HTTPS from the publisher during installation. Normal use is
        blocked until the archive hash has been recorded from the disposable-VM audit.
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('x86','x64')][string]$Architecture = $(if ([Environment]::Is64BitOperatingSystem) { 'x64' } else { 'x86' }),
        [string]$DestinationPath,
        [switch]$AuditOnly
    )

    $ErrorActionPreference = 'Stop'
    $version = '3.1.2'
    $archiveUri = [uri]'https://helgeklein.com/files/SetACL/current/SetACL%203.1.2%20%28executable%20version%29.zip'

    # Replace only after the disposable-VM audit records the official archive's SHA-256.
    $expectedSha256 = 'REPLACE_AFTER_VM_VALIDATION'

    if ($archiveUri.Scheme -ne 'https' -or $archiveUri.DnsSafeHost -ne 'helgeklein.com') {
        throw "Unexpected SetACL source URI: $archiveUri"
    }

    $workRoot = Join-Path ([IO.Path]::GetTempPath()) ("NSP-SetACL-{0}" -f [guid]::NewGuid().ToString('N'))
    $archivePath = Join-Path $workRoot 'SetACL.zip'
    $extractRoot = Join-Path $workRoot 'Extracted'
    New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $archiveUri.AbsoluteUri -OutFile $archivePath -UseBasicParsing -MaximumRedirection 0
        $archiveHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToUpperInvariant()

        if (-not $AuditOnly -and $expectedSha256 -eq 'REPLACE_AFTER_VM_VALIDATION') {
            throw 'SetACL installation is intentionally blocked until its official archive hash is recorded by the disposable-VM audit. Run this function with -AuditOnly first.'
        }
        if (-not $AuditOnly -and $archiveHash -ne $expectedSha256) {
            throw "SetACL archive failed SHA-256 validation. Expected $expectedSha256; received $archiveHash."
        }

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $archive = [IO.Compression.ZipFile]::OpenRead($archivePath)
        try {
            foreach ($entry in $archive.Entries) {
                $candidate = [IO.Path]::GetFullPath((Join-Path $extractRoot $entry.FullName))
                $rootPrefix = [IO.Path]::GetFullPath($extractRoot).TrimEnd('\') + '\'
                if (-not $candidate.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
                    throw "SetACL archive contains an unsafe path: $($entry.FullName)"
                }
            }
        } finally {
            $archive.Dispose()
        }

        [IO.Compression.ZipFile]::ExtractToDirectory($archivePath, $extractRoot)
        $executables = @(Get-ChildItem -LiteralPath $extractRoot -Recurse -File -Filter 'SetACL.exe')
        if ($executables.Count -ne 2) {
            throw "Expected exactly two SetACL executables in the publisher archive; found $($executables.Count)."
        }

        $details = foreach ($file in $executables) {
            $pathArchitecture = if ($file.FullName -match '(?i)(^|[\\/])64[ -]?bit([\\/]|$)') { 'x64' }
                elseif ($file.FullName -match '(?i)(^|[\\/])32[ -]?bit([\\/]|$)') { 'x86' }
                else { 'Unknown' }
            $signature = Get-AuthenticodeSignature -LiteralPath $file.FullName
            [pscustomobject]@{
                Architecture = $pathArchitecture
                RelativePath = $file.FullName.Substring($extractRoot.Length).TrimStart('\')
                Length = $file.Length
                Sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
                ProductVersion = $file.VersionInfo.ProductVersion
                SignatureStatus = $signature.Status.ToString()
                SignerSubject = if ($signature.SignerCertificate) { $signature.SignerCertificate.Subject } else { $null }
            }
        }

        if (@($details | Where-Object Architecture -eq 'Unknown').Count -gt 0 -or
            @($details | Group-Object Architecture | Where-Object Count -ne 1).Count -gt 0) {
            throw 'The SetACL publisher archive no longer has one recognizable x86 and one recognizable x64 executable.'
        }

        if ($AuditOnly) {
            return [pscustomobject]@{
                Version = $version
                Uri = $archiveUri.AbsoluteUri
                ArchiveLength = (Get-Item -LiteralPath $archivePath).Length
                ArchiveSha256 = $archiveHash
                Executables = @($details)
            }
        }

        $selected = $executables | Where-Object {
            if ($Architecture -eq 'x64') { $_.FullName -match '(?i)(^|[\\/])64[ -]?bit([\\/]|$)' }
            else { $_.FullName -match '(?i)(^|[\\/])32[ -]?bit([\\/]|$)' }
        } | Select-Object -First 1
        if (-not $selected) { throw "SetACL $Architecture executable was not found after extraction." }

        if (-not $DestinationPath) {
            $DestinationPath = Join-Path $env:ProgramData "NSP\Tools\SetACL\$version\SetACL.exe"
        }
        New-Item -ItemType Directory -Path (Split-Path -Path $DestinationPath -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $selected.FullName -Destination $DestinationPath -Force
        return Get-Item -LiteralPath $DestinationPath
    } finally {
        Remove-Item -LiteralPath $workRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
