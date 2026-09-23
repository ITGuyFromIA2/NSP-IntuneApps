function New-NSPParallelsClientApp {
    <#
    .SYNOPSIS
        Generates a client-specific Parallels RAS Client connection app.
    .DESCRIPTION
        Copies the generic install/uninstall/detect implementation from Apps\ParallelsClient
        (Source\DownloadInstall_ParallelsClient.ps1 resolves and signature-validates the latest
        official MSI at endpoint install time; Detect\Detect_ParallelsClient.ps1 is Authenticode-
        signed and copied byte-for-byte, never regenerated as a string literal, so the signature
        stays valid) and writes a real, filled-in Source\ParallelsConnection.config.psd1
        (Alias/Server/Port/SourceMode, plus PinnedMsiUri/PinnedSha256 when SourceMode is Pinned)
        and this instance's own settings file - the only genuinely per-client inputs. Defaults to
        Apps\ (deployable) unless run from the public upstream repo itself, where it writes to
        the ignored local generation area instead so client-specific values never reach that
        catalog. Pass -OutputRoot explicitly to override either default.

        This addresses only the "expose these inputs through a guided generator" item on
        Apps\ParallelsClient\README.md's checklist. The other listed items (disposable-VM
        resolver re-validation, comparing a real shared-device connection export, a version-
        aware detection contract, and full install/upgrade/uninstall testing) need a live VM and
        a real Parallels client and are not something a generator can complete - the reference
        Apps\ParallelsClient app itself stays RequiresRepair until an operator finishes those.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [string]$Alias,
        [string]$Server,
        [int]$Port = 443,
        [ValidateSet('Latest', 'Pinned')][string]$SourceMode = 'Latest',
        [string]$PinnedMsiUri,
        [string]$PinnedSha256,
        [string]$ExpectedSignerPattern = '(?i)Parallels|Alludo',
        [string]$OutputRoot,
        [switch]$Interactive,
        [switch]$Force
    )

    if ($Interactive) {
        Write-Host 'Parallels RAS Client configuration wizard' -ForegroundColor Cyan
        Write-Host 'Example alias: Contoso RAS'
        if (-not $Alias) { $Alias = Read-Host '1. Connection alias' }
        Write-Host 'Example gateway: ras.contoso.com'
        if (-not $Server) { $Server = Read-Host '2. RAS gateway (server) address' }
        $portInput = Read-Host '3. Port [443]'
        if ($portInput) { $Port = [int]$portInput }
        Write-Host '[1] Latest - resolve the current official x64 MSI at install time (default)'
        Write-Host '[2] Pinned - use one explicit, hash-verified MSI'
        $sourceModeChoice = Read-NSPMenuChoice -Prompt '4. Source mode' -Allowed @('1', '2') -Default '1'
        $SourceMode = if ($sourceModeChoice -eq '2') { 'Pinned' } else { 'Latest' }
        if ($SourceMode -eq 'Pinned') {
            Write-Host 'Example: https://download.parallels.com/ras/19.x/19.2.24076/RASClient-x64-19.2.24076.msi'
            if (-not $PinnedMsiUri) { $PinnedMsiUri = Read-Host '5. Pinned MSI URI' }
            if (-not $PinnedSha256) { $PinnedSha256 = Read-Host '6. Pinned MSI SHA-256' }
        }
    }

    if ([string]::IsNullOrWhiteSpace($Alias)) { throw 'Alias is required.' }
    if ($Alias -match '[\[\]\\/"\r\n]') { throw 'Alias cannot contain brackets, slash, backslash, quote, or newline characters.' }
    if ([string]::IsNullOrWhiteSpace($Server)) { throw 'Server is required.' }
    if ($Port -lt 1 -or $Port -gt 65535) { throw 'Port must be between 1 and 65535.' }
    if ($SourceMode -eq 'Pinned') {
        if ([string]::IsNullOrWhiteSpace($PinnedMsiUri)) { throw 'PinnedMsiUri is required when SourceMode is Pinned.' }
        try { $pinnedUri = [uri]$PinnedMsiUri } catch { throw "PinnedMsiUri must be an absolute HTTPS URL. $($_.Exception.Message)" }
        if (-not $pinnedUri.IsAbsoluteUri -or $pinnedUri.Scheme -ne 'https') { throw 'PinnedMsiUri must be an absolute HTTPS URL.' }
        if ([string]::IsNullOrWhiteSpace($PinnedSha256) -or $PinnedSha256 -notmatch '^[A-Fa-f0-9]{64}$') { throw 'PinnedSha256 must be a 64-character hexadecimal SHA-256 hash when SourceMode is Pinned.' }
    }
    if (-not $OutputRoot) { $OutputRoot = if (Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot) { Join-Path $RepoRoot 'Config\Local\GeneratedApps' } else { Join-Path $RepoRoot 'Apps' } }

    $safeName = ($Alias -replace '[^A-Za-z0-9_-]', '')
    if ([string]::IsNullOrWhiteSpace($safeName)) { throw 'Alias did not contain any filename-safe characters.' }
    $id = "ParallelsClient$safeName"
    $appRoot = Join-Path $OutputRoot $id
    if ((Test-Path -LiteralPath $appRoot) -and -not $Force) { throw "Destination already exists: $appRoot. Use -Force to replace generated files." }
    if (-not $PSCmdlet.ShouldProcess($appRoot, "Generate Parallels RAS Client app for $Alias")) { return }

    $templateRoot = Join-Path $RepoRoot 'Apps\ParallelsClient'
    if (-not (Test-Path -LiteralPath (Join-Path $templateRoot 'Detect\Detect_ParallelsClient.ps1'))) {
        throw "Reference implementation not found under $templateRoot. This generator copies its Source/Detect scripts and cannot run without them."
    }
    $sourceDestination = Join-Path $appRoot 'Source'
    $detectDestination = Join-Path $appRoot 'Detect'
    New-Item -ItemType Directory -Path $sourceDestination -Force | Out-Null
    New-Item -ItemType Directory -Path $detectDestination -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Source\DownloadInstall_ParallelsClient.ps1') -Destination $sourceDestination -Force
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Source\Uninstall_ParallelsClient.ps1') -Destination $sourceDestination -Force
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Detect\Detect_ParallelsClient.ps1') -Destination $detectDestination -Force

    $escapedAlias = $Alias.Replace("'", "''")
    $escapedServer = $Server.Replace("'", "''")
    $escapedSignerPattern = $ExpectedSignerPattern.Replace("'", "''")
    $escapedPinnedMsiUri = if ($PinnedMsiUri) { $PinnedMsiUri.Replace("'", "''") } else { '' }
    $escapedPinnedSha256 = if ($PinnedSha256) { $PinnedSha256.Replace("'", "''") } else { '' }
    $configLines = @(
        '@{'
        "    Alias                 = '$escapedAlias'"
        "    Server                = '$escapedServer'"
        "    Port                  = $Port"
        ''
        "    SourceMode            = '$SourceMode'"
        "    DownloadPageUri       = 'https://www.parallels.com/products/ras/download/client/'"
        "    PinnedMsiUri          = '$escapedPinnedMsiUri'"
        "    PinnedSha256          = '$escapedPinnedSha256'"
        ''
        "    ExpectedSignerPattern = '$escapedSignerPattern'"
        '}'
    )
    $configPath = Join-Path $sourceDestination 'ParallelsConnection.config.psd1'
    Set-Content -LiteralPath $configPath -Value $configLines -Encoding UTF8

    $settingsAlias = $Alias.Replace("'", "''")
    $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = 'Parallels RAS Client - $settingsAlias'
