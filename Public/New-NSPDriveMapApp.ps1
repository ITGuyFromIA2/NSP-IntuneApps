function New-NSPDriveMapApp {
    <#
    .SYNOPSIS
        Generates a self-contained DriveMap app from the upstream template.
    .EXAMPLE
        New-NSPDriveMapApp -RepoRoot C:\GitRepos\NSP-IntuneApps -Interactive
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [string]$Name,
        [ValidatePattern('^[A-Za-z]$')][string]$DriveLetter,
        [string]$Path,
        [string]$OutputRoot,
        [bool]$Persistent = $true,
        [switch]$Interactive,
        [switch]$Force
    )

    if ($Interactive) {
        Write-Host 'Drive map wizard' -ForegroundColor Cyan
        Write-Host 'Example name: Accounting Shared Drive'
        if (-not $Name) { $Name = Read-Host '1. Friendly name' }
        Write-Host 'Example drive letter: S (enter the letter only)'
        if (-not $DriveLetter) { $DriveLetter = Read-Host '2. Drive letter' }
        Write-Host 'Example path: \\files.contoso.com\Accounting'
        if (-not $Path) { $Path = Read-Host '3. UNC path' }
        if (-not $OutputRoot) {
            $defaultHint = if (Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot) { 'Config\Local\GeneratedApps (ignored by Git - this is the public upstream repo)' } else { 'Apps (this repo is not the public upstream, so it is deployable by default)' }
            Write-Host "Default output folder: $defaultHint"
            $enteredRoot = Read-Host '4. Output folder [press Enter for the default]'
            if ($enteredRoot) { $OutputRoot = $enteredRoot }
        }
    }
    if ([string]::IsNullOrWhiteSpace($Name)) { throw 'Name is required.' }
    if ($DriveLetter -notmatch '^[A-Za-z]$') { throw 'DriveLetter must be one letter, such as S.' }
    if ($Path -notmatch '^\\\\[^\\]+\\[^\\]+') { throw 'Path must be a UNC path, such as \\server\share.' }
    if (-not $OutputRoot) { $OutputRoot = if (Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot) { Join-Path $RepoRoot 'Config\Local\GeneratedApps' } else { Join-Path $RepoRoot 'Apps' } }

    $safeName = ($Name -replace '[^A-Za-z0-9_-]', '')
    if ([string]::IsNullOrWhiteSpace($safeName)) { throw 'Name did not contain any filename-safe characters.' }
    $id = "DriveMap$safeName"
    $destination = Join-Path $OutputRoot $id
    if ((Test-Path -LiteralPath $destination) -and -not $Force) { throw "Destination already exists: $destination. Use -Force to replace generated files." }
    if (-not $PSCmdlet.ShouldProcess($destination, "Generate drive-map app for $Name")) { return }

    $templateRoot = Join-Path $RepoRoot 'Templates\DriveMaps'
    $sourceDestination = Join-Path $destination 'Source'
    $detectDestination = Join-Path $destination 'Detect'
    New-Item -ItemType Directory -Path $sourceDestination -Force | Out-Null
    New-Item -ItemType Directory -Path $detectDestination -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Source\Invoke-DriveMap.ps1') -Destination $sourceDestination -Force
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Source\Install-DriveMap.ps1') -Destination $sourceDestination -Force
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Source\Uninstall-DriveMap.ps1') -Destination $sourceDestination -Force
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Detect\Detect-DriveMap.ps1') -Destination $detectDestination -Force

    $config = [ordered]@{ Id=$id; DisplayName=$Name; DriveLetter=$DriveLetter.ToUpperInvariant(); Path=$Path; Persistent=$Persistent; TaskName="NSP Drive Map - $Name" }
    $configJson = $config | ConvertTo-Json -Depth 4
    $configJson | Set-Content -LiteralPath (Join-Path $sourceDestination 'DriveMap.config.json') -Encoding UTF8
    $configJson | Set-Content -LiteralPath (Join-Path $detectDestination 'DriveMap.config.json') -Encoding UTF8

    $escapedName = $Name.Replace("'", "''")
    $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = '$escapedName'
`$VariableConfig.Description = 'Maps $($DriveLetter.ToUpperInvariant()): to the configured network location at user logon.'
`$VariableConfig.Publisher = 'Network Systems Plus, Inc.'
`$VariableConfig.IsFeatured = `$false
`$VariableConfig.Category = @('Productivity')
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
`$VariableConfig.AssignmentColl = @()
"@
    $settingsPath = Join-Path $destination "${id}_SplitScriptSettings.ps1"
    Set-Content -LiteralPath $settingsPath -Value $settings -Encoding UTF8

    [pscustomobject]@{ Name=$Name; Id=$id; Path=$destination; SettingsPath=$settingsPath; DriveLetter=$config.DriveLetter; UncPath=$Path }
}
