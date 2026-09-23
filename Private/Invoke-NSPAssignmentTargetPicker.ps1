function Invoke-NSPAssignmentTargetPicker {
    <#
    .SYNOPSIS
        Interactively picks one assignment target: All Users, All Devices, a previously-used
        group, or a live tenant group search.
    .DESCRIPTION
        Shared by every dashboard flow that needs one group/target picked for an assignment -
        the per-app "assign now" flow and the tenant master-defaults editor both need exactly
        this same picker, so it lives here instead of being duplicated.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [object[]]$KnownGroups = @()
    )

    $target = $null
    do {
        Write-Host 'Pick a group:' -ForegroundColor Cyan
        Write-Host '  [U] All Users'
        Write-Host '  [D] All Devices'
        if (@($KnownGroups).Count -gt 0) {
            Write-Host '  [K] Choose from groups already used for assignment (from the last [13] harvest)'
        }
        Write-Host '  [S] Search all tenant groups by name'
        $groupSourceAllowed = @(@('U', 'D', 'S') + $(if (@($KnownGroups).Count -gt 0) { 'K' }))
        $groupSource = Read-NSPMenuChoice -Prompt 'Source' -Allowed $groupSourceAllowed -Default 'S'
        if ($groupSource -eq 'U') {
            $target = [pscustomobject]@{ TargetType = 'AllUsers'; Id = $null; DisplayName = 'All Users' }
        } elseif ($groupSource -eq 'D') {
            $target = [pscustomobject]@{ TargetType = 'AllDevices'; Id = $null; DisplayName = 'All Devices' }
        } elseif ($groupSource -eq 'K') {
            for ($index = 0; $index -lt $KnownGroups.Count; $index++) { Write-Host ("  [{0}] {1} | {2}" -f ($index + 1), $KnownGroups[$index].GroupDisplayName, $KnownGroups[$index].GroupId) }
            $groupChoice = Read-NSPMenuChoice -Prompt 'Group' -Allowed @(1..$KnownGroups.Count | ForEach-Object { [string]$_ })
            $target = [pscustomobject]@{ TargetType = 'Group'; Id = $KnownGroups[[int]$groupChoice - 1].GroupId; DisplayName = $KnownGroups[[int]$groupChoice - 1].GroupDisplayName }
        } else {
            $searchTerm = Read-Host 'Search groups (matches anywhere in the name), or leave blank to list all groups'
            $matches = @(Find-NSPIntuneGroup -NameContains $searchTerm -TenantId $TenantId -ClientId $ClientId)
            if ($matches.Count -eq 0) {
                Write-Warning 'No matching groups were found. Try a different search.'
            } else {
                for ($index = 0; $index -lt $matches.Count; $index++) { Write-Host ("  [{0}] {1} | {2}" -f ($index + 1), $matches[$index].DisplayName, $matches[$index].Id) }
                Write-Host '  [R] Search again'
                $matchAllowed = @(@(1..$matches.Count | ForEach-Object { [string]$_ }) + 'R')
                $matchChoice = Read-NSPMenuChoice -Prompt 'Group' -Allowed $matchAllowed -Default 'R'
                if ($matchChoice -ne 'R') { $target = [pscustomobject]@{ TargetType = 'Group'; Id = $matches[[int]$matchChoice - 1].Id; DisplayName = $matches[[int]$matchChoice - 1].DisplayName } }
            }
        }
    } while (-not $target)
    $target
}
