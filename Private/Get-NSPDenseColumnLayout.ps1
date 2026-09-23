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
        below $minVal; a narrow (~80-col) window falls back to a single wide column. -MaxValueLen
        (the longest actual value being shown, not just the longest label) raises $minVal so a
        screen full of GUIDs/emails/paths settles on fewer, wider columns instead of packing in
        more columns and truncating every one of them - the original port only sized columns off
        label length, which looked fine for short field names but truncated real tenant/account
        values (a 36-character GUID, a 30+ character email) far more than necessary once real
        data was tried against it.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$ConsoleWidth,
        [Parameter(Mandatory)][int]$MaxLabelLen,
        [int]$MaxValueLen = 18
    )
    $labelWidth = [Math]::Min([Math]::Max($MaxLabelLen, 14), 30)
    $cellFixed  = $labelWidth + 6          # "{0,3}. " (5) + label + " " (1)
    $gutter     = 3
    $maxVal     = 40
    $minVal     = [Math]::Max(18, [Math]::Min($MaxValueLen, $maxVal)) # below this a column isn't worth having - use fewer, wider ones
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
