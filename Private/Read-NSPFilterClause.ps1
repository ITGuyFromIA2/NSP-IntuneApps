function Read-NSPFilterClause {
    <#
    .SYNOPSIS
        Interactively collects one leaf filter clause (Property/Operator/Value).
    .DESCRIPTION
        Shared by the dashboard's guided filter builder for both its top-level clause loop and
        an OR-group's own inner loop, so the two don't duplicate the property/operator/value
        prompts (including the enrollment-profile and static-value-set picklists).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$TenantId, [Parameter(Mandatory)][string]$ClientId, [string]$Platform)

    $commonProperties = @('device.deviceOwnership', 'device.manufacturer', 'device.model', 'device.deviceName', 'device.deviceCategory', 'device.enrollmentProfileName', 'device.deviceTrustType', 'device.osVersion', 'app.deviceManagementType', 'app.deviceManufacturer')
    $operators = @('eq', 'ne', 'in', 'notIn', 'contains', 'notContains', 'startsWith', 'notStartsWith')
    $listOperators = @('in', 'notIn', 'contains', 'notContains')

    for ($index = 0; $index -lt $commonProperties.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $commonProperties[$index]) }
    Write-Host '  [O] Other (type it)'
    $propertyAllowed = @(@(1..$commonProperties.Count | ForEach-Object { [string]$_ }) + 'O')
    $propertyChoice = Read-NSPMenuChoice -Prompt 'Property' -Allowed $propertyAllowed -Default '1'
    $property = if ($propertyChoice -eq 'O') { Read-Host 'Property (e.g. device.osVersion)' } else { $commonProperties[[int]$propertyChoice - 1] }

    for ($index = 0; $index -lt $operators.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $operators[$index]) }
    $operatorChoice = Read-NSPMenuChoice -Prompt 'Operator' -Allowed @(1..$operators.Count | ForEach-Object { [string]$_ }) -Default '1'
    $operator = $operators[[int]$operatorChoice - 1]

    $staticValueSets = [ordered]@{
        'device.deviceOwnership' = @('Corporate', 'Personal', 'Unknown')
        'device.deviceTrustType'  = @('AzureAd', 'ServerAd', 'Workplace')
    }
    $value = $null
    if ($property -eq 'device.enrollmentProfileName') {
        Write-Host 'Harvesting enrollment profile names (Windows Autopilot, Apple ADE, Android dedicated-device)...' -ForegroundColor DarkGray
        $allProfiles = @(Get-NSPIntuneEnrollmentProfileNames -TenantId $TenantId -ClientId $ClientId)
        $platformKey = if ($Platform -eq 'windows10AndLater') { 'Windows' } elseif ($Platform -eq 'iOS') { 'Apple' } elseif ($Platform -like 'android*') { 'Android' } else { $null }
        $profiles = if ($platformKey) { @($allProfiles | Where-Object Platform -eq $platformKey) } else { $allProfiles }
        if ($profiles.Count -eq 0) {
            Write-Warning 'No matching enrollment profiles were found. Falling back to free text.'
        } else {
            for ($index = 0; $index -lt $profiles.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $profiles[$index].DisplayName) }
            $profilePick = Read-Host ("Profile number(s), comma-separated for {0}" -f $operator)
            $pickedIndexes = @($profilePick -split ',' | ForEach-Object Trim | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ - 1 })
            $value = @($pickedIndexes | ForEach-Object { $profiles[$_].DisplayName })
        }
    } elseif ($staticValueSets.Contains($property)) {
        $pickOptions = $staticValueSets[$property]
        for ($index = 0; $index -lt $pickOptions.Count; $index++) { Write-Host ("  [{0}] {1}" -f ($index + 1), $pickOptions[$index]) }
        Write-Host '  [O] Other (type it)'
        $optionAllowed = @(@(1..$pickOptions.Count | ForEach-Object { [string]$_ }) + 'O')
        if ($operator -in $listOperators) {
            $pick = Read-Host ("Value number(s), comma-separated, or 'O' for other, for {0}" -f $operator)
            if ($pick.Trim() -eq 'O') {
                $value = $null
            } else {
                $pickedIndexes = @($pick -split ',' | ForEach-Object Trim | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ - 1 })
                $value = @($pickedIndexes | ForEach-Object { $pickOptions[$_] })
            }
        } else {
            $valueChoice = Read-NSPMenuChoice -Prompt 'Value' -Allowed $optionAllowed -Default '1'
            $value = if ($valueChoice -eq 'O') { $null } else { $pickOptions[[int]$valueChoice - 1] }
        }
    }
    if (-not $value) {
        if ($operator -in $listOperators) {
            $rawValue = Read-Host 'Value(s), comma-separated'
            $value = @($rawValue -split ',' | ForEach-Object Trim | Where-Object { $_ })
        } else {
            $value = Read-Host "Value (or 'Null')"
        }
    }

    @{ Property = $property; Operator = $operator; Value = $value }
}
