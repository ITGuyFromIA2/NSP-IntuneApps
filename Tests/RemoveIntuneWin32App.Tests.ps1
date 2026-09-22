$script:intuneWin32AppAvailable = [bool](Get-Module -ListAvailable IntuneWin32App)

Describe 'Remove-NSPIntuneWin32App' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
        if ($script:intuneWin32AppAvailable) { Import-Module IntuneWin32App -Force }
    }

    It 'reports a plan without connecting to any tenant when -Execute is not passed' {
        $result = Remove-NSPIntuneWin32App -IntuneObjectId 'intune-app-1' -DisplayName 'Fixture App' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.Message | Should -Match 'cannot be undone'
    }

    It 'deletes the app when -Execute is passed' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Remove-IntuneWin32App { } -ModuleName NSP.IntuneApps

        $result = Remove-NSPIntuneWin32App -IntuneObjectId 'intune-app-1' -DisplayName 'Fixture App' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Deleted'
        Should -Invoke Remove-IntuneWin32App -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter { $ID -eq 'intune-app-1' }
    }

    It 'deletes nothing under -WhatIf' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { throw 'should not be called' } -ModuleName NSP.IntuneApps
        Mock Remove-IntuneWin32App { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $result = Remove-NSPIntuneWin32App -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -WhatIf
        $result | Should -BeNullOrEmpty
    }
}