`$VariableConfig.Description = 'Resolves and validates the latest official Parallels RAS Client MSI at endpoint install time, then imports the $settingsAlias connection.'
`$VariableConfig.Publisher = 'Network Systems Plus, Inc.'
`$VariableConfig.IsFeatured = `$false
`$VariableConfig.Category = @('Business','Productivity')
`$VariableConfig.SetupType = 'PoSH'
`$VariableConfig.InstallExperience = 'system'
`$VariableConfig.RestartExperience = 'basedOnReturnCode'
`$VariableConfig.REQ_Architecture = 'All'
`$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
`$VariableConfig.DetectionStyle = 'Script'
`$VariableConfig.DetectScript_Filter = 'Detect_*.ps1'
`$VariableConfig.SetupFile_Filter = 'Download*.ps1'
`$VariableConfig.PoSH = @{ Sign_SourceFilter = '*.ps1'; UninstallFile_Filter = 'Uninstall*.ps1' }
`$VariableConfig.EnforceSignature_Detection = `$true
`$VariableConfig.RunAs32Bit_Detection = `$false
`$VariableConfig.AssignmentColl = @()
"@
    $settingsPath = Join-Path $appRoot "${id}_SplitScriptSettings.ps1"
    Set-Content -LiteralPath $settingsPath -Value $settings -Encoding UTF8

    [pscustomobject]@{
        Name         = $Alias
        Id           = $id
        Path         = $appRoot
        SettingsPath = $settingsPath
        Server       = $Server
        Port         = $Port
        SourceMode   = $SourceMode
    }
}
