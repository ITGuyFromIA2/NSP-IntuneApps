Describe 'Connect-NSPGraph' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    Context 'without an existing Graph context' {
        It 'throws when a context is required' {
            InModuleScope NSP.IntuneApps {
                { Connect-NSPGraph -Scopes 'DeviceManagementApps.Read.All' } | Should -Throw '*No Microsoft Graph context is available*'
            }
        }

        It 'returns $null when the context is optional' {
            InModuleScope NSP.IntuneApps {
                Connect-NSPGraph -Scopes 'DeviceManagementApps.Read.All' -Optional | Should -Be $null
            }
        }
    }

    Context 'with an existing Graph context' {
        It 'returns the context when all required scopes are present' {
            InModuleScope NSP.IntuneApps {
                function Get-MgContext { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com'; Scopes = @('DeviceManagementApps.Read.All', 'Group.Read.All') } }
                $context = Connect-NSPGraph -Scopes 'DeviceManagementApps.Read.All'
                $context.TenantId | Should -Be 'tenant-1'
            }
        }

        It 'throws when a required scope is missing and the context is required' {
            InModuleScope NSP.IntuneApps {
                function Get-MgContext { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com'; Scopes = @('Group.Read.All') } }
                { Connect-NSPGraph -Scopes 'DeviceManagementApps.Read.All' } | Should -Throw '*lacks required scope*'
            }
        }

        It 'returns the context without validating scopes when optional' {
            InModuleScope NSP.IntuneApps {
                function Get-MgContext { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com'; Scopes = @() } }
                $context = Connect-NSPGraph -Scopes 'DeviceManagementApps.Read.All' -Optional
                $context.TenantId | Should -Be 'tenant-1'
            }
        }
    }

    Context 'connecting with a registered app instead of the SDK default' {
        It 'passes ClientId and TenantId through to Connect-MgGraph when provided' {
            InModuleScope NSP.IntuneApps {
                Mock Connect-MgGraph { } -ModuleName NSP.IntuneApps
                function Get-MgContext { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com'; Scopes = @('DeviceManagementApps.Read.All') } }

                Connect-NSPGraph -Scopes 'DeviceManagementApps.Read.All' -Connect -ClientId 'client-1' -TenantId 'tenant-1' | Out-Null

                Should -Invoke Connect-MgGraph -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
                    $ClientId -eq 'client-1' -and $TenantId -eq 'tenant-1'
                }
            }
        }

        It 'omits ClientId and TenantId when not provided, falling back to the SDK default app' {
            InModuleScope NSP.IntuneApps {
                Mock Connect-MgGraph { } -ModuleName NSP.IntuneApps
                function Get-MgContext { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com'; Scopes = @('DeviceManagementApps.Read.All') } }

                Connect-NSPGraph -Scopes 'DeviceManagementApps.Read.All' -Connect | Out-Null

                Should -Invoke Connect-MgGraph -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
                    $null -eq $ClientId -and $null -eq $TenantId
                }
            }
        }
    }
}
