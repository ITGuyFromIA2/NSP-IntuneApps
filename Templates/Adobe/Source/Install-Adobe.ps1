$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Adobe.config.json') -Raw | ConvertFrom-Json
$payloadRoot = Join-Path $PSScriptRoot 'Payload'

foreach ($item in $config.PayloadManifest) {
    $path = Join-Path $payloadRoot ([string]$item.Path)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Adobe payload file is missing: $($item.Path)" }
    $actualHash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    if ($actualHash -ne [string]$item.Sha256) { throw "Adobe payload hash mismatch: $($item.Path)" }
}

$workingRoot = $payloadRoot
$stagingRoot = $null
try {
    if ($config.PayloadKind -eq 'Archive') {
        $archiveRecord = @($config.PayloadManifest)[0]
        $archivePath = Join-Path $payloadRoot ([string]$archiveRecord.Path)
        $stagingRoot = Join-Path $env:ProgramData ("NSP\Staging\Adobe-{0}" -f [guid]::NewGuid())
        New-Item -ItemType Directory -Path $stagingRoot -Force | Out-Null
        Expand-Archive -LiteralPath $archivePath -DestinationPath $stagingRoot -Force
        $workingRoot = $stagingRoot
    }
    $installer = Join-Path $workingRoot ([string]$config.InstallerRelativePath)
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) { throw "Adobe installer was not found inside the payload: $($config.InstallerRelativePath)" }
    $arguments = @($config.InstallArguments | ForEach-Object { [string]$_ })
    if ([IO.Path]::GetExtension($installer) -ieq '.msi') {
        $arguments = @('/i', ('"{0}"' -f $installer)) + $arguments
        $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
    } else {
        $process = Start-Process -FilePath $installer -ArgumentList $arguments -Wait -PassThru -WorkingDirectory (Split-Path -Path $installer -Parent)
    }
    if ($process.ExitCode -notin @(0,1641,3010)) { throw "Adobe installer failed with exit code $($process.ExitCode)." }
    exit $process.ExitCode
} finally {
    if ($stagingRoot -and (Test-Path -LiteralPath $stagingRoot)) { Remove-Item -LiteralPath $stagingRoot -Recurse -Force }
}
