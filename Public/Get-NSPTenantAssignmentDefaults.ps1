function Get-NSPTenantAssignmentDefaults {
    <#
    .SYNOPSIS
        Reads the per-tenant "master" assignment groups a newly created app is assigned to
        unless its own settings file overrides them.
    .DESCRIPTION
        Read-only, local-only. Returns an empty DefaultAssignments array (never throws) when
        no defaults file exists yet, or when the saved file belongs to a different tenant -
        callers should treat that as "nothing configured", not an error.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$TenantId
    )

    $path = Join-Path $RepoRoot 'Config\Local\MasterAssignGroups.json'
    if (-not (Test-Path -LiteralPath $path)) {
        return [pscustomobject]@{ TenantId = $TenantId; Path = $path; DefaultAssignments = @() }
    }

    $saved = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if ([string]$saved.TenantId -ne $TenantId) {
        return [pscustomobject]@{ TenantId = $TenantId; Path = $path; DefaultAssignments = @() }
    }

    $defaults = @(@($saved.DefaultAssignments) | ForEach-Object {
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
    [pscustomobject]@{ TenantId = $TenantId; Path = $path; DefaultAssignments = $defaults }
}
