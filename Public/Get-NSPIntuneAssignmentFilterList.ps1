function Get-NSPIntuneAssignmentFilterList {
    <#
    .SYNOPSIS
        Lists every assignment filter defined in the tenant, live from Graph.
    .DESCRIPTION
        Read-only. A tenant's assignment filters can be fresher than the last saved [13]
        harvest - for example ones just created by New-NSPIntuneAssignmentFilter or
        New-NSPCookieCutterAssignmentFilters earlier in the same session - so an interactive flow
        that needs to offer a filter to scope an assignment by should call this instead of
        depending on a possibly stale or missing saved harvest file. Mirrors the live-fetch
        pattern Find-NSPIntuneGroup already gives the group picker.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId
    )

    Connect-NSPGraph -Scopes (Get-NSPGraphRoutineScopes) -Connect -ClientId $ClientId -TenantId $TenantId | Out-Null

    @(Invoke-NSPGraphCollection -Uri 'https://graph.microsoft.com/beta/deviceManagement/assignmentFilters' | ForEach-Object {
        [pscustomobject][ordered]@{
            Id          = [string]$_.id
            DisplayName = [string]$_.displayName
            Platform    = [string]$_.platform
            Rule        = [string]$_.rule
        }
    })
}
