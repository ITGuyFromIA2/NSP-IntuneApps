function Update-NSPIntuneWin32AppMetadata {
    <#
    .SYNOPSIS
        PATCHes an existing Win32 app's display metadata to match its current settings file,
        without touching content, assignments, dependencies, or reporting history.
    .DESCRIPTION
        Plan-only is the default; use -Execute and approve ShouldProcess to write. Wraps
        IntuneWin32App's Set-IntuneWin32App, which only exposes a narrow "display metadata"
        surface: DisplayName, Description, Publisher, the Company Portal featured flag, plus
        (optional, only patched when the settings file sets them) Developer, Owner,
        InformationURL, PrivacyURL, AppVersion, and AllowAvailableUninstall. Deliberately excludes
        Notes even though Set-IntuneWin32App supports it - the notes property is already owned by
        the management-notes marker (Get-NSPAppSourceState.ManagementNotes / Set-NSPAppManagementNotes),
        and editing it here would fight that marker on the next run of either. It deliberately does
        NOT update InstallExperience, RestartBehavior, detection rules, requirement rules, or scope
        tags - those are build-time win32LobApp properties Graph does support PATCHing, but the
        community module has no cmdlet for them, and this repo's action classifier does not
        distinguish "display text changed" from "a build-time field changed" (both hash as
        UpdateMetadataInPlace, since MetadataSha256 covers the whole settings file - see
        Get-NSPAppSourceState). If a settings-file edit changed one of those build-time fields,
        this function still runs (it always PATCHes the display-metadata fields from the current
        settings file) but the existing Intune app object's install experience/restart
        behavior/detection/requirement rules/scope tags will NOT reflect that edit - use
        Get-IntuneWin32App/Set-IntuneWin32App directly for now, or route the change through
        CreateSupersedingApp if it is significant enough to warrant a new app object.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$AppName,
        [Parameter(Mandatory)][string]$IntuneObjectId,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [switch]$Execute
    )

    $catalogEntry = Get-NSPIntuneAppCatalog -RepoRoot $RepoRoot | Where-Object Name -eq $AppName
    if (-not $catalogEntry) { throw "App was not found in the catalog: $AppName" }
    if (-not $catalogEntry.SettingsPath) { throw "App does not have one settings file: $AppName" }
    $VariableConfig = $null
    . $catalogEntry.SettingsPath

    $desired = [ordered]@{
        DisplayName = [string]$VariableConfig.DisplayName
        Description = [string]$VariableConfig.Description
        Publisher   = [string]$VariableConfig.Publisher
        IsFeatured  = [bool]$VariableConfig.IsFeatured
    }
    if ([string]::IsNullOrWhiteSpace($desired.DisplayName) -or [string]::IsNullOrWhiteSpace($desired.Description) -or [string]::IsNullOrWhiteSpace($desired.Publisher)) {
        throw "'$AppName' is missing DisplayName, Description, or Publisher in its settings file; nothing was patched."
    }
    # Optional Company Portal metadata - only included (and only PATCHed) when the settings file
    # actually sets it, so an app that predates these fields is unaffected.
    if ($VariableConfig.Developer) { $desired.Developer = [string]$VariableConfig.Developer }
    if ($VariableConfig.Owner) { $desired.Owner = [string]$VariableConfig.Owner }
    if ($VariableConfig.InformationURL) { $desired.InformationURL = [string]$VariableConfig.InformationURL }
    if ($VariableConfig.PrivacyURL) { $desired.PrivacyURL = [string]$VariableConfig.PrivacyURL }
    if ($VariableConfig.AppVersion) { $desired.AppVersion = [string]$VariableConfig.AppVersion }
    if ($null -ne $VariableConfig.AllowAvailableUninstall) { $desired.AllowAvailableUninstall = [bool]$VariableConfig.AllowAvailableUninstall }

    if (-not $Execute) {
        return [pscustomobject]@{
            Status         = 'PlanOnly'
            AppName        = $AppName
            IntuneObjectId = $IntuneObjectId
            Fields         = [pscustomobject]$desired
            Message        = "Run again with -Execute to PATCH display metadata for '$AppName' (IntuneObjectId $IntuneObjectId) in tenant $TenantId. Install experience, restart behavior, detection, and requirement rules are not covered by this PATCH."
        }
    }

    if (-not $PSCmdlet.ShouldProcess("tenant $TenantId", "PATCH display metadata for '$AppName' ($IntuneObjectId)")) { return }

    if (-not (Get-Module -ListAvailable IntuneWin32App)) {
        Import-NSPBootstrap | Out-Null
        Install-NSPModule -Name IntuneWin32App -Scope CurrentUser
    }
    Import-Module IntuneWin32App -ErrorAction Stop
    Connect-MSIntuneGraph -TenantID $TenantId -ClientID $ClientId | Out-Null

    $setArguments = @{
        ID                       = $IntuneObjectId
        DisplayName              = $desired.DisplayName
        Description              = $desired.Description
        Publisher                = $desired.Publisher
        CompanyPortalFeaturedApp = $desired.IsFeatured
    }
    foreach ($optionalField in @('Developer', 'Owner', 'InformationURL', 'PrivacyURL', 'AppVersion', 'AllowAvailableUninstall')) {
        if ($desired.Contains($optionalField)) { $setArguments[$optionalField] = $desired[$optionalField] }
    }
    Set-IntuneWin32App @setArguments -ErrorAction Stop | Out-Null

    [pscustomobject]@{
        Status         = 'Updated'
        AppName        = $AppName
        IntuneObjectId = $IntuneObjectId
        Fields         = [pscustomobject]$desired
        TenantId       = $TenantId
    }
}
