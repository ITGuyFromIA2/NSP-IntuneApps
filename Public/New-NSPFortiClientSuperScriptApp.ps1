function New-NSPFortiClientSuperScriptApp {
    <#
    .SYNOPSIS
        Packages an already-built FortiClient SuperScript (NSP-FGTIPSecTools' SuperScriptBuilder)
        as an NSP-IntuneApps Win32 app.
    .DESCRIPTION
        The superscript is a self-contained, versioned, multi-target (GPO/PDQ/Intune) deployment
        engine - all real install/detect/uninstall logic already lives inside it, dispatched by its
        own -Mode switch. IntuneDeploy/IntuneUninstall already use Win32's native install-command
        exit-code contract (0 success, 3010 soft reboot mid-upgrade, 1 failure). This function does
        not invoke SuperScriptBuilder itself - it takes an already-built
        <Abbrev>_FortiClient_Upgrade.ps1 and wraps it: copies it into Source/, writes the install
        and uninstall mode-dispatch scripts, copies the builder's companion detection script, and
        writes a _SplitScriptSettings.ps1.

        Detection cannot dispatch to the superscript's own -Mode IntuneDetect: Intune uploads the
        detection script by itself and runs it from the Intune Management Extension's folder,
        where the package content (and so the superscript) is not present. Build-SuperScript.ps1
        emits a standalone Detect_<Abbrev>_FortiClientVPN.ps1 for exactly this reason; it is found
        next to the superscript or in a staged INTUNE-FortiClient-<Abbrev>\Detect folder there,
        or passed with -DetectScriptPath. Its $SuperScriptBuiltUtc stamp must match the
        superscript's, since a stale companion would check for the previous build's target
        version and config hash.

        SetupType is 'PoSH_sysnative' and detection runs 64-bit, matching Apps/FortiClient_
        ImportConfig's own documented reasoning (see Resolve-NSPAppBuildPlan) - the superscript
        reads/writes HKLM:\SOFTWARE\Fortinet\FortiClient\... directly, which needs the 64-bit
        PowerShell host on a 64-bit OS or WOW64 silently redirects those reads to
        HKLM\SOFTWARE\WOW6432Node\... instead.

        RestartExperience is 'basedOnReturnCode', not 'suppress' - IntuneDeploy's own 3010 exit
        code IS how it tells Intune "succeeded, needs a reboot before the next pass can finish";
        suppressing that would break its own resumable multi-pass design.

        Assignment targeting is deliberately left empty - that's Set-NSPTenantAssignmentDefaults /
        Set-NSPAppAssignmentOverride's job now, not baked into generated app source.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [string]$SuperScriptPath,
        [string]$DetectScriptPath,
        [string]$ClientAbbrev,
        [string]$DisplayName,
        [string]$OutputRoot,
        [switch]$Interactive,
        [switch]$Force
    )

    if ($Interactive) {
        Write-Host 'FortiClient SuperScript packaging wizard' -ForegroundColor Cyan
        Write-Host 'Example: C:\GitRepo\NSP-FGTIPSecTools\IPSEC AIO\Staging\<Client>\<Client>_FortiClient_Upgrade.ps1'
        if (-not $SuperScriptPath) { $SuperScriptPath = Read-NSPPathInput -Prompt '1. Path to the already-built SuperScript' }
        Write-Host 'Example: Contoso'
        if (-not $ClientAbbrev) { $ClientAbbrev = Read-Host '2. Client abbreviation' }
        Write-Host "Example: FortiClient - $ClientAbbrev (blank to use this default)"
        if (-not $DisplayName) { $DisplayName = Read-Host '3. Display name' }
    }

    if ([string]::IsNullOrWhiteSpace($SuperScriptPath)) { throw 'SuperScriptPath is required.' }
    if (-not (Test-Path -LiteralPath $SuperScriptPath -PathType Leaf)) { throw "SuperScript not found: $SuperScriptPath" }
    if ([string]::IsNullOrWhiteSpace($ClientAbbrev)) { throw 'ClientAbbrev is required.' }
    if ($ClientAbbrev -match '[^A-Za-z0-9_-]') { throw 'ClientAbbrev may only contain letters, digits, underscore, and hyphen.' }
    if ([string]::IsNullOrWhiteSpace($DisplayName)) { $DisplayName = "FortiClient - $ClientAbbrev" }

    if ([string]::IsNullOrWhiteSpace($DetectScriptPath)) {
        $superScriptDir = Split-Path -Path $SuperScriptPath -Parent
        $detectFileName = "Detect_${ClientAbbrev}_FortiClientVPN.ps1"
        $DetectScriptPath = @(
            (Join-Path $superScriptDir $detectFileName)
            (Join-Path $superScriptDir "INTUNE-FortiClient-$ClientAbbrev\Detect\$detectFileName")
        ) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
        if (-not $DetectScriptPath) { throw "Companion detection script $detectFileName was not found next to the SuperScript or in its INTUNE-FortiClient-$ClientAbbrev\Detect folder. Pass -DetectScriptPath with the one Build-SuperScript.ps1 emitted for this build." }
    } elseif (-not (Test-Path -LiteralPath $DetectScriptPath -PathType Leaf)) {
        throw "Detection script not found: $DetectScriptPath"
    }
    $buildStampPattern = "(?m)^\`$SuperScriptBuiltUtc\s*=\s*'([^']+)'"
    $superScriptStamp = [regex]::Match((Get-Content -LiteralPath $SuperScriptPath -Raw), $buildStampPattern).Groups[1].Value
    $detectStamp = [regex]::Match((Get-Content -LiteralPath $DetectScriptPath -Raw), $buildStampPattern).Groups[1].Value
    if ($superScriptStamp -and $detectStamp -ne $superScriptStamp) {
        throw "Detection script $DetectScriptPath was built at '$detectStamp', but the SuperScript was built at '$superScriptStamp'. Use the companion detection script from the same build."
    }

    if (-not $OutputRoot) { $OutputRoot = if (Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot) { Join-Path $RepoRoot 'Config\Local\GeneratedApps' } else { Join-Path $RepoRoot 'Apps' } }

    $id = "FortiClient-$ClientAbbrev"
    $appRoot = Join-Path $OutputRoot $id
    if ((Test-Path -LiteralPath $appRoot) -and -not $Force) { throw "Destination already exists: $appRoot. Use -Force to replace generated files." }
    if (-not $PSCmdlet.ShouldProcess($appRoot, "Package the FortiClient SuperScript for $ClientAbbrev")) { return }

    $sourceRoot = Join-Path $appRoot 'Source'
    $detectRoot = Join-Path $appRoot 'Detect'
    New-Item -ItemType Directory -Path $sourceRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $detectRoot -Force | Out-Null

    $superScriptFileName = Split-Path -Path $SuperScriptPath -Leaf
    Copy-Item -LiteralPath $SuperScriptPath -Destination (Join-Path $sourceRoot $superScriptFileName) -Force

    $wrapperHeader = @(
        '# Auto-generated by New-NSPFortiClientSuperScriptApp. All real install/detect/uninstall'
        '# logic lives in the embedded SuperScript itself - this just dispatches to its own -Mode.'
    ) -join "`r`n"

    $deployWrapper = @($wrapperHeader, "& `"`$PSScriptRoot\$superScriptFileName`" -Mode IntuneDeploy", 'exit $LASTEXITCODE') -join "`r`n"
    $uninstallWrapper = @($wrapperHeader, "& `"`$PSScriptRoot\$superScriptFileName`" -Mode IntuneUninstall", 'exit $LASTEXITCODE') -join "`r`n"

    Set-Content -LiteralPath (Join-Path $sourceRoot "DownloadInstall_$id.ps1") -Value $deployWrapper -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $sourceRoot "Uninstall_$id.ps1") -Value $uninstallWrapper -Encoding UTF8
    Copy-Item -LiteralPath $DetectScriptPath -Destination (Join-Path $detectRoot (Split-Path -Path $DetectScriptPath -Leaf)) -Force

    $settingsDisplayName = $DisplayName.Replace("'", "''")
    $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = '$settingsDisplayName'
