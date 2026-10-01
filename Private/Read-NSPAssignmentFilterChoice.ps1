function Read-NSPAssignmentFilterChoice {
    <#
    .SYNOPSIS
        Offers the tenant's existing Windows assignment filters for one Include assignment.
    .DESCRIPTION
        Returns FilterDisplayName/FilterMode, both $null when no filter was chosen. Exclude
        assignments never prompt, since Intune does not allow a filter on an exclusion. Every
        app this tool assigns is a Win32 LOB app (Windows-only), so 'windows10AndLater' is the
        only platform a filter could ever match. Shared by the one-off assignment flow, the
        tenant master groups, and per-app overrides so all three offer the same choice.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [Parameter(Mandatory)][string]$Mode
    )

    $result = [pscustomobject]@{ FilterDisplayName = $null; FilterMode = $null }
    if ($Mode -ne 'Include') { return $result }

    $knownFilters = @(Get-NSPIntuneAssignmentFilterList -TenantId $TenantId -ClientId $ClientId -Platform 'windows10AndLater')
    if ($knownFilters.Count -eq 0) {
        Write-Host 'No Windows assignment filters exist in this tenant yet (Targeting & Filters can build one or deploy the standard set); continuing without a filter.' -ForegroundColor DarkGray
        return $result
    }

    Write-Host 'Scope by an existing assignment filter? (Build one via Targeting & Filters > Build and create an assignment filter, or deploy the standard set via Targeting & Filters > Deploy the standard cookie-cutter assignment filter set, if you need a new one.)' -ForegroundColor Cyan
    for ($index = 0; $index -lt $knownFilters.Count; $index++) { Write-Host ("  [{0}] {1} ({2})" -f ($index + 1), $knownFilters[$index].DisplayName, $knownFilters[$index].Platform) }
    Write-Host '  [N] No filter'
    $filterAllowed = @(@(1..$knownFilters.Count | ForEach-Object { [string]$_ }) + 'N')
    $filterChoice = Read-NSPMenuChoice -Prompt 'Filter' -Allowed $filterAllowed -Default 'N'
    if ($filterChoice -ne 'N') {
        $result.FilterDisplayName = $knownFilters[[int]$filterChoice - 1].DisplayName
        Write-Host '[1] Include  [2] Exclude'
        $filterModeChoice = Read-NSPMenuChoice -Prompt 'Filter mode' -Allowed @('1', '2') -Default '1'
        $result.FilterMode = if ($filterModeChoice -eq '2') { 'Exclude' } else { 'Include' }
    }
    $result
}
