function Get-NSPIntuneEnrollmentProfileNames {
    <#
    .SYNOPSIS
        Returns enrollment profile display names for assignment-filter picklists.
    .DESCRIPTION
        Read-only. Covers three platform-specific enrollment profile surfaces: Windows Autopilot
        deployment profiles (v1.0, tenant-verified against two real tenants), Apple Automated
        Device Enrollment profiles (beta, one query per Apple MDM Push token's own
        depOnboardingSettings), and Android Enterprise corporate-owned dedicated-device
        enrollment profiles (beta). The Apple and Android lookups are not yet verified against a
        live tenant with either configured, unlike the Windows one - each platform's query is
        wrapped so a renamed/unsupported endpoint for a given tenant yields zero results for that
        platform only (the dashboard falls back to free text, same as "no profiles found" today)
        rather than failing the whole call.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId
    )

    Connect-NSPGraph -Scopes 'DeviceManagementServiceConfig.ReadWrite.All' -Connect -ClientId $ClientId -TenantId $TenantId | Out-Null

    $profiles = [Collections.Generic.List[object]]::new()

    try {
        $windowsUri = 'https://graph.microsoft.com/v1.0/deviceManagement/windowsAutopilotDeploymentProfiles?$select=id,displayName'
        foreach ($item in @(Invoke-NSPGraphCollection -Uri $windowsUri)) {
            $profiles.Add([pscustomobject][ordered]@{ Platform = 'Windows'; Id = [string]$item.id; DisplayName = [string]$item.displayName })
        }
    } catch { }

    try {
        $depSettingsUri = 'https://graph.microsoft.com/beta/deviceManagement/depOnboardingSettings?$select=id'
        foreach ($setting in @(Invoke-NSPGraphCollection -Uri $depSettingsUri)) {
            try {
                $appleUri = "https://graph.microsoft.com/beta/deviceManagement/depOnboardingSettings/$($setting.id)/enrollmentProfiles?`$select=id,displayName"
                foreach ($item in @(Invoke-NSPGraphCollection -Uri $appleUri)) {
                    $profiles.Add([pscustomobject][ordered]@{ Platform = 'Apple'; Id = [string]$item.id; DisplayName = [string]$item.displayName })
                }
            } catch { }
        }
    } catch { }

    try {
        $androidUri = 'https://graph.microsoft.com/beta/deviceManagement/androidDeviceOwnerEnrollmentProfiles?$select=id,displayName'
        foreach ($item in @(Invoke-NSPGraphCollection -Uri $androidUri)) {
            $profiles.Add([pscustomobject][ordered]@{ Platform = 'Android'; Id = [string]$item.id; DisplayName = [string]$item.displayName })
        }
    } catch { }

    @($profiles)
}
