function Build-NSPAssignmentFilterRule {
    <#
    .SYNOPSIS
        Assembles an Intune assignment filter rule string from one or more AND-joined clauses.
    .DESCRIPTION
        Pure and offline: no Graph calls, no tenant knowledge. Each clause becomes its own
        parenthesized term; multiple clauses are joined with 'and'. OR and explicit grouping
        are a deliberate, planned V2 extension, not an oversight - real tenant filters
        (e.g. "(A) and (B)) or (C)") need them, but V1 covers the common AND-chain case.
        Each clause is a hashtable/object with Property, Operator, and Value. Operator is one
        of: eq, ne, in, notIn, contains, notContains, startsWith, notStartsWith. Value is a
        single value for eq/ne/startsWith/notStartsWith (or the literal string 'Null'), or an
        array of values for in/notIn/contains/notContains.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object[]]$Clauses
    )

    if (@($Clauses).Count -eq 0) { throw 'At least one clause is required.' }

    $allowedOperators = @('eq', 'ne', 'in', 'notIn', 'contains', 'notContains', 'startsWith', 'notStartsWith')
    $listOperators = @('in', 'notIn', 'contains', 'notContains')

    $terms = foreach ($clause in $Clauses) {
        $property = [string]$clause.Property
        $operator = [string]$clause.Operator
        if ([string]::IsNullOrWhiteSpace($property)) { throw 'Each clause needs a Property.' }
        if ($operator -notin $allowedOperators) { throw "Unsupported operator '$operator'. Use one of: $($allowedOperators -join ', ')." }

        $valueText = if ($operator -in $listOperators) {
            $values = @($clause.Value)
            if ($values.Count -eq 0) { throw "Operator '$operator' needs at least one value." }
            '[' + (($values | ForEach-Object { '"' + ([string]$_).Replace('"', '\"') + '"' }) -join ',') + ']'
        } elseif ([string]$clause.Value -eq 'Null') {
            'Null'
        } else {
            '"' + ([string]$clause.Value).Replace('"', '\"') + '"'
        }

        "($property -$operator $valueText)"
    }

    $terms -join ' and '
}
