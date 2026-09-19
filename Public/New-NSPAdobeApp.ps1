function New-NSPAdobeApp {
    <#
    .SYNOPSIS
        Generates a self-contained Adobe Acrobat/Reader Intune app from an operator-resolved package.
    .DESCRIPTION
        Package discovery and download happen on the operator workstation. The generated endpoint
        package contains the selected, hash-recorded payload and has no Evergreen or PSGallery dependency.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [ValidateSet('UnifiedBootstrapper','StandaloneReader','AdminConsole')]
        [string]$PackageKind = 'UnifiedBootstrapper',
        [ValidateSet('x64','x86')][string]$Architecture = 'x64',
        [string]$PackagePath,
        [switch]$ResolveReaderWithEvergreen,
        [string]$Language = 'English',
        [string]$Version,
        [string]$InstallerRelativePath,
        [string[]]$InstallArguments,
        [string]$DisplayName,
        [string]$OutputRoot,
        [switch]$Interactive,
        [switch]$Force
    )

    if ($Interactive) {
        Write-Host 'Adobe package wizard' -ForegroundColor Cyan
        Write-Host '[1] Unified 64-bit Acrobat/Reader bootstrapper (default)'
        Write-Host '    One installation; Reader, Standard, or Pro features follow the user entitlement.'
        Write-Host '[2] Standalone Reader package'
        Write-Host '[3] Adobe Admin Console package'
        $kindChoice = Read-NSPMenuChoice -Prompt '1. Package type' -Allowed @('1','2','3') -Default '1'
        $PackageKind = @{ '1'='UnifiedBootstrapper'; '2'='StandaloneReader'; '3'='AdminConsole' }[$kindChoice]
        if ($PackageKind -eq 'StandaloneReader') {
            Write-Host '[1] 64-bit (default)  [2] 32-bit legacy/compatibility requirement'
            $Architecture = if ((Read-NSPMenuChoice -Prompt '2. Architecture' -Allowed @('1','2') -Default '1') -eq '2') { 'x86' } else { 'x64' }
            Write-Host '[1] Supply a package already downloaded and reviewed (default)'
            Write-Host '[2] Resolve the current package with Evergreen on this operator workstation'
            $ResolveReaderWithEvergreen = (Read-NSPMenuChoice -Prompt '3. Package source' -Allowed @('1','2') -Default '1') -eq '2'
        } else {
            $Architecture = 'x64'
        }
        if (-not $ResolveReaderWithEvergreen -and -not $PackagePath) {
            Write-Host 'Example: C:\Staging\AdobeAcrobat.zip, an installer EXE/MSI, or an extracted package directory'
            $PackagePath = Read-Host '4. Reviewed package path'
        }
        if (-not $InstallerRelativePath) {
            Write-Host 'For a ZIP/directory, example: AdobeAcrobat\Setup.exe. Press Enter to auto-detect one Setup.exe.'
            $InstallerRelativePath = Read-Host '5. Installer path inside the package (optional)'
        }
    }

    if ($PackageKind -eq 'UnifiedBootstrapper' -and $Architecture -ne 'x64') {
        throw 'Adobe UnifiedBootstrapper is 64-bit. Use StandaloneReader only for an intentional 32-bit Reader requirement.'
    }
    if ($ResolveReaderWithEvergreen -and $PackageKind -ne 'StandaloneReader') {
        throw 'Evergreen resolution is supported only for StandaloneReader. Licensed/unified packages must be supplied from an approved Adobe source.'
    }
    if ($ResolveReaderWithEvergreen -and $PackagePath) {
        throw 'Choose either PackagePath or ResolveReaderWithEvergreen, not both.'
    }
    if (-not $OutputRoot) { $OutputRoot = Join-Path $RepoRoot 'Config\Local\GeneratedApps' }

    $temporaryDownload = $null
    try {
        if ($ResolveReaderWithEvergreen) {
            $evergreenCommand = Get-Command Get-EvergreenApp -ErrorAction SilentlyContinue
            if (-not $evergreenCommand) {
                throw 'Get-EvergreenApp is unavailable. Install/import Evergreen on the operator workstation or supply PackagePath. Evergreen is never required on endpoints.'
            }
            $candidates = @(Get-EvergreenApp -Name AdobeAcrobatReaderDC | Where-Object {
                $_.Architecture -eq $Architecture -and ($_.Language -eq $Language -or $_.Language -eq 'MUI')
            } | Sort-Object { try { [version]$_.Version } catch { [version]'0.0' } } -Descending)
            if ($candidates.Count -eq 0) { throw "Evergreen returned no Adobe Reader $Architecture package for language '$Language'." }
            $selected = $candidates[0]
            if (-not $selected.URI) { throw 'The selected Evergreen record has no URI.' }
            $downloadName = [IO.Path]::GetFileName(([uri]$selected.URI).AbsolutePath)
            if (-not $downloadName) { $downloadName = "AdobeReader-$Architecture.exe" }
            $temporaryDownload = Join-Path ([IO.Path]::GetTempPath()) ("NSP-Adobe-{0}-{1}" -f [guid]::NewGuid(), $downloadName)
            Invoke-WebRequest -Uri $selected.URI -OutFile $temporaryDownload -UseBasicParsing
            $PackagePath = $temporaryDownload
            if (-not $Version) { $Version = [string]$selected.Version }
        }

        if ([string]::IsNullOrWhiteSpace($PackagePath)) { throw 'PackagePath is required unless ResolveReaderWithEvergreen is selected.' }
        $PackagePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($PackagePath)
        if (-not (Test-Path -LiteralPath $PackagePath)) { throw "Adobe package was not found: $PackagePath" }

        if (-not $DisplayName) {
            $DisplayName = switch ($PackageKind) {
                'UnifiedBootstrapper' { 'Adobe Acrobat and Reader - Unified 64-bit' }
                'StandaloneReader' { "Adobe Acrobat Reader - $($Architecture.Replace('x',''))-bit" }
                'AdminConsole' { 'Adobe Acrobat - Admin Console Package' }
            }
        }
        if (-not $InstallArguments) {
            $InstallArguments = if ($PackageKind -eq 'AdminConsole') { @('--silent') } else { @('/sAll','/rs') }
        }

        $safeName = ($DisplayName -replace '[^A-Za-z0-9_-]', '')
        if (-not $safeName) { throw 'DisplayName did not contain any filename-safe characters.' }
        $id = "Adobe$safeName"
        $appRoot = Join-Path $OutputRoot $id
        if ((Test-Path -LiteralPath $appRoot) -and -not $Force) { throw "Destination already exists: $appRoot. Use -Force to replace generated files." }
        if (-not $PSCmdlet.ShouldProcess($appRoot, "Generate $DisplayName from $PackagePath")) { return }

        $sourceRoot = Join-Path $appRoot 'Source'
        $detectRoot = Join-Path $appRoot 'Detect'
        $payloadRoot = Join-Path $sourceRoot 'Payload'
        New-Item -ItemType Directory -Path $payloadRoot -Force | Out-Null
        New-Item -ItemType Directory -Path $detectRoot -Force | Out-Null
        $templateRoot = Join-Path $RepoRoot 'Templates\Adobe'
        Copy-Item -LiteralPath (Join-Path $templateRoot 'Source\Install-Adobe.ps1') -Destination $sourceRoot -Force
        Copy-Item -LiteralPath (Join-Path $templateRoot 'Source\Uninstall-Adobe.ps1') -Destination $sourceRoot -Force
        Copy-Item -LiteralPath (Join-Path $templateRoot 'Detect\Detect-Adobe.ps1') -Destination $detectRoot -Force

        $packageItem = Get-Item -LiteralPath $PackagePath
        if ($packageItem.PSIsContainer) {
            Get-ChildItem -LiteralPath $PackagePath -Force | Copy-Item -Destination $payloadRoot -Recurse -Force
            $payloadKind = 'Directory'
            if (-not $InstallerRelativePath) {
                $setupFiles = @(Get-ChildItem -LiteralPath $payloadRoot -Recurse -File -Filter 'Setup.exe')
                if ($setupFiles.Count -ne 1) { throw 'A package directory must contain exactly one Setup.exe or specify InstallerRelativePath.' }
                $InstallerRelativePath = $setupFiles[0].FullName.Substring($payloadRoot.Length).TrimStart('\','/')
            }
        } else {
            Copy-Item -LiteralPath $PackagePath -Destination $payloadRoot -Force
            $payloadFile = Join-Path $payloadRoot $packageItem.Name
            if ($packageItem.Extension -eq '.zip') {
                $payloadKind = 'Archive'
                if (-not $InstallerRelativePath) {
                    Add-Type -AssemblyName System.IO.Compression.FileSystem
                    $archive = [IO.Compression.ZipFile]::OpenRead($PackagePath)
                    try {
                        $setups = @($archive.Entries | Where-Object { [IO.Path]::GetFileName($_.FullName) -ieq 'Setup.exe' })
                        if ($setups.Count -ne 1) { throw 'A ZIP package must contain exactly one Setup.exe or specify InstallerRelativePath.' }
                        $InstallerRelativePath = $setups[0].FullName
                    } finally { $archive.Dispose() }
                }
            } else {
                $payloadKind = 'File'
                if (-not $InstallerRelativePath) { $InstallerRelativePath = $packageItem.Name }
            }
        }
        if ([IO.Path]::IsPathRooted($InstallerRelativePath) -or $InstallerRelativePath -match '(^|[\\/])\.\.([\\/]|$)') {
            throw 'InstallerRelativePath must remain within the supplied package.'
        }

        $manifest = @(Get-ChildItem -LiteralPath $payloadRoot -Recurse -File | Sort-Object FullName | ForEach-Object {
            [ordered]@{
                Path = $_.FullName.Substring($payloadRoot.Length).TrimStart('\','/').Replace('\','/')
                Sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
            }
        })
        $displayPattern = if ($PackageKind -eq 'StandaloneReader' -and $Architecture -eq 'x86') { 'Adobe Acrobat Reader*' } else { 'Adobe Acrobat*' }
        $config = [ordered]@{
            Id=$id; DisplayName=$DisplayName; PackageKind=$PackageKind; Architecture=$Architecture
            Version=$Version; InstallerRelativePath=$InstallerRelativePath.Replace('\','/'); InstallArguments=@($InstallArguments)
            DisplayNamePattern=$displayPattern; PayloadKind=$payloadKind; PayloadManifest=$manifest
        }
        $configJson = $config | ConvertTo-Json -Depth 8
        $configJson | Set-Content -LiteralPath (Join-Path $sourceRoot 'Adobe.config.json') -Encoding UTF8
        $configJson | Set-Content -LiteralPath (Join-Path $detectRoot 'Adobe.config.json') -Encoding UTF8

        $escapedName = $DisplayName.Replace("'", "''")
        $description = "Installs a build-time resolved, hash-recorded $PackageKind package. Product features follow Adobe licensing and entitlement."
        $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = '$escapedName'
`$VariableConfig.Description = '$description'
`$VariableConfig.Publisher = 'Adobe'
`$VariableConfig.IsFeatured = `$false
`$VariableConfig.Category = @('Business','Productivity')
`$VariableConfig.SetupType = 'PoSH'
`$VariableConfig.InstallExperience = 'system'
`$VariableConfig.RestartExperience = 'basedOnReturnCode'
`$VariableConfig.REQ_Architecture = '$Architecture'
`$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
`$VariableConfig.DetectionStyle = 'Script'
`$VariableConfig.DetectScript_Filter = 'Detect-*.ps1'
`$VariableConfig.SetupFile_Filter = 'Install-*.ps1'
`$VariableConfig.PoSH = @{ Sign_SourceFilter='*.ps1'; UninstallFile_Filter='Uninstall-*.ps1' }
`$VariableConfig.EnforceSignature_Detection = `$true
`$VariableConfig.RunAs32Bit_Detection = `$false
`$VariableConfig.AssignmentColl = @()
"@
        $settingsPath = Join-Path $appRoot "${id}_SplitScriptSettings.ps1"
        Set-Content -LiteralPath $settingsPath -Value $settings -Encoding UTF8
        [pscustomobject]@{ Name=$DisplayName; Id=$id; Path=$appRoot; SettingsPath=$settingsPath; PackageKind=$PackageKind; Architecture=$Architecture; Version=$Version }
    } finally {
        if ($temporaryDownload -and (Test-Path -LiteralPath $temporaryDownload)) { Remove-Item -LiteralPath $temporaryDownload -Force }
    }
}
