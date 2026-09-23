function New-NSPIntuneAssignmentFilter {
    <#
    .SYNOPSIS
        Creates a new Intune assignment filter from one or more AND-joined clauses.
    .DESCRIPTION
        Plan-only is the default. Use -Execute and approve ShouldProcess to actually create it
        in the tenant. Pass -Rule directly to skip clause assembly (a rule authored by hand or
        copied from an existing filter), or -Clauses to have Build-NSPAssignmentFilterRule
        assemble it. Each entry in -Clauses is either a leaf (Property/Operator/Value) or a
        nested group (its own Clauses array, optionally its own Operator) - see
        Build-NSPAssignmentFilterRule for the exact shape and parenthesization rules.
        -TopLevelOperator joins the top-level -Clauses themselves ('and' by default, matching
        every existing caller).
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Clauses')]
    param(
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter(Mandatory)][string]$Platform,
        [Parameter(Mandatory, ParameterSetName = 'Clauses')][object[]]$Clauses,
        [Parameter(ParameterSetName = 'Clauses')][ValidateSet('and', 'or')][string]$TopLevelOperator = 'and',
        [Parameter(Mandatory, ParameterSetName = 'RawRule')][string]$Rule,
        [ValidateSet('devices', 'apps')][string]$ManagementType = 'devices',
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [switch]$Execute
    )

    $resolvedRule = if ($PSCmdlet.ParameterSetName -eq 'RawRule') { $Rule } else { Build-NSPAssignmentFilterRule -Clauses $Clauses -Operator $TopLevelOperator }

    if (-not $Execute) {
        return [pscustomobject]@{
            Status      = 'PlanOnly'
            DisplayName = $DisplayName
            Platform    = $Platform
            Rule        = $resolvedRule
            Message     = "Run again with -Execute to create assignment filter '$DisplayName' in tenant $TenantId."
        }
    }

    if (-not $PSCmdlet.ShouldProcess("tenant $TenantId", "Create assignment filter '$DisplayName' ($Platform): $resolvedRule")) { return }

    $registrationScope = 'DeviceManagementConfiguration.ReadWrite.All'
    $graphContext = Connect-NSPGraph -Scopes $registrationScope -Connect -ClientId $ClientId -TenantId $TenantId
    $body = @{
        displayName                    = $DisplayName
        platform                       = $Platform
        rule                           = $resolvedRule
        assignmentFilterManagementType = $ManagementType
    } | ConvertTo-Json
    $result = Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/beta/deviceManagement/assignmentFilters' -Body $body -ContentType 'application/json' -ErrorAction Stop

    [pscustomobject]@{
        Status      = 'Created'
        Id          = [string]$result.id
        DisplayName = $DisplayName
        Platform    = $Platform
        Rule        = $resolvedRule
        TenantId    = $graphContext.TenantId
    }
}
