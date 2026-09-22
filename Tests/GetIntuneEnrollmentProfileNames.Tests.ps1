Describe 'Get-NSPIntuneEnrollmentProfileNames' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'returns Windows Autopilot deployment profile names' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            @(
                [pscustomobject]@{ id = 'profile-1'; displayName = 'Hybrid AutoPilot Shared Device' }
                [pscustomobject]@{ id = 'profile-2'; displayName = 'Example Org AzureAD Joined User Driven - Convert to AutoPilot' }
            )
        } -ModuleName NSP.IntuneApps

        $result = Get-NSPIntuneEnrollmentProfileNames -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Count | Should -Be 2
        $result[0] | Should -BeOfType ([System.Management.Automation.PSCustomObject])
        $result.DisplayName | Should -Contain 'Hybrid AutoPilot Shared Device'
        Should -Invoke Invoke-NSPGraphCollection -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Uri -match 'windowsAutopilotDeploymentProfiles'
        }
    }
}
