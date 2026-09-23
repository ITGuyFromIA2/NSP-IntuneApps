function Write-NSPDenseNumberedList {
    <#
    .SYNOPSIS
        Prints a numbered list ("[N] Text"), packed into as many columns as the console width
        allows, instead of one entry per line.
    .DESCRIPTION
        Adapted from the same "prefer more columns, never below a usable minimum, fall back to
        one wide column on a narrow window" idea as NSP-FGTIPSecTools' Get-DenseColumnLayout, but
        for plain numbered items (no separate label:value split) - the app-catalog pickers here
        are "[N] AppName" with nothing else, so there is no value column to reserve, unlike the
        Saved Answers screen that pattern was written for.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]]$Items,
        [string[]]$Markers
    )

    $items = @($Items)
    if ($items.Count -eq 0) { return }
    $markers = if ($Markers -and $Markers.Count -eq $items.Count) { $Markers } else { @($items | ForEach-Object { '' }) }

    $consoleWidth = 120
    try { $cw = $Host.UI.RawUI.WindowSize.Width; if ($cw -and $cw -gt 20) { $consoleWidth = [int]$cw } } catch { }

    $cellTexts = for ($i = 0; $i -lt $items.Count; $i++) {
        $marker = if ($markers[$i]) { "$($markers[$i]) " } else { '' }
        "$marker[{0,3}] {1}" -f ($i + 1), $items[$i]
    }
    $maxCellLen = ($cellTexts | Measure-Object -Property Length -Maximum).Maximum

    $gutter = 3
    $minColWidth = 18
    $avail = $consoleWidth - 2 - 1
    $itemWidth = [Math]::Max($maxCellLen, $minColWidth)
    $cols = 1
    for ($c = 4; $c -ge 1; $c--) {
        $perCol = [Math]::Floor(($avail - ($c - 1) * $gutter) / $c)
        if ($perCol -ge $itemWidth) { $cols = $c; break }
    }
    $colWidth = [Math]::Floor(($avail - ($cols - 1) * $gutter) / $cols)

    $pending = [Collections.Generic.List[string]]::new()
    $flushRow = {
        if ($pending.Count -eq 0) { return }
        $line = (($pending | ForEach-Object { $_.PadRight($colWidth) }) -join (' ' * $gutter)).TrimEnd()
        Write-Host "  $line"
        $pending.Clear()
    }
    foreach ($cellText in $cellTexts) {
        $pending.Add($cellText)
        if ($pending.Count -ge $cols) { & $flushRow }
    }
    & $flushRow
}
