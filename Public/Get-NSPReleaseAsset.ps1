function Get-NSPReleaseAsset {
    <#
    .SYNOPSIS
        Downloads and verifies a large source artifact from a private GitHub Release.
    .DESCRIPTION
        Uses GitHub CLI authentication so tokens are not stored in app source. The
        manifest must pin a release tag, asset name, and SHA-256 hash.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$ManifestPath,
        [string]$DestinationDirectory
    )

    $manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
    foreach ($required in @('Repository','Tag','AssetName','Sha256')) {
        if ([string]::IsNullOrWhiteSpace([string]$manifest.$required)) { throw "Artifact manifest is missing '$required': $ManifestPath" }
    }
    if (-not $DestinationDirectory) { $DestinationDirectory = Split-Path -Path $ManifestPath -Parent }
    New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
    $destination = Join-Path $DestinationDirectory ([string]$manifest.AssetName)

    if (Test-Path -LiteralPath $destination) {
        $actual = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
        if ($actual -eq ([string]$manifest.Sha256).ToUpperInvariant()) { return Get-Item -LiteralPath $destination }
        throw "Existing asset hash is incorrect: $destination. Remove it explicitly before downloading again."
    }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw 'GitHub CLI is required. Install it and run gh auth login before retrieving private release assets.' }
    if (-not $PSCmdlet.ShouldProcess($destination, "Download $($manifest.AssetName) from $($manifest.Repository) release $($manifest.Tag)")) { return }

    & gh release download ([string]$manifest.Tag) --repo ([string]$manifest.Repository) --pattern ([string]$manifest.AssetName) --dir $DestinationDirectory
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $destination)) { throw "GitHub release download failed for $($manifest.AssetName)." }
    $hash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
    if ($hash -ne ([string]$manifest.Sha256).ToUpperInvariant()) {
        Remove-Item -LiteralPath $destination -Force
        throw "Downloaded asset failed SHA-256 verification and was removed. Expected $($manifest.Sha256); received $hash."
    }
    Get-Item -LiteralPath $destination
}
