function New-NSPPrinterApp {
    <#
    .SYNOPSIS
        Generates a self-contained printer-driver app or a queue app that depends on one.
    .EXAMPLE
        New-NSPPrinterApp -RepoRoot C:\GitRepos\NSP-IntuneApps -Interactive
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [ValidateSet('Driver','Queue')][string]$Mode = 'Queue',
        [string]$Name,
        [string]$DriverName,
        [string]$InfRelativePath,
        [string]$DriverArchivePath,
        [string]$ReleaseManifestPath,
        [string]$HostAddress,
        [string]$PortName,
        [string]$DriverAppName,
        [ValidateSet('Unchanged','Color','Monochrome')][string]$Color = 'Unchanged',
        [ValidateSet('Unchanged','OneSided','TwoSidedLongEdge','TwoSidedShortEdge')][string]$Duplex = 'Unchanged',
        [string]$OutputRoot,
        [switch]$Interactive,
        [switch]$Force
    )

    if ($Interactive) {
        Write-Host 'Printer app wizard' -ForegroundColor Cyan
        Write-Host '[1] Driver package - one reusable vendor/model driver (default)'
        Write-Host '[2] Printer queue - one named printer, port, and preferences'
        $modeChoice = Read-NSPMenuChoice -Prompt '1. App type' -Allowed @('1','2') -Default '1'
        $Mode = if ($modeChoice -eq '2') { 'Queue' } else { 'Driver' }
        if ($Mode -eq 'Driver') {
            Write-Host 'Example name: Canon Generic Plus UFR II Driver'
            if (-not $Name) { $Name = Read-Host '2. Friendly app name' }
            Write-Host 'Example Windows driver name: Canon Generic Plus UFR II'
            if (-not $DriverName) { $DriverName = Read-Host '3. Exact Windows printer-driver name' }
            Write-Host '[1] Local driver ZIP (default)'
            Write-Host '[2] Pinned private GitHub Release manifest'
            $sourceChoice = Read-NSPMenuChoice -Prompt '4. Driver source' -Allowed @('1','2') -Default '1'
            if ($sourceChoice -eq '2') {
                Write-Host 'Example: Artifacts\PrinterDrivers\Canon-UFRII.release.json'
                if (-not $ReleaseManifestPath) { $ReleaseManifestPath = Read-Host '5. Manifest path' }
            } else {
                Write-Host 'Example: C:\Temp\Canon-UFRII.zip'
                if (-not $DriverArchivePath) { $DriverArchivePath = Read-Host '5. Driver ZIP path' }
            }
            Write-Host 'Example: Driver\x64\CNLB0MA64.INF'
            Write-Host 'For a release manifest, press Enter to use its InfRelativePath.'
            if (-not $InfRelativePath) { $InfRelativePath = Read-Host '6. INF path inside the ZIP' }
        } else {
            Write-Host 'Example name: Main Office Copier'
            if (-not $Name) { $Name = Read-Host '2. Printer queue name shown to users' }
            Write-Host 'Example address: 192.0.2.25 or printer.example.com'
            if (-not $HostAddress) { $HostAddress = Read-Host '3. Printer IP address or DNS name' }
            Write-Host 'Example exact driver: Canon Generic Plus UFR II'
            if (-not $DriverName) { $DriverName = Read-Host '4. Exact Windows printer-driver name' }
            Write-Host 'Example dependency app: Canon Generic Plus UFR II Driver'
            if (-not $DriverAppName) { $DriverAppName = Read-Host '5. Driver app display name' }
            Write-Host '[1] Leave color unchanged (default)  [2] Color  [3] Monochrome'
            $colorChoice = Read-NSPMenuChoice -Prompt '6. Color default' -Allowed @('1','2','3') -Default '1'
            $Color = @{ '1'='Unchanged'; '2'='Color'; '3'='Monochrome' }[$colorChoice]
            Write-Host '[1] Leave duplex unchanged (default)  [2] One-sided  [3] Two-sided, long edge  [4] Two-sided, short edge'
            $duplexChoice = Read-NSPMenuChoice -Prompt '7. Duplex default' -Allowed @('1','2','3','4') -Default '1'
            $Duplex = @{ '1'='Unchanged'; '2'='OneSided'; '3'='TwoSidedLongEdge'; '4'='TwoSidedShortEdge' }[$duplexChoice]
        }
    }

    if ($ReleaseManifestPath) {
        $ReleaseManifestPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ReleaseManifestPath)
        if (-not (Test-Path -LiteralPath $ReleaseManifestPath -PathType Leaf)) { throw "Release manifest was not found: $ReleaseManifestPath" }
        $manifest = Get-Content -LiteralPath $ReleaseManifestPath -Raw | ConvertFrom-Json
        if (-not $DriverName) { $DriverName = [string]$manifest.DriverName }
        if (-not $InfRelativePath) { $InfRelativePath = [string]$manifest.InfRelativePath }
        $DriverArchivePath = (Get-NSPReleaseAsset -ManifestPath $ReleaseManifestPath).FullName
    }
    if ([string]::IsNullOrWhiteSpace($Name)) { throw 'Name is required.' }
    if ([string]::IsNullOrWhiteSpace($DriverName)) { throw 'DriverName is required and must exactly match the Windows printer-driver name.' }
    if (-not $OutputRoot) { $OutputRoot = if (Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot) { Join-Path $RepoRoot 'Config\Local\GeneratedApps' } else { Join-Path $RepoRoot 'Apps' } }

    if ($Mode -eq 'Driver') {
        if ([string]::IsNullOrWhiteSpace($InfRelativePath)) { throw 'InfRelativePath is required for a driver app.' }
        if ([IO.Path]::IsPathRooted($InfRelativePath) -or $InfRelativePath -match '(^|[\\/])\.\.([\\/]|$)') { throw 'InfRelativePath must be a safe path within the driver ZIP.' }
        if ([string]::IsNullOrWhiteSpace($DriverArchivePath) -or -not (Test-Path -LiteralPath $DriverArchivePath -PathType Leaf)) { throw "DriverArchivePath was not found: $DriverArchivePath" }
        if ([IO.Path]::GetExtension($DriverArchivePath) -ne '.zip') { throw 'DriverArchivePath must be a ZIP file.' }
    } else {
        if ([string]::IsNullOrWhiteSpace($HostAddress)) { throw 'HostAddress is required for a queue app.' }
        if ([string]::IsNullOrWhiteSpace($DriverAppName)) { throw 'DriverAppName is required so Intune can install the driver dependency first.' }
        if (-not $PortName) { $PortName = 'TCP_' + ($HostAddress -replace '[^A-Za-z0-9_.-]', '_') }
    }

    $safeName = ($Name -replace '[^A-Za-z0-9_-]', '')
    if ([string]::IsNullOrWhiteSpace($safeName)) { throw 'Name did not contain any filename-safe characters.' }
    $id = "Printer$($Mode)$safeName"
    $appRoot = Join-Path $OutputRoot $id
    if ((Test-Path -LiteralPath $appRoot) -and -not $Force) { throw "Destination already exists: $appRoot. Use -Force to replace generated files." }
    if (-not $PSCmdlet.ShouldProcess($appRoot, "Generate printer $Mode app for $Name")) { return }

    $templateRoot = Join-Path $RepoRoot "Templates\Printers\$Mode"
    $source = Join-Path $appRoot 'Source'
    $detect = Join-Path $appRoot 'Detect'
    New-Item -ItemType Directory -Path $source -Force | Out-Null
    New-Item -ItemType Directory -Path $detect -Force | Out-Null
    Get-ChildItem -LiteralPath (Join-Path $templateRoot 'Source') -File -Filter 'Install-*.ps1' | Copy-Item -Destination $source -Force
    Get-ChildItem -LiteralPath (Join-Path $templateRoot 'Source') -File -Filter 'Uninstall-*.ps1' | Copy-Item -Destination $source -Force
    Get-ChildItem -LiteralPath (Join-Path $templateRoot 'Detect') -File -Filter 'Detect-*.ps1' | Copy-Item -Destination $detect -Force

    if ($Mode -eq 'Driver') {
        Copy-Item -LiteralPath $DriverArchivePath -Destination (Join-Path $source 'Driver.zip') -Force
        $archiveHash = (Get-FileHash -LiteralPath $DriverArchivePath -Algorithm SHA256).Hash
        $config = [ordered]@{ Id=$id; DisplayName=$Name; DriverName=$DriverName; InfRelativePath=$InfRelativePath; SourceArchiveSha256=$archiveHash }
        $description = "Installs the Windows printer driver '$DriverName' from a hash-recorded source archive."
    } else {
        $config = [ordered]@{ Id=$id; PrinterName=$Name; HostAddress=$HostAddress; PortName=$PortName; DriverName=$DriverName; DriverAppName=$DriverAppName; Color=$Color; Duplex=$Duplex }
        $description = "Installs the managed printer queue '$Name' using the '$DriverName' driver."
    }
    $configJson = $config | ConvertTo-Json -Depth 5
    $configFile = "Printer$Mode.config.json"
    $configJson | Set-Content -LiteralPath (Join-Path $source $configFile) -Encoding UTF8
    $configJson | Set-Content -LiteralPath (Join-Path $detect $configFile) -Encoding UTF8

    $escapedName = $Name.Replace("'", "''")
    $escapedDescription = $description.Replace("'", "''")
    $dependency = if ($Mode -eq 'Queue') {
        $escapedDependency = $DriverAppName.Replace("'", "''")
        "`$VariableConfig.AppDependency = @{ AppName='$escapedDependency'; DependencyType='AutoInstall' }"
    } else { '' }
    $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = '$escapedName'
