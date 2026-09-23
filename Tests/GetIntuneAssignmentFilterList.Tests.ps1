Describe 'Get-NSPIntuneAssignmentFilterList' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'lists every filter live from the beta assignmentFilters endpoint' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            @(
                [pscustomobject]@{ id = 'filter-1'; displayName = 'Windows - Corporate Devices'; platform = 'windows10AndLater'; rule = '(device.deviceOwnership -eq "Corporate")' }
                [pscustomobject]@{ id = 'filter-2'; displayName = 'Windows - Hybrid Azure AD Join Devices'; platform = 'windows10AndLater'; rule = '(device.deviceTrustType -eq "Hybrid Azure AD joined")' }
            )
        } -ModuleName NSP.IntuneApps

        $result = Get-NSPIntuneAssignmentFilterList -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Count | Should -Be 2
        $result[0].DisplayName | Should -Be 'Windows - Corporate Devices'
        $result[0].Platform | Should -Be 'windows10AndLater'
        Should -Invoke Invoke-NSPGraphCollection -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Uri -eq 'https://graph.microsoft.com/beta/deviceManagement/assignmentFilters'
        }
    }

    It 'returns an empty array when the tenant has no filters' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection { @() } -ModuleName NSP.IntuneApps

        $result = Get-NSPIntuneAssignmentFilterList -TenantId 'tenant-1' -ClientId 'client-1'

        @($result).Count | Should -Be 0
    }
}
