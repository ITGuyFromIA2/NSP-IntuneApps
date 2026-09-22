function Find-NSPIntuneGroup {
    <#
    .SYNOPSIS
        Searches tenant groups by a display-name substring, for interactive picking.
    .DESCRIPTION
        Read-only. A tenant can have far more groups than were ever used for an app
        assignment (the harvested "already used" list from Get-NSPIntuneAppAssignmentInventory),
        so this searches every group live instead. Uses Graph's advanced query support
        (ConsistencyLevel: eventual) to match the term anywhere in the name, not just a prefix.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$NameContains,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [int]$MaxResults = 25
    )

    Connect-NSPGraph -Scopes 'Group.Read.All' -Connect -ClientId $ClientId -TenantId $TenantId | Out-Null

    $escapedTerm = $NameContains.Replace("'", "''")
    $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=contains(displayName,'$escapedTerm')&`$select=id,displayName&`$top=$MaxResults&`$count=true"
    $response = Invoke-MgGraphRequest -Method GET -Uri $uri -Headers @{ ConsistencyLevel = 'eventual' } -ErrorAction Stop
    @($response.value | ForEach-Object { [pscustomobject][ordered]@{ Id = [string]$_.id; DisplayName = [string]$_.displayName } })
}
