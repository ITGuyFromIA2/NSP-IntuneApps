Describe 'Get-NSPIntuneEnrollmentProfileNames' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'returns Windows Autopilot deployment profile names' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            if ($Uri -match 'windowsAutopilotDeploymentProfiles') {
                return @(
                    [pscustomobject]@{ id = 'profile-1'; displayName = 'Hybrid AutoPilot Shared Device' }
                    [pscustomobject]@{ id = 'profile-2'; displayName = 'Example Org AzureAD Joined User Driven - Convert to AutoPilot' }
                )
            }
            return @()
        } -ModuleName NSP.IntuneApps

        $result = Get-NSPIntuneEnrollmentProfileNames -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Count | Should -Be 2
        $result[0] | Should -BeOfType ([System.Management.Automation.PSCustomObject])
        $result.DisplayName | Should -Contain 'Hybrid AutoPilot Shared Device'
        $result[0].Platform | Should -Be 'Windows'
        Should -Invoke Invoke-NSPGraphCollection -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Uri -match 'windowsAutopilotDeploymentProfiles'
        }
    }

    It 'returns Apple ADE enrollment profiles from each depOnboardingSettings entry' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            if ($Uri -match 'depOnboardingSettings\?') {
                return @([pscustomobject]@{ id = 'dep-1' })
            }
            if ($Uri -match 'depOnboardingSettings/dep-1/enrollmentProfiles') {
                return @([pscustomobject]@{ id = 'apple-profile-1'; displayName = 'iOS Supervised Devices' })
            }
            return @()
        } -ModuleName NSP.IntuneApps

        $result = Get-NSPIntuneEnrollmentProfileNames -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Count | Should -Be 1
        $result[0].Platform | Should -Be 'Apple'
        $result[0].DisplayName | Should -Be 'iOS Supervised Devices'
    }

    It 'returns Android device-owner enrollment profiles' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            if ($Uri -match 'androidDeviceOwnerEnrollmentProfiles') {
                return @([pscustomobject]@{ id = 'android-profile-1'; displayName = 'Dedicated Kiosk Devices' })
            }
            return @()
        } -ModuleName NSP.IntuneApps

        $result = Get-NSPIntuneEnrollmentProfileNames -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Count | Should -Be 1
        $result[0].Platform | Should -Be 'Android'
        $result[0].DisplayName | Should -Be 'Dedicated Kiosk Devices'
    }

    It 'combines all three platforms and is not blocked by one platform erroring' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            if ($Uri -match 'windowsAutopilotDeploymentProfiles') {
                return @([pscustomobject]@{ id = 'win-1'; displayName = 'Windows Profile' })
            }
            if ($Uri -match 'depOnboardingSettings\?') {
                throw 'Resource not found for the segment depOnboardingSettings'
            }
            if ($Uri -match 'androidDeviceOwnerEnrollmentProfiles') {
                return @([pscustomobject]@{ id = 'android-1'; displayName = 'Android Profile' })
            }
            return @()
        } -ModuleName NSP.IntuneApps

        $result = Get-NSPIntuneEnrollmentProfileNames -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Count | Should -Be 2
        $result.Platform | Should -Contain 'Windows'
        $result.Platform | Should -Contain 'Android'
    }

    It 'returns an empty list rather than throwing when every platform lookup fails' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection { throw 'Resource not found' } -ModuleName NSP.IntuneApps

        { $script:result = Get-NSPIntuneEnrollmentProfileNames -TenantId 'tenant-1' -ClientId 'client-1' } | Should -Not -Throw
        $script:result.Count | Should -Be 0
    }
}
