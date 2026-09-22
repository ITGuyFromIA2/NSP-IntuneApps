Describe 'Register-NSPIntuneWin32AppRegistration' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force

        function New-FixtureGraphServicePrincipal {
            [pscustomobject]@{
                Id = 'graph-sp-id'
                Oauth2PermissionScopes = @(
                    [pscustomobject]@{ Value = 'DeviceManagementApps.ReadWrite.All'; Id = 'scope-1' }
                    [pscustomobject]@{ Value = 'DeviceManagementConfiguration.ReadWrite.All'; Id = 'scope-2' }
                    [pscustomobject]@{ Value = 'DeviceManagementRBAC.Read.All'; Id = 'scope-3' }
                    [pscustomobject]@{ Value = 'Group.Read.All'; Id = 'scope-4' }
                    [pscustomobject]@{ Value = 'DeviceManagementServiceConfig.ReadWrite.All'; Id = 'scope-5' }
                )
            }
        }
    }

    It 'reports a plan without creating anything when -Execute is not passed' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgServicePrincipal { New-FixtureGraphServicePrincipal } -ModuleName NSP.IntuneApps
        Mock New-MgApplication { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'plan-only'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null
        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.RequiredScopes | Should -Contain 'DeviceManagementApps.ReadWrite.All'
        Test-Path -LiteralPath (Join-Path $repoRoot 'Config\Local\GraphAppRegistration.json') | Should -BeFalse
        Should -Invoke New-MgApplication -Times 0 -ModuleName NSP.IntuneApps
    }

    It 'derives the tenant from the connected Graph context when -TenantId is omitted' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgServicePrincipal { New-FixtureGraphServicePrincipal } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'no-tenant-arg'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null
        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot

        $result.Status | Should -Be 'PlanOnly'
        $result.TenantId | Should -Be 'tenant-1'
    }

    It 'throws when the connected tenant does not match the requested tenant' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-2'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'tenant-mismatch'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null
        { Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1' } | Should -Throw '*does not match*'
    }

    It 'reports an existing registration instead of creating a duplicate' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgApplication {
            [pscustomobject]@{ Id = 'existing-object-id'; AppId = 'existing-app-id'; PublicClient = [pscustomobject]@{ RedirectUris = @('http://localhost', 'ms-appx-web://Microsoft.AAD.BrokerPlugin/existing-app-id') } }
        } -ModuleName NSP.IntuneApps
        Mock Get-MgServicePrincipal { New-FixtureGraphServicePrincipal } -ModuleName NSP.IntuneApps
        Mock Get-MgOauth2PermissionGrant {
            [pscustomobject]@{ Id = 'grant-id'; Scope = 'DeviceManagementApps.ReadWrite.All DeviceManagementConfiguration.ReadWrite.All DeviceManagementRBAC.Read.All Group.Read.All DeviceManagementServiceConfig.ReadWrite.All' }
        } -ModuleName NSP.IntuneApps
        Mock New-MgApplication { throw 'should not be called' } -ModuleName NSP.IntuneApps
        Mock Update-MgApplication { throw 'should not be called' } -ModuleName NSP.IntuneApps
        Mock Update-MgOauth2PermissionGrant { throw 'should not be called' } -ModuleName NSP.IntuneApps
        Mock New-MgOauth2PermissionGrant { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'already-registered'
        $configDir = Join-Path $repoRoot 'Config\Local'
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        [ordered]@{
            TenantId = 'tenant-1'; ClientId = 'existing-app-id'; AppName = 'NSP-IntuneApps-Win32AppDeployment'
            CreatedAtUtc = (Get-Date).ToString('o'); GrantedScopes = @('DeviceManagementApps.ReadWrite.All')
        } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $configDir 'GraphAppRegistration.json') -Encoding UTF8

        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1' -Execute -Confirm:$false
        $result.Status | Should -Be 'AlreadyRegistered'
        $result.ClientId | Should -Be 'existing-app-id'
        Should -Invoke New-MgApplication -Times 0 -ModuleName NSP.IntuneApps
        Should -Invoke Update-MgApplication -Times 0 -ModuleName NSP.IntuneApps
    }

    It 'reports that the broker redirect URI needs repair without -Execute' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgApplication {
            [pscustomobject]@{ Id = 'existing-object-id'; AppId = 'existing-app-id'; PublicClient = [pscustomobject]@{ RedirectUris = @('http://localhost') } }
        } -ModuleName NSP.IntuneApps
        Mock Update-MgApplication { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'needs-repair-planonly'
        $configDir = Join-Path $repoRoot 'Config\Local'
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        [ordered]@{
            TenantId = 'tenant-1'; ClientId = 'existing-app-id'; AppName = 'NSP-IntuneApps-Win32AppDeployment'
            CreatedAtUtc = (Get-Date).ToString('o'); GrantedScopes = @('DeviceManagementApps.ReadWrite.All')
        } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $configDir 'GraphAppRegistration.json') -Encoding UTF8

        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1'
        $result.Status | Should -Be 'NeedsRedirectUriRepair'
        $result.Message | Should -Match 'AADSTS50011'
        Should -Invoke Update-MgApplication -Times 0 -ModuleName NSP.IntuneApps
    }

    It 'repairs a missing broker redirect URI when -Execute is passed' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgApplication {
            [pscustomobject]@{ Id = 'existing-object-id'; AppId = 'existing-app-id'; PublicClient = [pscustomobject]@{ RedirectUris = @('http://localhost') } }
        } -ModuleName NSP.IntuneApps
        Mock Update-MgApplication { } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'needs-repair-execute'
        $configDir = Join-Path $repoRoot 'Config\Local'
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        [ordered]@{
            TenantId = 'tenant-1'; ClientId = 'existing-app-id'; AppName = 'NSP-IntuneApps-Win32AppDeployment'
            CreatedAtUtc = (Get-Date).ToString('o'); GrantedScopes = @('DeviceManagementApps.ReadWrite.All')
        } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $configDir 'GraphAppRegistration.json') -Encoding UTF8

        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1' -Execute -Confirm:$false
        $result.Status | Should -Be 'RedirectUriRepaired'
        Should -Invoke Update-MgApplication -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $ApplicationId -eq 'existing-object-id' -and $PublicClient.RedirectUris -contains 'ms-appx-web://Microsoft.AAD.BrokerPlugin/existing-app-id' -and $PublicClient.RedirectUris -contains 'http://localhost'
        }
    }

    It 'reports that admin consent needs repair without -Execute' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgApplication {
            [pscustomobject]@{ Id = 'existing-object-id'; AppId = 'existing-app-id'; PublicClient = [pscustomobject]@{ RedirectUris = @('http://localhost', 'ms-appx-web://Microsoft.AAD.BrokerPlugin/existing-app-id') } }
        } -ModuleName NSP.IntuneApps
        Mock Get-MgServicePrincipal { New-FixtureGraphServicePrincipal } -ModuleName NSP.IntuneApps
        Mock Get-MgOauth2PermissionGrant {
            [pscustomobject]@{ Id = 'grant-id'; Scope = 'DeviceManagementApps.ReadWrite.All DeviceManagementConfiguration.ReadWrite.All DeviceManagementRBAC.Read.All Group.Read.All' }
        } -ModuleName NSP.IntuneApps
        Mock Update-MgOauth2PermissionGrant { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'needs-permission-repair-planonly'
        $configDir = Join-Path $repoRoot 'Config\Local'
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        [ordered]@{
            TenantId = 'tenant-1'; ClientId = 'existing-app-id'; AppName = 'NSP-IntuneApps-Win32AppDeployment'
            CreatedAtUtc = (Get-Date).ToString('o'); GrantedScopes = @('DeviceManagementApps.ReadWrite.All')
        } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $configDir 'GraphAppRegistration.json') -Encoding UTF8

        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1'
        $result.Status | Should -Be 'NeedsPermissionRepair'
        $result.Message | Should -Match 'DeviceManagementServiceConfig.ReadWrite.All'
        Should -Invoke Update-MgOauth2PermissionGrant -Times 0 -ModuleName NSP.IntuneApps
    }

    It 'grants missing admin consent when -Execute is passed' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgApplication {
            [pscustomobject]@{ Id = 'existing-object-id'; AppId = 'existing-app-id'; PublicClient = [pscustomobject]@{ RedirectUris = @('http://localhost', 'ms-appx-web://Microsoft.AAD.BrokerPlugin/existing-app-id') } }
        } -ModuleName NSP.IntuneApps
        Mock Get-MgServicePrincipal { New-FixtureGraphServicePrincipal } -ModuleName NSP.IntuneApps
        Mock Get-MgOauth2PermissionGrant {
            [pscustomobject]@{ Id = 'grant-id'; Scope = 'DeviceManagementApps.ReadWrite.All DeviceManagementConfiguration.ReadWrite.All DeviceManagementRBAC.Read.All Group.Read.All' }
        } -ModuleName NSP.IntuneApps
        Mock Update-MgOauth2PermissionGrant { } -ModuleName NSP.IntuneApps
        Mock New-MgOauth2PermissionGrant { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'needs-permission-repair-execute'
        $configDir = Join-Path $repoRoot 'Config\Local'
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        [ordered]@{
            TenantId = 'tenant-1'; ClientId = 'existing-app-id'; AppName = 'NSP-IntuneApps-Win32AppDeployment'
            CreatedAtUtc = (Get-Date).ToString('o'); GrantedScopes = @('DeviceManagementApps.ReadWrite.All')
        } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $configDir 'GraphAppRegistration.json') -Encoding UTF8

        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1' -Execute -Confirm:$false
        $result.Status | Should -Be 'PermissionsRepaired'
        Should -Invoke Update-MgOauth2PermissionGrant -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $OAuth2PermissionGrantId -eq 'grant-id' -and $BodyParameter.Scope -match 'DeviceManagementServiceConfig.ReadWrite.All'
        }
    }

    It 'creates the application, service principal, and consent grant, then records the registration' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgServicePrincipal { New-FixtureGraphServicePrincipal } -ModuleName NSP.IntuneApps
        Mock New-MgApplication { [pscustomobject]@{ Id = 'object-id-1'; AppId = 'new-app-id' } } -ModuleName NSP.IntuneApps
        Mock Update-MgApplication { } -ModuleName NSP.IntuneApps
        Mock New-MgServicePrincipal { [pscustomobject]@{ Id = 'new-sp-id' } } -ModuleName NSP.IntuneApps
        Mock New-MgOauth2PermissionGrant { [pscustomobject]@{ Id = 'grant-id' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            [pscustomobject]@{ value = @([pscustomobject]@{ verifiedDomains = @(
                [pscustomobject]@{ name = 'contoso.onmicrosoft.com'; isDefault = $false }
                [pscustomobject]@{ name = 'contoso.com'; isDefault = $true }
            ) }) }
        } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'create-new'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null
        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Created'
        $result.ClientId | Should -Be 'new-app-id'
        $result.TenantDomain | Should -Be 'contoso.com'
        $recordPath = Join-Path $repoRoot 'Config\Local\GraphAppRegistration.json'
        Test-Path -LiteralPath $recordPath | Should -BeTrue
        $record = Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json
        $record.ClientId | Should -Be 'new-app-id'
        $record.TenantId | Should -Be 'tenant-1'
        $record.TenantDomain | Should -Be 'contoso.com'
        $record.GrantedScopes | Should -Contain 'Group.Read.All'
        Should -Invoke New-MgOauth2PermissionGrant -Times 1 -ModuleName NSP.IntuneApps
        Should -Invoke Update-MgApplication -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $ApplicationId -eq 'object-id-1' -and $PublicClient.RedirectUris -contains 'ms-appx-web://Microsoft.AAD.BrokerPlugin/new-app-id'
        }
    }

    It 'leaves TenantDomain empty rather than failing when the organization lookup errors' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgServicePrincipal { New-FixtureGraphServicePrincipal } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { throw 'not authorized' } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'domain-lookup-fails'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null
        $result = Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.TenantDomain | Should -BeNullOrEmpty
    }

    It 'fails clearly when a required Graph permission cannot be resolved' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Get-MgServicePrincipal { [pscustomobject]@{ Id = 'graph-sp-id'; Oauth2PermissionScopes = @() } } -ModuleName NSP.IntuneApps

        $repoRoot = Join-Path $TestDrive 'missing-scope'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null
        { Register-NSPIntuneWin32AppRegistration -RepoRoot $repoRoot -TenantId 'tenant-1' } | Should -Throw '*was not found on the Microsoft Graph service principal*'
    }
}
