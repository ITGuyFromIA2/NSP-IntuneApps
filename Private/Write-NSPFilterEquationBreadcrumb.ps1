function Write-NSPFilterEquationBreadcrumb {
    <#
    .SYNOPSIS
        Prints a running "(Clause1) and (Clause2)" preview of the filter rule being built in the
        dashboard's guided clause builder, with the piece currently being edited highlighted so
        its place in the whole expression is clear as soon as it starts, not just once it's done.
    .DESCRIPTION
        -OuterClauses are already-completed top-level clauses. When the piece currently being
        edited is itself an OR/AND group, pass its already-completed sub-clauses as
        -CurrentGroupClauses and its own joining operator as -CurrentGroupOperator - the
        highlighted placeholder then nests inside that group's own parens, e.g.
        "(Clause1) and ((SubClause1) or (...))" while a second sub-clause is being entered.
        Each already-completed clause/sub-clause is rendered with Build-NSPAssignmentFilterRule
        so the preview always matches exactly what the real rule string would be.
    #>
    [CmdletBinding()]
    param(
        [object[]]$OuterClauses = @(),
        [object[]]$CurrentGroupClauses = @(),
        [string]$CurrentGroupOperator,
        [string]$CurrentPlaceholder = '...',
        [ValidateSet('and', 'or')][string]$OuterOperator = 'and'
    )

    $renderOne = { param($Clause) try { Build-NSPAssignmentFilterRule -Clauses @($Clause) } catch { '(...)' } }

    $outerParts = @(@($OuterClauses) | ForEach-Object { & $renderOne $_ })

    $currentText = if ($PSBoundParameters.ContainsKey('CurrentGroupOperator')) {
        $groupParts = @(@($CurrentGroupClauses) | ForEach-Object { & $renderOne $_ }) + @("($CurrentPlaceholder)")
        if ($groupParts.Count -gt 1) { '(' + ($groupParts -join " $CurrentGroupOperator ") + ')' } else { $groupParts[0] }
    } else {
        "($CurrentPlaceholder)"
    }

    Write-Host '  ' -NoNewline
    foreach ($part in $outerParts) {
        Write-Host $part -NoNewline -ForegroundColor Gray
        Write-Host " $OuterOperator " -NoNewline -ForegroundColor DarkGray
    }
    Write-Host $currentText -ForegroundColor Yellow
}
