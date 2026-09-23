function New-NSPIntuneWin32AppAssignment {
    <#
    .SYNOPSIS
        Assigns an existing Win32 app to a group, optionally scoped by an assignment filter.
    .DESCRIPTION
        Plan-only is the default. Use -Execute and approve ShouldProcess to actually create the
        assignment. TargetType 'Group' wraps IntuneWin32App's Add-IntuneWin32AppAssignmentGroup,
        which supports both a plain group assignment and a filter-scoped one. TargetType
        'AllUsers'/'AllDevices' wraps the matching Add-IntuneWin32AppAssignment* virtual-target
        cmdlets instead - Intune has no group object for "all users" or "all devices", so those
        targets skip GroupId entirely, only ever run as an Include, and don't support the
        'availableWithoutEnrollment' intent (the underlying cmdlets reject it). Each call adds
        exactly one assignment; it never creates, deletes, or replaces any existing assignment.
        Intune does not support combining a filter with an Exclude assignment.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$IntuneObjectId,
        [string]$AppDisplayName,
        [ValidateSet('Group', 'AllUsers', 'AllDevices')][string]$TargetType = 'Group',
        [string]$GroupId,
        [string]$GroupDisplayName,
        [Parameter(Mandatory)][ValidateSet('Include', 'Exclude')][string]$Mode,
        [ValidateSet('required', 'available', 'uninstall', 'availableWithoutEnrollment')][string]$Intent = 'required',
        [string]$FilterDisplayName,
        [ValidateSet('Include', 'Exclude')][string]$FilterMode,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [switch]$Execute
    )

    if ($TargetType -eq 'Group' -and -not $GroupId) {
        throw 'GroupId is required when TargetType is Group.'
    }
    if ($TargetType -ne 'Group' -and $Mode -eq 'Exclude') {
        throw "Exclude is not supported for TargetType '$TargetType'; only a specific group can be excluded."
    }
    if ($TargetType -ne 'Group' -and $Intent -eq 'availableWithoutEnrollment') {
        throw "Intent 'availableWithoutEnrollment' is not supported for TargetType '$TargetType'."
    }
    if ($Mode -eq 'Exclude' -and $FilterDisplayName) {
        throw 'A filter cannot be combined with an Exclude assignment; Intune does not support filtering excludes.'
    }
    if ($FilterDisplayName -and -not $FilterMode) {
        throw 'FilterMode is required when FilterDisplayName is specified.'
    }

    $appLabel = if ($AppDisplayName) { $AppDisplayName } else { $IntuneObjectId }
    $targetLabel = switch ($TargetType) {
        'AllUsers' { 'All Users' }
        'AllDevices' { 'All Devices' }
        default { if ($GroupDisplayName) { $GroupDisplayName } else { $GroupId } }
    }
    $filterSuffix = if ($FilterDisplayName) { " filtered by '$FilterDisplayName' ($FilterMode)" } else { '' }
    $actionLabel = "$Mode-assign '$appLabel' to '$targetLabel' ($Intent)$filterSuffix"

    if (-not $Execute) {
        return [pscustomobject]@{
            Status     = 'PlanOnly'
            AppId      = $IntuneObjectId
            TargetType = $TargetType
            GroupId    = $GroupId
            Mode       = $Mode
            Intent     = $Intent
            Filter     = $FilterDisplayName
            Message    = "Run again with -Execute to $actionLabel in tenant $TenantId."
        }
    }

    if (-not $PSCmdlet.ShouldProcess("tenant $TenantId", $actionLabel)) { return }

    if (-not (Get-Module -ListAvailable IntuneWin32App)) {
        Import-NSPBootstrap | Out-Null
        Install-NSPModule -Name IntuneWin32App -Scope CurrentUser
    }
    Import-Module IntuneWin32App -ErrorAction Stop
    Connect-MSIntuneGraph -TenantID $TenantId -ClientID $ClientId | Out-Null

    switch ($TargetType) {
        'AllUsers' {
            $assignArgs = @{ ID = $IntuneObjectId; Intent = $Intent }
            if ($FilterDisplayName) { $assignArgs.FilterName = $FilterDisplayName; $assignArgs.FilterMode = $FilterMode }
            Add-IntuneWin32AppAssignmentAllUsers @assignArgs -ErrorAction Stop | Out-Null
        }
        'AllDevices' {
            $assignArgs = @{ ID = $IntuneObjectId; Intent = $Intent }
            if ($FilterDisplayName) { $assignArgs.FilterName = $FilterDisplayName; $assignArgs.FilterMode = $FilterMode }
            Add-IntuneWin32AppAssignmentAllDevices @assignArgs -ErrorAction Stop | Out-Null
        }
        default {
            $assignArgs = @{ ID = $IntuneObjectId; GroupID = $GroupId; Intent = $Intent }
            if ($Mode -eq 'Include') {
                $assignArgs.Include = $true
                if ($FilterDisplayName) {
                    $assignArgs.FilterName = $FilterDisplayName
                    $assignArgs.FilterMode = $FilterMode
                }
            } else {
                $assignArgs.Exclude = $true
            }
            Add-IntuneWin32AppAssignmentGroup @assignArgs -ErrorAction Stop | Out-Null
        }
    }

    [pscustomobject]@{
        Status     = 'Assigned'
        AppId      = $IntuneObjectId
        TargetType = $TargetType
        GroupId    = $GroupId
        Mode       = $Mode
        Intent     = $Intent
        Filter     = $FilterDisplayName
    }
}
