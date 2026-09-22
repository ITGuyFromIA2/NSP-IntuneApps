$script:intuneWin32AppAvailable = [bool](Get-Module -ListAvailable IntuneWin32App)

Describe 'Update-NSPIntuneWin32AppContent' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
        if ($script:intuneWin32AppAvailable) { Import-Module IntuneWin32App -Force }
    }

    It 'reports a plan without connecting to any tenant when -Execute is not passed' {
        $packagePath = Join-Path $TestDrive 'Fixture.intunewin'
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        $result = Update-NSPIntuneWin32AppContent -AppName 'Fixture' -PackagePath $packagePath -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.IntuneObjectId | Should -Be 'intune-app-1'
    }

    It 'throws when the package file does not exist' {
        { Update-NSPIntuneWin32AppContent -AppName 'Fixture' -PackagePath (Join-Path $TestDrive 'nope.intunewin') -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw '*Package not found*'
    }

    It 'uploads the new content version and preserves the existing object ID' -Skip:(-not $script:intuneWin32AppAvailable) {
        $packagePath = Join-Path $TestDrive 'Fixture.intunewin'
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Update-IntuneWin32AppPackageFile { } -ModuleName NSP.IntuneApps

        $result = Update-NSPIntuneWin32AppContent -AppName 'Fixture' -PackagePath $packagePath -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Updated'
        $result.IntuneObjectId | Should -Be 'intune-app-1'
        Should -Invoke Update-IntuneWin32AppPackageFile -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $ID -eq 'intune-app-1' -and $FilePath -eq $packagePath
        }
    }

    It 'uploads nothing under -WhatIf' -Skip:(-not $script:intuneWin32AppAvailable) {
        $packagePath = Join-Path $TestDrive 'Fixture.intunewin'
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        Mock Connect-MSIntuneGraph { throw 'should not be called' } -ModuleName NSP.IntuneApps
        Mock Update-IntuneWin32AppPackageFile { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $result = Update-NSPIntuneWin32AppContent -AppName 'Fixture' -PackagePath $packagePath -IntuneObjectId 'intune-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -WhatIf
        $result | Should -BeNullOrEmpty
    }
}
