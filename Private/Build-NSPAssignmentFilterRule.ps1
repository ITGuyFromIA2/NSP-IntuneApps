function Build-NSPAssignmentFilterRule {
    <#
    .SYNOPSIS
        Assembles an Intune assignment filter rule string from one or more clauses, joined by
        'and' or 'or', with optional nested parenthesized groups (V2: real tenant filters like
        Android enrollment-profile ones routinely mix and/or with explicit grouping).
    .DESCRIPTION
        Pure and offline: no Graph calls, no tenant knowledge. Each entry in -Clauses is either
        a leaf (a hashtable/object with Property, Operator, Value - unchanged from V1) or a
        group (a hashtable/object with its own Clauses array and, optionally, its own Operator -
        'and' by default). A leaf becomes its own parenthesized term; a group recurses and, when
        it has more than one clause, wraps the recursive result in one more pair of parens so it
        combines unambiguously with whatever it is joined into, e.g.
        "(device.osVersion -ge "10.0.19044") and ((device.manufacturer -eq "Dell") or
        (device.manufacturer -eq "HP"))". -Operator sets how the top-level -Clauses are joined;
        it defaults to 'and', so every V1 call (a flat array of leaves, no -Operator) renders
        identically to before. Leaf Operator is one of: eq, ne, in, notIn, contains, notContains,
        startsWith, notStartsWith. Value is a single value for eq/ne/startsWith/notStartsWith (or
        the literal string 'Null'), or an array of values for in/notIn/contains/notContains.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object[]]$Clauses,
        [ValidateSet('and', 'or')][string]$Operator = 'and'
    )

    if (@($Clauses).Count -eq 0) { throw 'At least one clause is required.' }

    $allowedOperators = @('eq', 'ne', 'in', 'notIn', 'contains', 'notContains', 'startsWith', 'notStartsWith')
    $listOperators = @('in', 'notIn', 'contains', 'notContains')

    $terms = foreach ($clause in $Clauses) {
        $nestedClauses = if ($clause -is [hashtable]) {
            if ($clause.ContainsKey('Clauses')) { $clause.Clauses } else { $null }
        } elseif ($clause.PSObject.Properties['Clauses']) {
            $clause.Clauses
        } else {
            $null
        }

        if ($nestedClauses) {
            $groupOperator = if ($clause.Operator) { [string]$clause.Operator } else { 'and' }
            $inner = Build-NSPAssignmentFilterRule -Clauses @($nestedClauses) -Operator $groupOperator
            if (@($nestedClauses).Count -gt 1) { "($inner)" } else { $inner }
        } else {
            $property = [string]$clause.Property
            $leafOperator = [string]$clause.Operator
            if ([string]::IsNullOrWhiteSpace($property)) { throw 'Each clause needs a Property.' }
            if ($leafOperator -notin $allowedOperators) { throw "Unsupported operator '$leafOperator'. Use one of: $($allowedOperators -join ', ')." }

            $valueText = if ($leafOperator -in $listOperators) {
                $values = @($clause.Value)
                if ($values.Count -eq 0) { throw "Operator '$leafOperator' needs at least one value." }
                '[' + (($values | ForEach-Object { '"' + ([string]$_).Replace('"', '\"') + '"' }) -join ',') + ']'
            } elseif ([string]$clause.Value -eq 'Null') {
                'Null'
            } else {
                '"' + ([string]$clause.Value).Replace('"', '\"') + '"'
            }

            "($property -$leafOperator $valueText)"
        }
    }

    $terms -join " $Operator "
}
