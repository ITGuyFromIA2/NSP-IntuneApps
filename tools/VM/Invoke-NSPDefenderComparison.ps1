[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
param(
    [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string[]]$CandidatePath,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
if (-not $OutputPath) {
    $resultRoot = Join-Path $repoRoot 'Config\Local\VMResults'
    New-Item -ItemType Directory -Path $resultRoot -Force | Out-Null
    $OutputPath = Join-Path $resultRoot ("DefenderComparison-{0}.json" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
}

$platformRoot = Join-Path $env:ProgramData 'Microsoft\Windows Defender\Platform'
$defenderCli = Get-ChildItem -LiteralPath $platformRoot -Directory -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending |
    ForEach-Object { Join-Path $_.FullName 'MpCmdRun.exe' } |
    Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
    Select-Object -First 1
if (-not $defenderCli) {
    $legacyCli = Join-Path $env:ProgramFiles 'Windows Defender\MpCmdRun.exe'
    if (Test-Path -LiteralPath $legacyCli -PathType Leaf) { $defenderCli = $legacyCli }
}
if (-not $defenderCli) { throw 'Microsoft Defender command-line scanner was not found.' }

$results = foreach ($path in $CandidatePath) {
    $resolved = (Resolve-Path -LiteralPath $path).Path
    $signature = Get-AuthenticodeSignature -LiteralPath $resolved
    $before = @(Get-MpThreatDetection -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ThreatID -Unique)
    $startedAt = Get-Date
    $exitCode = $null
    if ($PSCmdlet.ShouldProcess($resolved, 'Run a Microsoft Defender custom scan')) {
        $quotedPath = '"{0}"' -f $resolved.Replace('"', '\"')
        $process = Start-Process -FilePath $defenderCli -ArgumentList @('-Scan','-ScanType','3','-File', $quotedPath,'-DisableRemediation') -Wait -PassThru -NoNewWindow
        $exitCode = $process.ExitCode
    }
    $detections = @(Get-MpThreatDetection -ErrorAction SilentlyContinue | Where-Object {
        $_.InitialDetectionTime -ge $startedAt.AddSeconds(-2) -or $_.ThreatID -notin $before
    } | Select-Object ThreatID, ThreatStatusID, InitialDetectionTime, Resources)
    [pscustomobject][ordered]@{
        Path              = $resolved
        Length            = (Get-Item -LiteralPath $resolved).Length
        Sha256            = (Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash
        SignatureStatus   = [string]$signature.Status
        SignerSubject     = if ($signature.SignerCertificate) { $signature.SignerCertificate.Subject } else { $null }
        DefenderExitCode  = $exitCode
        DefenderDetection = @($detections)
    }
}

$report = [pscustomobject][ordered]@{
    CapturedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    ComputerName  = $env:COMPUTERNAME
    Candidates    = @($results)
}
$parent = Split-Path -Path $OutputPath -Parent
if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
$report
Write-Host "Defender comparison: $OutputPath" -ForegroundColor Cyan
