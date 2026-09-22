function New-NSPFortiClientVpnConfigApp {
    <#
    .SYNOPSIS
        Generates a client-specific FortiClient SSL VPN configuration app.
    .DESCRIPTION
        Defaults to Apps\ (deployable) unless run from the public upstream repo itself, where
        it writes to the ignored local generation area instead so client-specific values never
        reach that catalog. Pass -OutputRoot explicitly to override either default.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [string]$TunnelName,
        [string]$Server,
        [string]$Description = '',
        [bool]$PromptUsername = $true,
        [bool]$EnableSso = $false,
        [bool]$UseExternalBrowser = $false,
        [string]$OutputRoot,
        [switch]$Interactive,
        [switch]$Force
    )

    if ($Interactive) {
        Write-Host 'FortiClient VPN configuration wizard' -ForegroundColor Cyan
        Write-Host 'Example tunnel name: Company VPN'
        if (-not $TunnelName) { $TunnelName = Read-Host '1. VPN tunnel name' }
        Write-Host 'Example server: https://vpn.example.com:8443'
        if (-not $Server) { $Server = Read-Host '2. VPN server URL' }
        Write-Host 'Example description: Company SSL VPN (optional)'
        if (-not $Description) { $Description = Read-Host '3. Description' }
        Write-Host '[1] Prompt for username (default)'
        Write-Host '[2] Do not prompt for username'
        $PromptUsername = (Read-NSPMenuChoice -Prompt '4. Username behavior' -Allowed @('1','2') -Default '1') -eq '1'
        Write-Host '[1] Standard FortiClient sign-in (default)'
        Write-Host '[2] Enable SSO in FortiClient'
        Write-Host '[3] Enable SSO and use the external browser'
        $signInChoice = Read-NSPMenuChoice -Prompt '5. Sign-in behavior' -Allowed @('1','2','3') -Default '1'
        $EnableSso = $signInChoice -in @('2','3')
        $UseExternalBrowser = $signInChoice -eq '3'
    }

    if ([string]::IsNullOrWhiteSpace($TunnelName)) { throw 'TunnelName is required.' }
    if ($TunnelName -match '[\[\]\\/"\r\n]') { throw 'TunnelName cannot contain brackets, slash, backslash, quote, or newline characters.' }
    if ([string]::IsNullOrWhiteSpace($Server)) { throw 'Server is required.' }
    try { $serverUri = [uri]$Server } catch { throw "Server must be an absolute HTTPS URL, such as https://vpn.example.com:8443. $($_.Exception.Message)" }
    if (-not $serverUri.IsAbsoluteUri -or $serverUri.Scheme -ne 'https' -or [string]::IsNullOrWhiteSpace($serverUri.Host)) {
        throw 'Server must be an absolute HTTPS URL, such as https://vpn.example.com:8443.'
    }
    if (-not $OutputRoot) { $OutputRoot = if (Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot) { Join-Path $RepoRoot 'Config\Local\GeneratedApps' } else { Join-Path $RepoRoot 'Apps' } }

    $safeName = ($TunnelName -replace '[^A-Za-z0-9_-]', '')
    if ([string]::IsNullOrWhiteSpace($safeName)) { throw 'TunnelName did not contain any filename-safe characters.' }
    $id = "FortiClientVpn$safeName"
    $appRoot = Join-Path $OutputRoot $id
    if ((Test-Path -LiteralPath $appRoot) -and -not $Force) { throw "Destination already exists: $appRoot. Use -Force to replace generated files." }
    if (-not $PSCmdlet.ShouldProcess($appRoot, "Generate FortiClient VPN configuration app for $TunnelName")) { return }

    $sourceRoot = Join-Path $appRoot 'Source'
    New-Item -ItemType Directory -Path $sourceRoot -Force | Out-Null

    $escapedTunnelName = $TunnelName
    $escapedDescription = $Description.Replace('\\', '\\\\').Replace('"', '\"')
    $escapedServer = $serverUri.AbsoluteUri.Replace('\\', '\\\\').Replace('"', '\"')
    $certFilter = '{"version":1,"CN":{"type":1,"pattern":"*"},"CA":{"type":1,"pattern":"*"},"OIDS":[{"type":1,"pattern":"*"}]}'
    $certFilterReg = $certFilter.Replace('"', '\"')
    $addRegistry = @(
        'Windows Registry Editor Version 5.00'
        ''
        "[HKEY_LOCAL_MACHINE\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$escapedTunnelName]"
        "`"Description`"=`"$escapedDescription`""
        "`"Server`"=`"$escapedServer`""
        '"DATA1"=""'
        '"dual_stack"=dword:00000000'
        "`"sso_enabled`"=dword:$(([int]$EnableSso).ToString('x8'))"
        "`"use_external_browser`"=dword:$(([int]$UseExternalBrowser).ToString('x8'))"
        '"azure_auto_login"=dword:00000000'
        '"single_user_mode"=dword:00000000'
        '"machine"=dword:00000000'
        "`"CertFilter`"=`"$certFilterReg`""
        '"ServerCert"="1"'
        '"promptcertificate"=dword:00000000'
        "`"promptusername`"=dword:$(([int]$PromptUsername).ToString('x8'))"
    )
    $removeRegistry = @(
        'Windows Registry Editor Version 5.00'
        ''
        "[-HKEY_LOCAL_MACHINE\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$escapedTunnelName]"
    )
    Set-Content -LiteralPath (Join-Path $sourceRoot 'VPNConfig_Add.reg') -Value $addRegistry -Encoding Unicode
    Set-Content -LiteralPath (Join-Path $sourceRoot 'VPNConfig_Remove.reg') -Value $removeRegistry -Encoding Unicode

    $installScript = @'
$registryFile = Join-Path $PSScriptRoot 'VPNConfig_Add.reg'
& reg.exe import $registryFile
if ($LASTEXITCODE -ne 0) { throw "FortiClient VPN registry import failed with exit code $LASTEXITCODE." }
'@
    $uninstallScript = @'
$registryFile = Join-Path $PSScriptRoot 'VPNConfig_Remove.reg'
& reg.exe import $registryFile
if ($LASTEXITCODE -ne 0) { throw "FortiClient VPN registry removal failed with exit code $LASTEXITCODE." }
'@
    Set-Content -LiteralPath (Join-Path $sourceRoot 'Install-FortiClientVpnConfig.ps1') -Value $installScript -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $sourceRoot 'Uninstall-FortiClientVpnConfig.ps1') -Value $uninstallScript -Encoding UTF8

    $settingsName = $TunnelName.Replace("'", "''")
    $settingsDescription = $Description.Replace("'", "''")
    $settingsKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\$TunnelName".Replace("'", "''")
    $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = 'FortiClient - Configure $settingsName'
`$VariableConfig.Description = 'Configures the FortiClient SSL VPN tunnel $settingsName. $settingsDescription'
`$VariableConfig.Publisher = 'Network Systems Plus, Inc.'
`$VariableConfig.IsFeatured = `$false
`$VariableConfig.Category = @('Business','Computer Management')
`$VariableConfig.SetupType = 'PoSH_sysnative'
`$VariableConfig.InstallExperience = 'system'
`$VariableConfig.RestartExperience = 'suppress'
`$VariableConfig.REQ_Architecture = 'All'
`$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
`$VariableConfig.DetectionStyle = 'Registry_Exist'
`$VariableConfig.Detection_KeyPath = '$settingsKey'
`$VariableConfig.Detection_ValueName = 'Server'
`$VariableConfig.SetupFile_Filter = 'Install-*.ps1'
`$VariableConfig.PoSH = @{ Sign_SourceFilter='*.ps1'; UninstallFile_Filter='Uninstall-*.ps1' }
`$VariableConfig.EnforceSignature_Detection = `$true
`$VariableConfig.RunAs32Bit_Detection = `$true
`$VariableConfig.AppDependency = @{ AppName='FortiClient'; DependencyType='AutoInstall' }
`$VariableConfig.AssignmentColl = @()
"@
    $settingsPath = Join-Path $appRoot "${id}_SplitScriptSettings.ps1"
    Set-Content -LiteralPath $settingsPath -Value $settings -Encoding UTF8

    [pscustomobject]@{
        Name         = $TunnelName
        Id           = $id
        Path         = $appRoot
        SettingsPath = $settingsPath
        Server       = $serverUri.AbsoluteUri
    }
}
