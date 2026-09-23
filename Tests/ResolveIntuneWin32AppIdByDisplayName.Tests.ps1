Describe 'Resolve-NSPIntuneWin32AppIdByDisplayName' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'resolves the single matching app id' {
        InModuleScope NSP.IntuneApps {
            Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
            Mock Invoke-NSPGraphCollection {
                @([pscustomobject]@{ id = 'app-1'; displayName = 'FortiClient' })
            } -ModuleName NSP.IntuneApps

            $result = Resolve-NSPIntuneWin32AppIdByDisplayName -DisplayName 'FortiClient' -TenantId 'tenant-1' -ClientId 'client-1'

            $result | Should -Be 'app-1'
            Should -Invoke Invoke-NSPGraphCollection -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
                $Uri -match "displayName eq 'FortiClient'"
            }
        }
    }

    It 'throws when no app matches' {
        InModuleScope NSP.IntuneApps {
            Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
            Mock Invoke-NSPGraphCollection { @() } -ModuleName NSP.IntuneApps

            { Resolve-NSPIntuneWin32AppIdByDisplayName -DisplayName 'Missing App' -TenantId 'tenant-1' -ClientId 'client-1' } |
                Should -Throw '*No Win32 app named*'
        }
    }

    It 'throws rather than guessing when more than one app matches' {
        InModuleScope NSP.IntuneApps {
            Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
            Mock Invoke-NSPGraphCollection {
                @(
                    [pscustomobject]@{ id = 'app-1'; displayName = 'FortiClient' }
                    [pscustomobject]@{ id = 'app-2'; displayName = 'FortiClient' }
                )
            } -ModuleName NSP.IntuneApps

            { Resolve-NSPIntuneWin32AppIdByDisplayName -DisplayName 'FortiClient' -TenantId 'tenant-1' -ClientId 'client-1' } |
                Should -Throw '*Multiple Win32 apps named*cannot resolve unambiguously*'
        }
    }

    It 'escapes an embedded single quote in DisplayName' {
        InModuleScope NSP.IntuneApps {
            Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
            Mock Invoke-NSPGraphCollection { @([pscustomobject]@{ id = 'app-1'; displayName = "O'Brien" }) } -ModuleName NSP.IntuneApps

            Resolve-NSPIntuneWin32AppIdByDisplayName -DisplayName "O'Brien" -TenantId 'tenant-1' -ClientId 'client-1' | Out-Null

            Should -Invoke Invoke-NSPGraphCollection -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
                $Uri -match "O''Brien"
            }
        }
    }
}
