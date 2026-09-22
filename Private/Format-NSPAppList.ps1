function Format-NSPAppList {
    <#
    .SYNOPSIS
        Formats a list of app names for a compact one-line menu display.
    #>
    [CmdletBinding()]
    param(
        [string[]]$Names,
        [int]$MaxItems = 3
    )

    $names = @($Names | Where-Object { $_ })
    if ($names.Count -eq 0) { return '(no apps)' }
    if ($names.Count -le $MaxItems) { return ($names -join ', ') }
    $shown = $names | Select-Object -First $MaxItems
    return ("{0} +{1} more" -f ($shown -join ', '), ($names.Count - $MaxItems))
}
