function Set-NSPAppAssignmentOverride {
    <#
    .SYNOPSIS
        Saves, or clears, one app's assignment override for a tenant - so it is assigned
        differently than, or not assigned by, the tenant's master default groups.
    .DESCRIPTION
        Local-only; makes no tenant writes and no Graph calls. An empty -AssignmentOverride array
        is a valid, meaningful save: it means "assign this app to nothing", distinct from never
        having called this function for the app at all (which falls back to the tenant's
        Get-NSPTenantAssignmentDefaults - see Get-NSPAppAssignmentOverride). -Clear removes the
        app's entry entirely, restoring the tenant-default fallback. Each entry is validated the
        same way New-NSPIntuneWin32AppAssignment validates at apply time, so a bad entry is
        caught here instead of during a real deployment run.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Save')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$AppName,
        [Parameter(Mandatory, ParameterSetName = 'Save')][AllowEmptyCollection()][object[]]$AssignmentOverride,
        [Parameter(Mandatory, ParameterSetName = 'Clear')][switch]$Clear
    )

    $path = Join-Path $RepoRoot 'Config\Local\AppAssignmentOverrides.json'
    $document = if (Test-Path -LiteralPath $path) { Get-Content -LiteralPath $path -Raw | ConvertFrom-Json } else { $null }
    # @() around the whole if/else is required: an empty result from either branch would
    # otherwise unroll to zero pipeline objects, collapsing the assignment to $null instead of
    # an empty array - the same class of gotcha as the @() note in New-NSPAppDeploymentRun.ps1.
    $existingApps = @(if ($document -and [string]$document.TenantId -eq $TenantId) { $document.Apps } else { @() })
    $apps = [Collections.Generic.List[object]]::new()
    foreach ($item in $existingApps) { $apps.Add($item) }
    $existingIndex = -1
    for ($i = 0; $i -lt $apps.Count; $i++) { if ([string]$apps[$i].AppName -eq $AppName) { $existingIndex = $i; break } }

    if ($PSCmdlet.ParameterSetName -eq 'Clear') {
        if (-not $PSCmdlet.ShouldProcess("$AppName in tenant $TenantId", 'Clear the saved assignment override')) { return }
        if ($existingIndex -ge 0) { $apps.RemoveAt($existingIndex) }
        $status = 'Cleared'
        $count = 0
    } else {
        $normalized = foreach ($spec in $AssignmentOverride) {
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
        if (-not $PSCmdlet.ShouldProcess("$AppName in tenant $TenantId", "Save $(@($normalized).Count) assignment override entry/entries")) { return }
        $entryRecord = [ordered]@{ AppName = $AppName; AssignmentOverride = @($normalized) }
        if ($existingIndex -ge 0) { $apps[$existingIndex] = $entryRecord } else { $apps.Add($entryRecord) }
        $status = 'Saved'
        $count = @($normalized).Count
    }

    $toWrite = [ordered]@{ TenantId = $TenantId; SavedAtUtc = (Get-Date).ToUniversalTime().ToString('o'); Apps = @($apps) }
    $parent = Split-Path -Path $path -Parent
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $toWrite | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $path -Encoding UTF8

    [pscustomobject]@{ Status = $status; AppName = $AppName; TenantId = $TenantId; Path = $path; Count = $count }
}
