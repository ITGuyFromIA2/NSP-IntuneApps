function Invoke-NSPGraphCollection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Uri
    )

    $items = [System.Collections.Generic.List[object]]::new()
    $next = $Uri
    while ($next) {
        $page = Invoke-MgGraphRequest -Method GET -Uri $next -OutputType PSObject -ErrorAction Stop
        foreach ($item in @($page.value)) { $items.Add($item) }
        $next = $page.'@odata.nextLink'
    }
    @($items)
}
