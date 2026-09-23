function Get-NSPAppAssignmentOverride {
    <#
    .SYNOPSIS
        Reads one app's saved assignment override, if any, for a tenant.
    .DESCRIPTION
        Read-only, local-only. Overrides are kept out of the app's own settings file entirely -
        Test-NSPIntuneAppsPreflight already blocks literal group targeting embedded in a
        deployable settings file (the retired AssignmentColl pattern), since that is exactly how
        a downstream client's real group name ends up committed to a shared repo. An override
        lives in Config/Local instead, alongside the tenant's master defaults (see
        Get-NSPTenantAssignmentDefaults), so the same safety property holds regardless of which
        repo this runs in. HasOverride distinguishes "nothing recorded for this app" (fall back
        to the tenant's defaults) from "recorded as an empty list" (assign nothing).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$AppName
    )

    $path = Join-Path $RepoRoot 'Config\Local\AppAssignmentOverrides.json'
    if (-not (Test-Path -LiteralPath $path)) {
        return [pscustomobject]@{ AppName = $AppName; HasOverride = $false; AssignmentOverride = @() }
    }
    $saved = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if ([string]$saved.TenantId -ne $TenantId) {
        return [pscustomobject]@{ AppName = $AppName; HasOverride = $false; AssignmentOverride = @() }
    }
    $entry = @(@($saved.Apps) | Where-Object { [string]$_.AppName -eq $AppName }) | Select-Object -First 1
    if (-not $entry) {
        return [pscustomobject]@{ AppName = $AppName; HasOverride = $false; AssignmentOverride = @() }
    }

    $normalized = @(@($entry.AssignmentOverride) | ForEach-Object {
        [pscustomobject][ordered]@{
            TargetType        = [string]$_.TargetType
            GroupId           = if ($_.GroupId) { [string]$_.GroupId } else { $null }
            GroupDisplayName  = if ($_.GroupDisplayName) { [string]$_.GroupDisplayName } else { $null }
            Mode              = [string]$_.Mode
            Intent            = [string]$_.Intent
            FilterDisplayName = if ($_.FilterDisplayName) { [string]$_.FilterDisplayName } else { $null }
            FilterMode        = if ($_.FilterMode) { [string]$_.FilterMode } else { $null }
        }
    })
    [pscustomobject]@{ AppName = $AppName; HasOverride = $true; AssignmentOverride = $normalized }
}
