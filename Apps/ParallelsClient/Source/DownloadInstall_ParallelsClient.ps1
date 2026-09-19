[CmdletBinding()]
param([switch]$DownloadOnly)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http -ErrorAction Stop

$sourceRoot = $PSScriptRoot
$configurationPath = Join-Path $sourceRoot 'ParallelsConnection.config.psd1'
if (-not (Test-Path -LiteralPath $configurationPath -PathType Leaf)) {
    throw 'ParallelsConnection.config.psd1 is missing. Copy and complete the example configuration before packaging.'
}

$configuration = Import-PowerShellDataFile -LiteralPath $configurationPath
if ([string]$configuration.Alias -match '^REPLACE_WITH_' -or [string]$configuration.Server -match '^REPLACE_WITH_') {
    throw 'The Parallels connection configuration still contains placeholder values.'
}
if ([string]::IsNullOrWhiteSpace([string]$configuration.Alias) -or [string]::IsNullOrWhiteSpace([string]$configuration.Server)) {
    throw 'Alias and Server are required.'
}
$port = [int]$configuration.Port
if ($port -lt 1 -or $port -gt 65535) { throw 'Port must be between 1 and 65535.' }

$sourceMode = if ($configuration.SourceMode) { [string]$configuration.SourceMode } else { 'Latest' }
if ($sourceMode -notin @('Latest', 'Pinned')) { throw "SourceMode must be Latest or Pinned, not '$sourceMode'." }
$expectedSignerPattern = if ($configuration.ExpectedSignerPattern) { [string]$configuration.ExpectedSignerPattern } else { '(?i)Parallels|Alludo' }
$workingRoot = Join-Path $env:ProgramData 'NSP\IntuneApps\ParallelsClient'
New-Item -ItemType Directory -Path $workingRoot -Force | Out-Null
$msiPath = Join-Path $workingRoot 'RASClient-x64.msi'

function Get-ParallelsLatestMsiUri {
    param([Parameter(Mandatory)][uri]$DownloadPageUri)

    if ($DownloadPageUri.Scheme -ne 'https' -or $DownloadPageUri.DnsSafeHost -notmatch '(^|\.)parallels\.com$') {
        throw "The Parallels download page must be an HTTPS parallels.com address: $DownloadPageUri"
    }

    $handler = [Net.Http.HttpClientHandler]::new()
    $handler.AutomaticDecompression = [Net.DecompressionMethods]::GZip -bor [Net.DecompressionMethods]::Deflate
    $client = [Net.Http.HttpClient]::new($handler)
    $client.Timeout = [TimeSpan]::FromSeconds(60)
    $client.DefaultRequestHeaders.UserAgent.ParseAdd('NSP-IntuneApps/1.0')
    try {
        $html = $client.GetStringAsync($DownloadPageUri).GetAwaiter().GetResult()
    }
    finally {
        $client.Dispose()
        $handler.Dispose()
    }

    $candidates = [Collections.Generic.List[uri]]::new()
    $anchorPattern = '(?is)<a\b[^>]*?href\s*=\s*["''](?<href>[^"'']+)["''][^>]*>(?<text>.*?)</a>'
    foreach ($match in [regex]::Matches($html, $anchorPattern)) {
        $text = [Net.WebUtility]::HtmlDecode(([regex]::Replace($match.Groups['text'].Value, '<[^>]+>', ' ')))
        $href = [Net.WebUtility]::HtmlDecode($match.Groups['href'].Value)
        if ($text -notmatch '(?i)(Remote Application Server|RAS).*Client.*Windows.*64-bit.*Setup' -and
            $href -notmatch '(?i)RASClient[^/]*-x64\.msi(?:\?|$)') { continue }

        $candidate = [uri]::new($DownloadPageUri, $href)
        if ($candidate.Scheme -eq 'https') { $candidates.Add($candidate) }
    }

    $unique = @($candidates | Select-Object -ExpandProperty AbsoluteUri -Unique)
    if ($unique.Count -ne 1) {
        throw "Expected exactly one current x64 Parallels RAS Client MSI link on $DownloadPageUri; found $($unique.Count). The vendor page shape may have changed."
    }
    [uri]$unique[0]
}

