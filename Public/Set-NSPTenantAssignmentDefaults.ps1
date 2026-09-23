function Set-NSPTenantAssignmentDefaults {
    <#
    .SYNOPSIS
        Saves the per-tenant "master" assignment groups a newly created app is assigned to by
        default, unless its own settings file overrides them.
    .DESCRIPTION
        Local-only; makes no tenant writes and no Graph calls. Each entry in -DefaultAssignments
        is validated against the same rules New-NSPIntuneWin32AppAssignment enforces at apply
        time, so a bad entry is caught here instead of during a real deployment run. Overwrites
        any previously saved defaults for this tenant.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][object[]]$DefaultAssignments
    )

    $normalized = foreach ($spec in $DefaultAssignments) {
        $targetType = if ($spec.TargetType) { [string]$spec.TargetType } else { 'Group' }
        if ($targetType -notin @('Group', 'AllUsers', 'AllDevices')) {
            throw "Unsupported TargetType '$targetType'. Use one of: Group, AllUsers, AllDevices."
        }
        if ($targetType -eq 'Group' -and -not $spec.GroupId) {
            throw 'GroupId is required when TargetType is Group.'
        }
        if ($targetType -ne 'Group' -and [string]$spec.Mode -eq 'Exclude') {
            throw "Exclude is not supported for TargetType '$targetType'; only a specific group can be excluded."
        }
        if ($targetType -ne 'Group' -and [string]$spec.Intent -eq 'availableWithoutEnrollment') {
            throw "Intent 'availableWithoutEnrollment' is not supported for TargetType '$targetType'."
        }
        if ([string]$spec.Mode -eq 'Exclude' -and $spec.FilterDisplayName) {
            throw 'A filter cannot be combined with an Exclude assignment; Intune does not support filtering excludes.'
        }
        if ($spec.FilterDisplayName -and -not $spec.FilterMode) {
            throw 'FilterMode is required when FilterDisplayName is specified.'
        }
        [ordered]@{
            TargetType        = $targetType
            GroupId           = if ($spec.GroupId) { [string]$spec.GroupId } else { $null }
            GroupDisplayName  = if ($spec.GroupDisplayName) { [string]$spec.GroupDisplayName } else { $null }
            Mode              = [string]$spec.Mode
            Intent            = [string]$spec.Intent
            FilterDisplayName = if ($spec.FilterDisplayName) { [string]$spec.FilterDisplayName } else { $null }
            FilterMode        = if ($spec.FilterMode) { [string]$spec.FilterMode } else { $null }
        }
    }

    $path = Join-Path $RepoRoot 'Config\Local\MasterAssignGroups.json'
    if (-not $PSCmdlet.ShouldProcess($path, "Save $(@($normalized).Count) master assignment default(s) for tenant $TenantId")) { return }

    $document = [ordered]@{ TenantId = $TenantId; SavedAtUtc = (Get-Date).ToUniversalTime().ToString('o'); DefaultAssignments = @($normalized) }
    $parent = Split-Path -Path $path -Parent
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $document | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $path -Encoding UTF8

    [pscustomobject]@{ Status = 'Saved'; TenantId = $TenantId; Path = $path; Count = @($normalized).Count }
}