`$VariableConfig.Description = 'Deploys and maintains FortiClient IPSec VPN for $ClientAbbrev via the NSP FortiClient SuperScript (GPO/PDQ/Intune-aware, self-contained, resumable across reboots).'
`$VariableConfig.Publisher = 'Network Systems Plus, Inc.'
`$VariableConfig.IsFeatured = `$true
`$VariableConfig.Category = @('Business','Computer Management')
`$VariableConfig.SetupType = 'PoSH_sysnative'
`$VariableConfig.InstallExperience = 'system'
`$VariableConfig.RestartExperience = 'basedOnReturnCode'
`$VariableConfig.REQ_Architecture = 'All'
`$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
`$VariableConfig.DetectionStyle = 'Script'
`$VariableConfig.DetectScript_Filter = 'Detect_*.ps1'
`$VariableConfig.SetupFile_Filter = 'DownloadInstall_*.ps1'
`$VariableConfig.PoSH = @{ Sign_SourceFilter='*.ps1'; UninstallFile_Filter='Uninstall_*.ps1' }
`$VariableConfig.EnforceSignature_Detection = `$true
`$VariableConfig.RunAs32Bit_Detection = `$false
`$VariableConfig.AssignmentColl = @()
"@
    $settingsPath = Join-Path $appRoot "${id}_SplitScriptSettings.ps1"
    Set-Content -LiteralPath $settingsPath -Value $settings -Encoding UTF8

    [pscustomobject]@{
        Name            = $ClientAbbrev
        Id              = $id
        Path            = $appRoot
        SettingsPath    = $settingsPath
        SuperScriptFile = $superScriptFileName
    }
}
