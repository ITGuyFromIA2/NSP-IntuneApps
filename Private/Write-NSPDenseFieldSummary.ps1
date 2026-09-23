function Write-NSPDenseFieldSummary {
    <#
    .SYNOPSIS
        Prints a list of label:value rows packed into as many columns as the console width
        allows, instead of one per line.
    .DESCRIPTION
        Rendering half of the pattern ported from NSP-FGTIPSecTools' Show-SavedAnswersScreen
        -Dense (see Get-NSPDenseColumnLayout). Each row is @{ Label; Value }; an over-long value
        is shortened with a trailing '..'. Column count/width come from Get-NSPDenseColumnLayout,
        sized to $Host.UI.RawUI.WindowSize.Width (falls back to 120 when that isn't available,
        e.g. redirected output or a non-interactive host). -InputObject is a convenience for the
        dashboard's many "$result | Format-List" preview call sites: each of the object's own
        properties, in declared order, becomes one row - a drop-in denser replacement for
        Format-List's one-property-per-line output.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Rows')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Rows')][AllowEmptyCollection()][object[]]$Rows,
        [Parameter(Mandatory, ParameterSetName = 'InputObject')][psobject]$InputObject
    )

    if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
        $Rows = @($InputObject.PSObject.Properties | ForEach-Object { [pscustomobject]@{ Label = $_.Name; Value = $_.Value } })
    }
    $rows = @($Rows)
    if ($rows.Count -eq 0) { return }

    $consoleWidth = 120
    try { $cw = $Host.UI.RawUI.WindowSize.Width; if ($cw -and $cw -gt 20) { $consoleWidth = [int]$cw } } catch { }

    $maxLabelLen = ($rows | ForEach-Object { [string]$_.Label } | Measure-Object -Property Length -Maximum).Maximum
    if (-not $maxLabelLen) { $maxLabelLen = 20 }
    $layout = Get-NSPDenseColumnLayout -ConsoleWidth $consoleWidth -MaxLabelLen $maxLabelLen

    $pending = [Collections.Generic.List[string]]::new()
    $flushRow = {
        if ($pending.Count -eq 0) { return }
        $line = (($pending | ForEach-Object { $_.PadRight($layout.ColWidth) }) -join (' ' * $layout.Gutter)).TrimEnd()
        Write-Host "  $line"
        $pending.Clear()
    }

    foreach ($row in $rows) {
        $label = [string]$row.Label
        $value = "$($row.Value)"
        if ($value.Length -gt $layout.ValWidth) { $value = $value.Substring(0, [Math]::Max($layout.ValWidth - 2, 1)) + '..' }
        $pending.Add(("{0} {1}" -f $label.PadRight($layout.LabelWidth), $value))
        if ($pending.Count -ge $layout.Cols) { & $flushRow }
    }
    & $flushRow
}
