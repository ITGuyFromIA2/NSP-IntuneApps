function New-NSPRdpApp {
    <#
    .SYNOPSIS
        Generates a full-desktop or RemoteApp Intune app using a guided, conditional wizard.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [ValidateSet('Desktop','RemoteApp')][string]$Mode = 'Desktop',
        [string]$Name,
        [string]$HostName,
        [string]$Gateway,
        [bool]$UseMultiMon = $true,
        [string[]]$Redirection = @('Clipboard','SmartCards'),
        [string]$RemoteAppAlias,
        [string]$RemoteAppName,
        [string]$LoadBalanceInfo,
        [ValidateSet('PublicDesktop','StartMenu')][string]$Destination = 'PublicDesktop',
        [string]$OutputRoot,
        [switch]$Interactive,
        [switch]$Force
    )

    if ($Interactive) {
        Write-Host 'RDP / RemoteApp wizard' -ForegroundColor Cyan
        Write-Host '[1] Full remote desktop (default)'
        Write-Host '[2] RemoteApp - one published application'
        $modeChoice = Read-NSPMenuChoice -Prompt '1. Connection type' -Allowed @('1','2') -Default '1'
        $Mode = if ($modeChoice -eq '2') { 'RemoteApp' } else { 'Desktop' }
        Write-Host 'Example name: Accounting Desktop or Time Matters'
        if (-not $Name) { $Name = Read-Host '2. Friendly name' }
        Write-Host 'Example host: rds.contoso.com'
        if (-not $HostName) { $HostName = Read-Host '3. RDS host or farm DNS name' }
        Write-Host 'Example gateway: rdgateway.contoso.com; press Enter when no gateway is used'
        if (-not $Gateway) { $Gateway = Read-Host '4. RD Gateway' }
        Write-Host '[1] Use all monitors (default)'
        Write-Host '[2] Use one monitor'
        $monitorChoice = Read-NSPMenuChoice -Prompt '5. Display mode' -Allowed @('1','2') -Default '1'
        $UseMultiMon = $monitorChoice -eq '1'
        Write-Host 'Redirections: [C] Clipboard  [P] Printers  [D] Drives  [S] Smart cards'
        Write-Host 'Enter letters separated by commas. Example: C,P,S. Default: C,S'
        $redirectionChoice = Read-Host '6. Redirections'
        if ([string]::IsNullOrWhiteSpace($redirectionChoice)) { $redirectionChoice = 'C,S' }
        $map = @{ C='Clipboard'; P='Printers'; D='Drives'; S='SmartCards' }
        $Redirection = @($redirectionChoice -split ',' | ForEach-Object { $map[$_.Trim().ToUpperInvariant()] } | Where-Object { $_ })
        if ($Mode -eq 'RemoteApp') {
            Write-Host 'Example alias: ||TIMEMATTERS (include || when the feed uses it)'
            if (-not $RemoteAppAlias) { $RemoteAppAlias = Read-Host '7. RemoteApp program alias' }
            Write-Host 'Example display name: Time Matters'
            if (-not $RemoteAppName) { $RemoteAppName = Read-Host '8. RemoteApp display name' }
            Write-Host 'Optional example: tsv://MS Terminal Services Plugin.1.CollectionName'
            if (-not $LoadBalanceInfo) { $LoadBalanceInfo = Read-Host '9. Load-balancing information (optional)' }
        }
        Write-Host '[1] Public Desktop (default)'
        Write-Host '[2] Start Menu'
        $destinationChoice = Read-NSPMenuChoice -Prompt '10. Shortcut location' -Allowed @('1','2') -Default '1'
        $Destination = if ($destinationChoice -eq '2') { 'StartMenu' } else { 'PublicDesktop' }
    }

    if ([string]::IsNullOrWhiteSpace($Name)) { throw 'Name is required.' }
    if ([string]::IsNullOrWhiteSpace($HostName)) { throw 'HostName is required.' }
    if ($Mode -eq 'RemoteApp' -and [string]::IsNullOrWhiteSpace($RemoteAppAlias)) { throw 'RemoteAppAlias is required for RemoteApp mode.' }
    if (-not $OutputRoot) { $OutputRoot = if (Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot) { Join-Path $RepoRoot 'Config\Local\GeneratedApps' } else { Join-Path $RepoRoot 'Apps' } }
    $safeName = ($Name -replace '[^A-Za-z0-9_-]', '')
    $id = "Rdp$safeName"
    $appRoot = Join-Path $OutputRoot $id
    if ((Test-Path -LiteralPath $appRoot) -and -not $Force) { throw "Destination already exists: $appRoot. Use -Force to replace generated files." }
    if (-not $PSCmdlet.ShouldProcess($appRoot, "Generate $Mode app for $Name")) { return }

    $source = Join-Path $appRoot 'Source'
    $detect = Join-Path $appRoot 'Detect'
    New-Item -ItemType Directory -Path $source -Force | Out-Null
    New-Item -ItemType Directory -Path $detect -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $RepoRoot 'Templates\Rdp\Source\Install-RdpConnection.ps1') -Destination $source -Force
    Copy-Item -LiteralPath (Join-Path $RepoRoot 'Templates\Rdp\Source\Uninstall-RdpConnection.ps1') -Destination $source -Force
    Copy-Item -LiteralPath (Join-Path $RepoRoot 'Templates\Rdp\Detect\Detect-RdpConnection.ps1') -Destination $detect -Force

    $fileName = "$Name.rdp" -replace '[<>:"/\\|?*]', '-'
    $config = [ordered]@{
        Id=$id; DisplayName=$Name; FileName=$fileName; Mode=$Mode; Host=$HostName; Gateway=$Gateway
        UseMultiMon=$UseMultiMon; RedirectClipboard=$Redirection -contains 'Clipboard'; RedirectPrinters=$Redirection -contains 'Printers'
        RedirectDrives=$Redirection -contains 'Drives'; RedirectSmartCards=$Redirection -contains 'SmartCards'
        RemoteAppAlias=$RemoteAppAlias; RemoteAppName=$RemoteAppName; LoadBalanceInfo=$LoadBalanceInfo; Destination=$Destination
    }
    $configJson = $config | ConvertTo-Json -Depth 5
    $configJson | Set-Content -LiteralPath (Join-Path $source 'Rdp.config.json') -Encoding UTF8
    $configJson | Set-Content -LiteralPath (Join-Path $detect 'Rdp.config.json') -Encoding UTF8

    $rdpLines = @(
        'screen mode id:i:2'
        "use multimon:i:$([int]$UseMultiMon)"
        'session bpp:i:32'
        "full address:s:$HostName"
        "redirectclipboard:i:$([int]($Redirection -contains 'Clipboard'))"
        "redirectprinters:i:$([int]($Redirection -contains 'Printers'))"
        "redirectsmartcards:i:$([int]($Redirection -contains 'SmartCards'))"
        "redirectdrives:i:$([int]($Redirection -contains 'Drives'))"
        "drivestoredirect:s:$(if ($Redirection -contains 'Drives') { '*' } else { '' })"
        "gatewayhostname:s:$Gateway"
        "gatewayusagemethod:i:$(if ($Gateway) { 2 } else { 4 })"
        "remoteapplicationmode:i:$([int]($Mode -eq 'RemoteApp'))"
    )
    if ($Mode -eq 'RemoteApp') {
        $rdpLines += "alternate shell:s:$RemoteAppAlias"
        $rdpLines += "remoteapplicationprogram:s:$RemoteAppAlias"
        $rdpLines += "remoteapplicationname:s:$RemoteAppName"
        if ($LoadBalanceInfo) { $rdpLines += "loadbalanceinfo:s:$LoadBalanceInfo" }
    }
    Set-Content -LiteralPath (Join-Path $source 'Connection.rdp') -Value $rdpLines -Encoding Unicode
    Copy-Item -LiteralPath (Join-Path $source 'Connection.rdp') -Destination $detect -Force

    $escapedName = $Name.Replace("'", "''")
    $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = '$escapedName'
`$VariableConfig.Description = 'Installs the managed $Mode connection named $escapedName.'
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
    [pscustomobject]@{ Name=$Name; Mode=$Mode; Path=$appRoot; SettingsPath=$settingsPath; Host=$HostName; Destination=$Destination }
}
