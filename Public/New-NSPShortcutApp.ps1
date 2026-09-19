function New-NSPShortcutApp {
    <#
    .SYNOPSIS
        Generates a managed web, browser-specific, or file shortcut app.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [ValidateSet('WebDefault','WebBrowser','File')][string]$Mode = 'WebDefault',
        [string]$Name,
        [string]$Target,
        [ValidateSet('Edge','Chrome')][string]$Browser = 'Edge',
        [string]$Arguments = '',
        [string]$Description = '',
        [string]$IconPath = '',
        [ValidateSet('PublicDesktop','StartMenu')][string]$Destination = 'PublicDesktop',
        [string]$OutputRoot,
        [switch]$Interactive,
        [switch]$Force
    )

    if ($Interactive) {
        Write-Host 'Shortcut wizard' -ForegroundColor Cyan
        Write-Host '[1] Website using the Windows default browser (default)'
        Write-Host '[2] Website forced into Microsoft Edge'
        Write-Host '[3] Website forced into Google Chrome'
        Write-Host '[4] File or program shortcut'
        $typeChoice = Read-NSPMenuChoice -Prompt '1. Shortcut type' -Allowed @('1','2','3','4') -Default '1'
        if ($typeChoice -eq '1') { $Mode = 'WebDefault' }
        elseif ($typeChoice -in @('2','3')) { $Mode = 'WebBrowser'; $Browser = if ($typeChoice -eq '3') { 'Chrome' } else { 'Edge' } }
        else { $Mode = 'File' }
        Write-Host 'Example name: Service Portal'
        if (-not $Name) { $Name = Read-Host '2. Friendly shortcut name' }
        Write-Host $(if ($Mode -like 'Web*') { 'Example target: https://portal.example.com' } else { 'Example target: %ProgramFiles%\Vendor\Application.exe' })
        if (-not $Target) { $Target = Read-Host '3. Target' }
        if ($Mode -eq 'File' -and -not $Arguments) {
            Write-Host 'Example arguments: --mode managed (optional)'
            $Arguments = Read-Host '4. Arguments'
        }
        if (-not $Description) { $Description = Read-Host '5. Shortcut description (optional)' }
        Write-Host '[1] Public Desktop (default)'
        Write-Host '[2] Start Menu'
        $destinationChoice = Read-NSPMenuChoice -Prompt '6. Shortcut location' -Allowed @('1','2') -Default '1'
        $Destination = if ($destinationChoice -eq '2') { 'StartMenu' } else { 'PublicDesktop' }
    }

    if ([string]::IsNullOrWhiteSpace($Name)) { throw 'Name is required.' }
    if ([string]::IsNullOrWhiteSpace($Target)) { throw 'Target is required.' }
    if ($Mode -like 'Web*') {
        try { $targetUri = [uri]$Target } catch { throw 'Web targets must be absolute HTTP or HTTPS URLs.' }
        if (-not $targetUri.IsAbsoluteUri -or $targetUri.Scheme -notin @('http','https')) { throw 'Web targets must be absolute HTTP or HTTPS URLs.' }
        $Target = $targetUri.AbsoluteUri
    }
    if (-not $Description) { $Description = if ($Mode -like 'Web*') { "Opens $Target" } else { "Opens $Target" } }
    if (-not $OutputRoot) { $OutputRoot = Join-Path $RepoRoot 'Config\Local\GeneratedApps' }

    $safeName = ($Name -replace '[^A-Za-z0-9_-]', '')
    if (-not $safeName) { throw 'Name did not contain any filename-safe characters.' }
    $id = "Shortcut$safeName"
    $appRoot = Join-Path $OutputRoot $id
    if ((Test-Path -LiteralPath $appRoot) -and -not $Force) { throw "Destination already exists: $appRoot. Use -Force to replace generated files." }
    if (-not $PSCmdlet.ShouldProcess($appRoot, "Generate shortcut app for $Name")) { return }

    $sourceRoot = Join-Path $appRoot 'Source'
    $detectRoot = Join-Path $appRoot 'Detect'
    New-Item -ItemType Directory -Path $sourceRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $detectRoot -Force | Out-Null
    $templateRoot = Join-Path $RepoRoot 'Templates\Shortcuts'
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Source\Install-Shortcut.ps1') -Destination $sourceRoot -Force
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Source\Uninstall-Shortcut.ps1') -Destination $sourceRoot -Force
    Copy-Item -LiteralPath (Join-Path $templateRoot 'Detect\Detect-Shortcut.ps1') -Destination $detectRoot -Force

    $extension = if ($Mode -eq 'WebDefault') { '.url' } else { '.lnk' }
    $fileName = ($Name -replace '[<>:"/\\|?*]', '-') + $extension
    $config = [ordered]@{
        Id=$id; DisplayName=$Name; FileName=$fileName; Mode=$Mode; Target=$Target; Browser=$Browser
        Arguments=$Arguments; Description=$Description; IconPath=$IconPath; Destination=$Destination
    }
    $configJson = $config | ConvertTo-Json -Depth 4
    $configJson | Set-Content -LiteralPath (Join-Path $sourceRoot 'Shortcut.config.json') -Encoding UTF8
    $configJson | Set-Content -LiteralPath (Join-Path $detectRoot 'Shortcut.config.json') -Encoding UTF8

    $escapedName = $Name.Replace("'", "''")
    $escapedDescription = $Description.Replace("'", "''")
    $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = '$escapedName - Shortcut'
`$VariableConfig.Description = '$escapedDescription'
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
    $settingsPath = Join-Path $appRoot "${id}_SplitScriptSettings.ps1"
    Set-Content -LiteralPath $settingsPath -Value $settings -Encoding UTF8
    [pscustomobject]@{ Name=$Name; Mode=$Mode; Path=$appRoot; SettingsPath=$settingsPath; Target=$Target; Destination=$Destination }
}
