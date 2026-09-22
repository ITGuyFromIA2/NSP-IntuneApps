function Set-NSPAppSignature {
    <#
    .SYNOPSIS
        Signs an app's detection and source scripts with the active NSP code-signing certificate.
    .DESCRIPTION
        Resolves the active certificate by exact configured thumbprint (it must already be
        imported machine-wide; use New-NSPCodeSigningCertificate/-ImportIfMissing for that
        separately, since this stage is expected to run non-interactively). Enumerates the
        app's Detect and Source scripts using the settings file's own filters and signs each
        one, throwing immediately with the offending file and StatusMessage if a signature
        does not come back Valid.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$AppName
    )

    $entry = Get-NSPIntuneAppCatalog -RepoRoot $RepoRoot | Where-Object Name -eq $AppName
    if (-not $entry) { throw "App was not found in the catalog: $AppName" }
    if (-not $entry.SettingsPath) { throw "App does not have one settings file: $AppName" }

    $VariableConfig = $null
    . $entry.SettingsPath

    $certificate = Get-NSPCodeSigningCertificate -RepoRoot $RepoRoot
    $config = Get-NSPCodeSigningConfiguration -RepoRoot $RepoRoot
    $timestampServer = [string]$config.Policy.TimestampServer

    $filesToSign = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    if ([string]$VariableConfig.DetectionStyle -eq 'Script') {
        $detectFilter = Resolve-NSPAppDetectScriptFilter -AppName $AppName -VariableConfig $VariableConfig
        $detectFolder = Join-Path $entry.Path 'Detect'
        foreach ($file in @(Get-ChildItem -LiteralPath $detectFolder -Filter $detectFilter -File -ErrorAction SilentlyContinue)) {
            $filesToSign.Add($file)
        }
    }
    $sourceFilter = [string]$VariableConfig.PoSH.Sign_SourceFilter
    if (-not [string]::IsNullOrWhiteSpace($sourceFilter)) {
        $sourceFolder = Join-Path $entry.Path 'Source'
        foreach ($file in @(Get-ChildItem -LiteralPath $sourceFolder -Filter $sourceFilter -File -ErrorAction SilentlyContinue)) {
            $filesToSign.Add($file)
        }
    }
    if ($filesToSign.Count -eq 0) { throw "No files matched the app's Detect/Source signing filters: $AppName" }

    $signed = [System.Collections.Generic.List[pscustomobject]]::new()
    foreach ($file in $filesToSign) {
        if (-not $PSCmdlet.ShouldProcess($file.FullName, "Sign with certificate $($certificate.Thumbprint)")) { continue }

        $signArguments = @{ FilePath = $file.FullName; Certificate = $certificate }
        if (-not [string]::IsNullOrWhiteSpace($timestampServer)) { $signArguments.TimeStampServer = $timestampServer }
        $signature = Set-AuthenticodeSignature @signArguments
        if ($signature.Status -ne 'Valid') {
            throw "Signing failed for $($file.FullName): $($signature.StatusMessage)"
        }
        $signed.Add([pscustomobject]@{ Path = $file.FullName; Status = $signature.Status })
    }

    [pscustomobject]@{
        AppName     = $AppName
        Thumbprint  = $certificate.Thumbprint
        SignedFiles = @($signed)
    }
}
