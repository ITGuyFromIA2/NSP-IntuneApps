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

        -Platform restricts the result to filters built for that one Graph platform value (e.g.
        'windows10AndLater'). A filter can only ever apply to an app/policy on the same platform,
        so an Android or iOS filter offered against a Windows app is dead weight at best and a
        Graph rejection at worst - callers that already know the target platform should pass it.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [string]$Platform
    )

    Connect-NSPGraph -Scopes (Get-NSPGraphRoutineScopes) -Connect -ClientId $ClientId -TenantId $TenantId | Out-Null

    $filters = @(Invoke-NSPGraphCollection -Uri 'https://graph.microsoft.com/beta/deviceManagement/assignmentFilters' | ForEach-Object {
        [pscustomobject][ordered]@{
            Id          = [string]$_.id
            DisplayName = [string]$_.displayName
            Platform    = [string]$_.platform
            Rule        = [string]$_.rule
        }
    })
    if ($Platform) { $filters = @($filters | Where-Object { $_.Platform -ieq $Platform }) }
    $filters
}
