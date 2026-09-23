function New-NSPCookieCutterAssignmentFilters {
    <#
    .SYNOPSIS
        Plans or creates the full set of standard, tenant-agnostic assignment filter blueprints in one batch.
    .DESCRIPTION
        Plan-only by default, matching New-NSPIntuneAssignmentFilter's own safety default. Reads
        the tenant's existing assignment filters first and skips any blueprint whose DisplayName
        already exists there, so re-running this after some filters are already created only
        plans/creates what's still missing. Pass -Execute to actually create the missing ones;
        each filter is created one at a time through New-NSPIntuneAssignmentFilter, so a single
        Graph rejection for one blueprint does not roll back filters already created earlier in
        the same call.

        See Get-NSPCookieCutterFilterBlueprints for the catalog. These are deliberately limited to
        filters built from stable Graph properties and fixed enum values - no enrollment profile
        names, device categories, or hardcoded device lists, since those are tenant-specific and
        would silently do nothing (or worse, match nothing) if copied to a different tenant.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [switch]$Execute
    )

    $graphContext = Connect-NSPGraph -Scopes (Get-NSPGraphRoutineScopes) -Connect -ClientId $ClientId -TenantId $TenantId
    $existingDisplayNames = @(Invoke-NSPGraphCollection -Uri 'https://graph.microsoft.com/beta/deviceManagement/assignmentFilters' | ForEach-Object { [string]$_.displayName })

    $results = @(foreach ($blueprint in @(Get-NSPCookieCutterFilterBlueprints)) {
        if ($blueprint.DisplayName -in $existingDisplayNames) {
            [pscustomobject]@{
                Status      = 'AlreadyExists'
                DisplayName = $blueprint.DisplayName
                Platform    = $blueprint.Platform
                Rule        = $blueprint.Rule
            }
            continue
        }

        $filterArgs = @{
            DisplayName    = $blueprint.DisplayName
            Platform       = $blueprint.Platform
            Rule           = $blueprint.Rule
            ManagementType = $blueprint.ManagementType
            TenantId       = $TenantId
            ClientId       = $ClientId
        }
        if ($Execute) {
            if ($PSCmdlet.ShouldProcess("tenant $TenantId", "Create cookie-cutter assignment filter '$($blueprint.DisplayName)'")) {
                New-NSPIntuneAssignmentFilter @filterArgs -Execute -Confirm:$false
            }
        } else {
            New-NSPIntuneAssignmentFilter @filterArgs
        }
    })

    [pscustomobject]@{
        TenantId      = $graphContext.TenantId
        Account       = $graphContext.Account
        AlreadyExists = @($results | Where-Object Status -eq 'AlreadyExists').Count
        Planned       = @($results | Where-Object Status -eq 'PlanOnly').Count
        Created       = @($results | Where-Object Status -eq 'Created').Count
        Results       = $results
    }
}
