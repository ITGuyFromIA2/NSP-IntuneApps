function Find-NSPIntuneGroup {
    <#
    .SYNOPSIS
        Searches tenant groups by a display-name substring, for interactive picking.
    .DESCRIPTION
        Read-only. A tenant can have far more groups than were ever used for an app
        assignment (the harvested "already used" list from Get-NSPIntuneAppAssignmentInventory),
        so this searches every group live instead. Uses Graph's advanced query support
        (ConsistencyLevel: eventual) to match the term anywhere in the name, not just a prefix.
        Leave NameContains blank to list all groups (useful for an unfamiliar tenant where you
        don't know any group names yet) - a Mandatory string parameter would otherwise reject an
        empty string at the binder level before this function's body ever ran.
    #>
    [CmdletBinding()]
    param(
        [string]$NameContains = '',
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [int]$MaxResults = 25
    )

    Connect-NSPGraph -Scopes (Get-NSPGraphRoutineScopes) -Connect -ClientId $ClientId -TenantId $TenantId | Out-Null

    $queryParts = [Collections.Generic.List[string]]::new()
    if (-not [string]::IsNullOrWhiteSpace($NameContains)) {
        $escapedTerm = $NameContains.Replace("'", "''")
        $queryParts.Add("`$filter=contains(displayName,'$escapedTerm')")
    }
    $queryParts.Add('$select=id,displayName')
    $queryParts.Add("`$top=$MaxResults")
    $queryParts.Add('$count=true')
    $queryParts.Add('$orderby=displayName')
    $uri = 'https://graph.microsoft.com/v1.0/groups?' + ($queryParts -join '&')
    $response = Invoke-MgGraphRequest -Method GET -Uri $uri -Headers @{ ConsistencyLevel = 'eventual' } -ErrorAction Stop
    @($response.value | ForEach-Object { [pscustomobject][ordered]@{ Id = [string]$_.id; DisplayName = [string]$_.displayName } })
}
