Describe 'Get-NSPIntuneAppInstallStatus' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'summarizes device install states and passes through the raw per-device list' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            if ($Uri -match '/deviceStatuses$') {
                return @(
                    [pscustomobject]@{ deviceName = 'PC-1'; installState = 'installed' }
                    [pscustomobject]@{ deviceName = 'PC-2'; installState = 'installed' }
                    [pscustomobject]@{ deviceName = 'PC-3'; installState = 'failed' }
                )
            }
            if ($Uri -match '/userStatuses$') { return @([pscustomobject]@{ userName = 'user1@example.com'; installState = 'installed' }) }
            @()
        } -ModuleName NSP.IntuneApps

        $result = Get-NSPIntuneAppInstallStatus -IntuneObjectId 'app-1' -AppDisplayName 'Fixture App' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.DeviceCount | Should -Be 3
        $result.UserCount | Should -Be 1
        ($result.DeviceStatusSummary | Where-Object InstallState -eq 'installed').Count | Should -Be 2
        ($result.DeviceStatusSummary | Where-Object InstallState -eq 'failed').Count | Should -Be 1
        $result.DeviceStatuses.Count | Should -Be 3
        Should -Invoke Invoke-NSPGraphCollection -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter { $Uri -eq 'https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/app-1/deviceStatuses' }
    }

    It 'returns zero counts when the app has no reported statuses yet' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection { @() } -ModuleName NSP.IntuneApps

        $result = Get-NSPIntuneAppInstallStatus -IntuneObjectId 'app-1' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.DeviceCount | Should -Be 0
        @($result.DeviceStatusSummary).Count | Should -Be 0
    }
}
