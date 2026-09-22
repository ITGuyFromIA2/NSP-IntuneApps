function Get-NSPIntuneEnrollmentProfileNames {
    <#
    .SYNOPSIS
        Returns enrollment profile display names for assignment-filter picklists.
    .DESCRIPTION
        Read-only. Covers Windows Autopilot deployment profiles only for now - the platform
        behind every real device.enrollmentProfileName example seen so far (Android/Apple
        enrollment profile sources are a separate Graph surface and are not yet included).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId
    )

    Connect-NSPGraph -Scopes 'DeviceManagementServiceConfig.ReadWrite.All' -Connect -ClientId $ClientId -TenantId $TenantId | Out-Null

    $uri = 'https://graph.microsoft.com/v1.0/deviceManagement/windowsAutopilotDeploymentProfiles?$select=id,displayName'
    @(Invoke-NSPGraphCollection -Uri $uri | ForEach-Object { [pscustomobject][ordered]@{ Id = [string]$_.id; DisplayName = [string]$_.displayName } })
}
