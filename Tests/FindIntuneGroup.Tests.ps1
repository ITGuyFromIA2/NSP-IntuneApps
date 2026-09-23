Describe 'Find-NSPIntuneGroup' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'searches groups by a display-name substring using advanced query' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            [pscustomobject]@{ value = @(
                [pscustomobject]@{ id = 'group-1'; displayName = 'Group-MDM_Dynamic_AllUsers' }
                [pscustomobject]@{ id = 'group-2'; displayName = 'Group-MDM_TestManagedReboots' }
            ) }
        } -ModuleName NSP.IntuneApps

        $result = Find-NSPIntuneGroup -NameContains 'MDM' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Count | Should -Be 2
        $result[0].DisplayName | Should -Be 'Group-MDM_Dynamic_AllUsers'
        Should -Invoke Invoke-MgGraphRequest -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Uri -match "contains\(displayName,'MDM'\)" -and $Headers.ConsistencyLevel -eq 'eventual'
        }
    }

    It 'lists all groups without a filter when NameContains is blank' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest {
            [pscustomobject]@{ value = @(
                [pscustomobject]@{ id = 'group-1'; displayName = 'Group-MDM_Dynamic_AllUsers' }
            ) }
        } -ModuleName NSP.IntuneApps

        $result = Find-NSPIntuneGroup -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Count | Should -Be 1
        Should -Invoke Invoke-MgGraphRequest -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Uri -notmatch '\$filter=' -and $Uri -match '\$orderby=displayName' -and $Headers.ConsistencyLevel -eq 'eventual'
        }
    }

    It 'escapes an embedded single quote in the search term' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { [pscustomobject]@{ value = @() } } -ModuleName NSP.IntuneApps

        Find-NSPIntuneGroup -NameContains "O'Brien" -TenantId 'tenant-1' -ClientId 'client-1' | Out-Null

        Should -Invoke Invoke-MgGraphRequest -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Uri -match "O''Brien"
        }
    }
}
