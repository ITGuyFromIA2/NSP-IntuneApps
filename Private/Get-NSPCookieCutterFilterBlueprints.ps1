function Get-NSPCookieCutterFilterBlueprints {
    <#
    .SYNOPSIS
        The standard, tenant-agnostic assignment filter blueprints any NSP tenant can reuse as-is.
    .DESCRIPTION
        Each blueprint uses only stable Graph device/app properties and Microsoft's own fixed
        enum values - never a tenant-specific enrollment profile name, device category, or
        hardcoded device list - so the same DisplayName/Platform/Rule/ManagementType can be
        created unchanged in any tenant. Drawn from comparing real assignment-filter inventories
        across multiple client tenants: deviceOwnership and deviceTrustType clauses recur
        verbatim, while enrollment-profile-name and hardcoded-device-name filters never do.

        New-NSPCookieCutterAssignmentFilters plans/creates these; this is just the static catalog.
    #>
    [CmdletBinding()]
    param()
    @(
        [pscustomobject]@{
            DisplayName    = 'Windows - Hybrid Azure AD Join Devices'
            Platform       = 'windows10AndLater'
            ManagementType = 'devices'
            Rule           = '(device.deviceTrustType -eq "Hybrid Azure AD joined")'
        }
        [pscustomobject]@{
            DisplayName    = 'Windows - Corporate Devices'
            Platform       = 'windows10AndLater'
            ManagementType = 'devices'
            Rule           = '(device.deviceOwnership -eq "Corporate")'
        }
        [pscustomobject]@{
            DisplayName    = 'Windows - Personal Devices'
            Platform       = 'windows10AndLater'
            ManagementType = 'devices'
            Rule           = '(device.deviceOwnership -eq "Personal")'
        }
        [pscustomobject]@{
            DisplayName    = 'Android - Corporate Devices'
            Platform       = 'androidForWork'
            ManagementType = 'devices'
            Rule           = '(device.deviceOwnership -eq "Corporate")'
        }
        [pscustomobject]@{
            DisplayName    = 'Android - Personal Devices'
            Platform       = 'androidForWork'
            ManagementType = 'devices'
            Rule           = '(device.deviceOwnership -eq "Personal")'
        }
        [pscustomobject]@{
            DisplayName    = 'Android Enterprise - Corporate-Owned (No Shared Mode)'
            Platform       = 'androidMobileApplicationManagement'
            ManagementType = 'apps'
            Rule           = '(app.deviceManagementType -eq "Corporate-owned dedicated devices without Entra ID Shared mode") or (app.deviceManagementType -eq "Corporate-owned fully managed") or (app.deviceManagementType -eq "Corporate-owned with work profile") or (app.deviceManagementType -eq "Personally-owned work profile")'
        }
        [pscustomobject]@{
            DisplayName    = 'Android Enterprise - Corporate-Owned WITH Shared Mode'
            Platform       = 'androidMobileApplicationManagement'
            ManagementType = 'apps'
            Rule           = '(app.deviceManagementType -eq "Corporate-owned dedicated devices with Entra ID Shared mode")'
        }
    )
}
