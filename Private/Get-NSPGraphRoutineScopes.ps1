function Get-NSPGraphRoutineScopes {
    <#
    .SYNOPSIS
        The full set of Graph scopes the registered app has admin consent for, requested by every
        routine (non-registration) Connect-NSPGraph call so one sign-in per dashboard session
        covers every action, regardless of which one runs first.
    .DESCRIPTION
        Register-NSPIntuneWin32AppRegistration grants org-wide admin consent for exactly these
        five permissions up front. Every routine function used to request only its own narrower
        subset (e.g. Group.Read.All for Find-NSPIntuneGroup, DeviceManagementServiceConfig.
        ReadWrite.All for enrollment profiles), which meant whichever action ran first established
        a narrow-scoped token, and the next action needing a scope outside that subset triggered
        its own separate sign-in - "two sign-ins back to back" running [13] after an earlier
        action in the same session had already established a different narrow scope.
        Requesting this same full set everywhere means whichever action runs first establishes a
        session every later action's own (still-narrower) scope check already satisfies, since
        Connect-NSPGraph only reconnects when the existing session is missing a required scope.
    #>
    [CmdletBinding()]
    param()
    @(
        'DeviceManagementApps.ReadWrite.All'
        'DeviceManagementConfiguration.ReadWrite.All'
        'DeviceManagementRBAC.Read.All'
        'Group.Read.All'
        'DeviceManagementServiceConfig.ReadWrite.All'
    )
}
