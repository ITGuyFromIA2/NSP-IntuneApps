function Read-NSPFilterClause {
    <#
    .SYNOPSIS
        Interactively collects one leaf filter clause (Property/Operator/Value).
    .DESCRIPTION
        Shared by the dashboard's guided filter builder for both its top-level clause loop and
        an OR-group's own inner loop, so the two don't duplicate the property/operator/value
        prompts (including the enrollment-profile and static-value-set picklists).

        Property/Operator/Value is a genuine undo-able sequence of prompts with nothing mutating
        interleaved between them, so it offers 'B'/'Back' navigation between its own three steps
        (reusing Read-NSPMenuChoice's -AllowBack and CA-Manager's established 'B'/'Back'
        convention) - Operator can step back to re-pick Property, and Value can step back to
        re-pick Operator. Stepping back re-runs the step it lands on from scratch (the previous
        answer for that step is discarded), the same "recompute fresh" convention CA-Manager's
        own wizard driver uses. There is no back out of Property itself - it is this function's
        first step, with nothing before it to return to.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$TenantId, [Parameter(Mandatory)][string]$ClientId, [string]$Platform)

    $commonProperties = @('device.deviceOwnership', 'device.manufacturer', 'device.model', 'device.deviceName', 'device.deviceCategory', 'device.enrollmentProfileName', 'device.deviceTrustType', 'device.osVersion', 'app.deviceManagementType', 'app.deviceManufacturer')
    $operators = @('eq', 'ne', 'in', 'notIn', 'contains', 'notContains', 'startsWith', 'notStartsWith')
    $listOperators = @('in', 'notIn', 'contains', 'notContains')
    $staticValueSets = [ordered]@{
        'device.deviceOwnership' = @('Corporate', 'Personal', 'Unknown')
        'device.deviceTrustType'  = @('AzureAd', 'ServerAd', 'Workplace')
    }

    $property = $null
    $operator = $null
    $value = $null
    $step = 0   # 0 = Property, 1 = Operator, 2 = Value
    while ($step -lt 3) {
        if ($step -eq 0) {
            for ($index = 0; $index -lt $commonProperties.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $commonProperties[$index]) }
            Write-Host '  [O] Other (type it)'
            $propertyAllowed = @(@(1..$commonProperties.Count | ForEach-Object { [string]$_ }) + 'O')
            $propertyChoice = Read-NSPMenuChoice -Prompt 'Property' -Allowed $propertyAllowed -Default '1'
            $property = if ($propertyChoice -eq 'O') { Read-Host 'Property (e.g. device.osVersion)' } else { $commonProperties[[int]$propertyChoice - 1] }
            $step = 1
        } elseif ($step -eq 1) {
            for ($index = 0; $index -lt $operators.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $operators[$index]) }
            Write-Host '  [B] Back'
            $operatorChoice = Read-NSPMenuChoice -Prompt 'Operator' -Allowed @(1..$operators.Count | ForEach-Object { [string]$_ }) -Default '1' -AllowBack
            if ($operatorChoice -eq 'B') {
                $step = 0
            } else {
                $operator = $operators[[int]$operatorChoice - 1]
                $step = 2
            }
        } else {
            $value = $null
            $backRequested = $false
            if ($property -eq 'device.enrollmentProfileName') {
                Write-Host 'Harvesting enrollment profile names (Windows Autopilot, Apple ADE, Android dedicated-device)...' -ForegroundColor DarkGray
                $allProfiles = @(Get-NSPIntuneEnrollmentProfileNames -TenantId $TenantId -ClientId $ClientId)
                $platformKey = if ($Platform -eq 'windows10AndLater') { 'Windows' } elseif ($Platform -eq 'iOS') { 'Apple' } elseif ($Platform -like 'android*') { 'Android' } else { $null }
                $profiles = if ($platformKey) { @($allProfiles | Where-Object Platform -eq $platformKey) } else { $allProfiles }
                if ($profiles.Count -eq 0) {
                    Write-Warning 'No matching enrollment profiles were found. Falling back to free text.'
                } else {
                    for ($index = 0; $index -lt $profiles.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $profiles[$index].DisplayName) }
                    $profilePick = Read-Host ("Profile number(s), comma-separated for {0}, or 'B' to go back" -f $operator)
                    if ($profilePick.Trim() -match '^(?i)b(ack)?$') {
                        $backRequested = $true
                    } else {
                        $pickedIndexes = @($profilePick -split ',' | ForEach-Object Trim | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ - 1 })
                        $value = @($pickedIndexes | ForEach-Object { $profiles[$_].DisplayName })
                    }
                }
            } elseif ($staticValueSets.Contains($property)) {
                $pickOptions = $staticValueSets[$property]
                for ($index = 0; $index -lt $pickOptions.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $pickOptions[$index]) }
                Write-Host '  [O] Other (type it)'
                $optionAllowed = @(@(1..$pickOptions.Count | ForEach-Object { [string]$_ }) + 'O')
                if ($operator -in $listOperators) {
                    $pick = Read-Host ("Value number(s), comma-separated, or 'O' for other, or 'B' to go back, for {0}" -f $operator)
                    if ($pick.Trim() -match '^(?i)b(ack)?$') {
                        $backRequested = $true
                    } elseif ($pick.Trim() -eq 'O') {
                        $value = $null
                    } else {
                        $pickedIndexes = @($pick -split ',' | ForEach-Object Trim | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ - 1 })
                        $value = @($pickedIndexes | ForEach-Object { $pickOptions[$_] })
                    }
                } else {
                    $valueChoice = Read-NSPMenuChoice -Prompt 'Value' -Allowed $optionAllowed -Default '1' -AllowBack
                    if ($valueChoice -eq 'B') {
                        $backRequested = $true
                    } else {
                        $value = if ($valueChoice -eq 'O') { $null } else { $pickOptions[[int]$valueChoice - 1] }
                    }
                }
            }
            if (-not $backRequested -and -not $value) {
                if ($operator -in $listOperators) {
                    $rawValue = Read-Host "Value(s), comma-separated, or 'B' to go back"
                    if ($rawValue.Trim() -match '^(?i)b(ack)?$') {
                        $backRequested = $true
                    } else {
                        $value = @($rawValue -split ',' | ForEach-Object Trim | Where-Object { $_ })
                    }
                } else {
                    $rawValue = Read-Host "Value (or 'Null'), or 'B' to go back"
                    if ($rawValue.Trim() -match '^(?i)b(ack)?$') { $backRequested = $true } else { $value = $rawValue }
                }
            }
            $step = if ($backRequested) { 1 } else { 3 }
        }
    }

    @{ Property = $property; Operator = $operator; Value = $value }
}