function Save-ValidatedParallelsMsi {
    param(
        [Parameter(Mandatory)][uri]$Uri,
        [Parameter(Mandatory)][string]$DestinationPath,
        [string]$RequiredSha256,
        [Parameter(Mandatory)][string]$SignerPattern
    )

    if ($Uri.Scheme -ne 'https') { throw "Refusing to download an installer over non-HTTPS URI: $Uri" }
    $temporaryPath = "$DestinationPath.download"
    Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
    try {
        $handler = [Net.Http.HttpClientHandler]::new()
        $handler.AutomaticDecompression = [Net.DecompressionMethods]::GZip -bor [Net.DecompressionMethods]::Deflate
        $client = [Net.Http.HttpClient]::new($handler)
        $client.Timeout = [TimeSpan]::FromMinutes(5)
        $client.DefaultRequestHeaders.UserAgent.ParseAdd('NSP-IntuneApps/1.0')
        try {
            $response = $client.GetAsync($Uri).GetAwaiter().GetResult()
            $response.EnsureSuccessStatusCode() | Out-Null
            if ($response.RequestMessage.RequestUri.Scheme -ne 'https') {
                throw "The installer download redirected to a non-HTTPS URI: $($response.RequestMessage.RequestUri)"
            }
            $bytes = $response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
            [IO.File]::WriteAllBytes($temporaryPath, $bytes)
        }
        finally {
            $client.Dispose()
            $handler.Dispose()
        }

        $compoundFileHeader = [byte[]](0xD0,0xCF,0x11,0xE0,0xA1,0xB1,0x1A,0xE1)
        $stream = [IO.File]::OpenRead($temporaryPath)
        try {
            $header = [byte[]]::new($compoundFileHeader.Length)
            $read = $stream.Read($header, 0, $header.Length)
        }
        finally { $stream.Dispose() }
        if ($read -lt $compoundFileHeader.Length) { throw 'The downloaded file is too short to be a Windows Installer package.' }
        for ($index = 0; $index -lt $compoundFileHeader.Length; $index++) {
            if ($header[$index] -ne $compoundFileHeader[$index]) { throw 'The downloaded file does not have a Windows Installer compound-file header.' }
        }

        $actualHash = (Get-FileHash -LiteralPath $temporaryPath -Algorithm SHA256).Hash
        if ($RequiredSha256 -and $actualHash -ne $RequiredSha256.Trim()) {
            throw "Pinned Parallels MSI hash mismatch. Expected $RequiredSha256; received $actualHash."
        }

        $signature = Get-AuthenticodeSignature -LiteralPath $temporaryPath
        if ($signature.Status -ne 'Valid') { throw "The downloaded Parallels MSI signature is not valid: $($signature.Status)." }
        if (-not $signature.SignerCertificate -or $signature.SignerCertificate.Subject -notmatch $SignerPattern) {
            throw "The downloaded MSI signer '$($signature.SignerCertificate.Subject)' does not match the approved signer pattern."
        }

        Move-Item -LiteralPath $temporaryPath -Destination $DestinationPath -Force
        [pscustomobject]@{
            Uri           = $Uri.AbsoluteUri
            Sha256        = $actualHash
            SignerSubject = $signature.SignerCertificate.Subject
        }
    }
    catch {
        Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
        throw
    }
}

if ($sourceMode -eq 'Latest') {
    $downloadPageUri = if ($configuration.DownloadPageUri) { [uri]$configuration.DownloadPageUri } else { [uri]'https://www.parallels.com/products/ras/download/client/' }
    $msiUri = Get-ParallelsLatestMsiUri -DownloadPageUri $downloadPageUri
    $download = Save-ValidatedParallelsMsi -Uri $msiUri -DestinationPath $msiPath -SignerPattern $expectedSignerPattern
}
else {
    if ([string]::IsNullOrWhiteSpace([string]$configuration.PinnedMsiUri) -or [string]$configuration.PinnedMsiUri -match '^REPLACE_WITH_') {
        throw 'Pinned SourceMode requires PinnedMsiUri.'
    }
    if ([string]$configuration.PinnedSha256 -notmatch '^[A-Fa-f0-9]{64}$') {
        throw 'Pinned SourceMode requires a 64-character PinnedSha256 value.'
    }
    $download = Save-ValidatedParallelsMsi -Uri ([uri]$configuration.PinnedMsiUri) -DestinationPath $msiPath -RequiredSha256 ([string]$configuration.PinnedSha256) -SignerPattern $expectedSignerPattern
}
Write-Output "Validated Parallels installer: $($download.Uri) [$($download.Sha256)]"
if ($DownloadOnly) {
    Write-Output $download
    return
}

$alias = [Security.SecurityElement]::Escape([string]$configuration.Alias)
$server = [Security.SecurityElement]::Escape([string]$configuration.Server)
$rasConfiguration = @"
<RootXML xmlns:dt="urn:schemas-microsoft-com:datatypes"><Alias dt:dt="string">$alias</Alias><Conn0000><Mode dt:dt="ui4">2</Mode><Server dt:dt="string">$server</Server><ServerPort dt:dt="ui4">$port</ServerPort><tmpssl dt:dt="ui4">$port</tmpssl></Conn0000><Domain dt:dt="string"/><Password dt:dt="string"/><SSO dt:dt="ui4">0</SSO><SharedDeviceMode dt:dt="ui4">1</SharedDeviceMode><Theme dt:dt="string"/><UserName dt:dt="string"/></RootXML>
"@

$xmlPath = Join-Path $workingRoot 'RASConfig.xml'
$rasConfiguration | Set-Content -LiteralPath $xmlPath -Encoding UTF8

$arguments = "/qn /norestart /i `"$msiPath`" SHAREDDEVICE=`"1:import:$xmlPath`""
$process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -notin @(0, 3010)) { throw "Parallels RAS Client installation failed with exit code $($process.ExitCode)." }
exit $process.ExitCode
