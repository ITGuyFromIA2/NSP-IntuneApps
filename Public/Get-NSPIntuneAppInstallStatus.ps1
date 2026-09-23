function Get-NSPIntuneAppInstallStatus {
    <#
    .SYNOPSIS
        Reads per-device (and per-user) install status for one Win32 app, live from Graph.
    .DESCRIPTION
        Read-only - no plan/execute split needed, matching Get-NSPIntuneAppAssignmentInventory's
        own shape. Summarizes deviceStatuses/userStatuses counts by installState alongside the raw
        per-record lists, so an operator can see how a just-created (or long-deployed) app actually
        landed without leaving the tool. Deliberately scoped to one app at a time - tenant-wide
        fleet drift/reporting is docs/Architecture.md's own stated NSP-IntuneManager territory, not
        this Apps workbench's job.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$IntuneObjectId,
        [string]$AppDisplayName,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId
    )

    $graphContext = Connect-NSPGraph -Scopes (Get-NSPGraphRoutineScopes) -Connect -ClientId $ClientId -TenantId $TenantId

    $deviceStatuses = @(Invoke-NSPGraphCollection -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$IntuneObjectId/deviceStatuses")
    $userStatuses = @(Invoke-NSPGraphCollection -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$IntuneObjectId/userStatuses")

    $deviceStatusSummary = @($deviceStatuses | Group-Object -Property installState | Sort-Object -Property Name | ForEach-Object {
        [pscustomobject]@{ InstallState = $_.Name; Count = $_.Count }
    })

    [pscustomobject]@{
        AppId               = $IntuneObjectId
        AppDisplayName      = $AppDisplayName
        TenantId            = $graphContext.TenantId
        Account             = $graphContext.Account
        DeviceCount         = $deviceStatuses.Count
        DeviceStatusSummary = $deviceStatusSummary
        DeviceStatuses      = $deviceStatuses
        UserCount           = $userStatuses.Count
        UserStatuses        = $userStatuses
    }
}