`$VariableConfig.Description = '$escapedDescription'
`$VariableConfig.Publisher = 'Network Systems Plus, Inc.'
`$VariableConfig.IsFeatured = `$false
`$VariableConfig.Category = @('Printers')
`$VariableConfig.SetupType = 'PoSH'
`$VariableConfig.InstallExperience = 'system'
`$VariableConfig.RestartExperience = 'suppress'
`$VariableConfig.REQ_Architecture = 'All'
`$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
`$VariableConfig.DetectionStyle = 'Script'
`$VariableConfig.DetectScript_Filter = 'Detect-*.ps1'
`$VariableConfig.SetupFile_Filter = 'Install-*.ps1'
`$VariableConfig.PoSH = @{ Sign_SourceFilter='*.ps1'; UninstallFile_Filter='Uninstall-*.ps1' }
`$VariableConfig.EnforceSignature_Detection = `$true
`$VariableConfig.RunAs32Bit_Detection = `$false
$dependency
`$VariableConfig.AssignmentColl = @()
"@
    $settingsPath = Join-Path $appRoot "${id}_SplitScriptSettings.ps1"
    Set-Content -LiteralPath $settingsPath -Value $settings -Encoding UTF8
    [pscustomobject]@{ Name=$Name; Mode=$Mode; Id=$id; Path=$appRoot; SettingsPath=$settingsPath; DriverName=$DriverName; HostAddress=$HostAddress; PortName=$PortName }
}
