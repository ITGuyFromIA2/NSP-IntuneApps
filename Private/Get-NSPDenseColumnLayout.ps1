function Get-NSPDenseColumnLayout {
    <#
    .SYNOPSIS
        Given the real console width and the longest label to be shown, works out how many
        label:value columns (1-4) a dense review screen should use and how wide each piece is.
    .DESCRIPTION
        Ported from NSP-FGTIPSecTools' IPSec-MasterOrchestrator.ps1 Get-DenseColumnLayout (its
        "Saved Answers" dense view), per the PLAN.md item to reuse suitable MasterOrchestrator/
        CLIBuilder presentation conventions without coupling to that repository - this is a pure,
        unit-testable function with zero FortiGate-specific logic, so it ports verbatim.

        Prefers MORE columns (less scrolling) but never so many that a column's value area drops
        below $minVal; a narrow (~80-col) window falls back to a single wide column.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$ConsoleWidth,
        [Parameter(Mandatory)][int]$MaxLabelLen
    )
    $labelWidth = [Math]::Min([Math]::Max($MaxLabelLen, 14), 30)
    $cellFixed  = $labelWidth + 6          # "{0,3}. " (5) + label + " " (1)
    $gutter     = 3
    $minVal     = 18                        # below this a column isn't worth having - use fewer, wider ones
    $maxVal     = 40
    $avail      = $ConsoleWidth - 2 - 1     # 2 leading spaces, 1 safety vs. edge auto-wrap

    $cols = 1
    for ($c = 4; $c -ge 1; $c--) {
        $perCol = [Math]::Floor(($avail - ($c - 1) * $gutter) / $c)
        if (($perCol - $cellFixed) -ge $minVal) { $cols = $c; break }
    }
    $valWidth = [Math]::Floor(($avail - ($cols - 1) * $gutter) / $cols) - $cellFixed
    if ($valWidth -gt $maxVal) { $valWidth = $maxVal }
    if ($valWidth -lt 12)      { $valWidth = 12 }
    $colWidth  = $cellFixed + $valWidth
    $ruleWidth = ($cols * $colWidth) + (($cols - 1) * $gutter)
    if ($ruleWidth -gt ($ConsoleWidth - 3)) { $ruleWidth = $ConsoleWidth - 3 }

    [pscustomobject]@{
        LabelWidth = $labelWidth
        ValWidth   = $valWidth
        Cols       = $cols
        Gutter     = $gutter
        ColWidth   = $colWidth
        RuleWidth  = $ruleWidth
    }
}
