Describe 'New-NSPIntuneAssignmentFilter' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'reports a plan with the assembled rule when -Execute is not passed' {
        $result = New-NSPIntuneAssignmentFilter -DisplayName 'Corporate Windows' -Platform 'windows10AndLater' -Clauses @(@{ Property = 'device.deviceOwnership'; Operator = 'eq'; Value = 'Corporate' }) -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.Rule | Should -Be '(device.deviceOwnership -eq "Corporate")'
    }

    It 'accepts a raw rule string directly, bypassing clause assembly' {
        $result = New-NSPIntuneAssignmentFilter -DisplayName 'Hand-authored' -Platform 'windows10AndLater' -Rule '(device.manufacturer -in ["Dell","HP"])' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Rule | Should -Be '(device.manufacturer -in ["Dell","HP"])'
    }

    It 'creates the filter via a beta Graph POST' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { [pscustomobject]@{ id = 'filter-new-1' } } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneAssignmentFilter -DisplayName 'Corporate Windows' -Platform 'windows10AndLater' -Clauses @(@{ Property = 'device.deviceOwnership'; Operator = 'eq'; Value = 'Corporate' }) -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Created'
        $result.Id | Should -Be 'filter-new-1'
        Should -Invoke Invoke-MgGraphRequest -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Method -eq 'POST' -and $Uri -eq 'https://graph.microsoft.com/beta/deviceManagement/assignmentFilters' -and $Body -match 'device.deviceOwnership'
        }
    }

    It 'creates nothing under -WhatIf' {
        Mock Connect-NSPGraph { throw 'should not be called' } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneAssignmentFilter -DisplayName 'Corporate Windows' -Platform 'windows10AndLater' -Clauses @(@{ Property = 'device.deviceOwnership'; Operator = 'eq'; Value = 'Corporate' }) -TenantId 'tenant-1' -ClientId 'client-1' -Execute -WhatIf
        $result | Should -BeNullOrEmpty
    }
}
