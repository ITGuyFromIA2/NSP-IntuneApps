Describe 'New-NSPCookieCutterAssignmentFilters' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'plans every blueprint when the tenant has no existing filters' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection { @() } -ModuleName NSP.IntuneApps

        $result = New-NSPCookieCutterAssignmentFilters -TenantId 'tenant-1' -ClientId 'client-1'

        $blueprintCount = @(InModuleScope NSP.IntuneApps { Get-NSPCookieCutterFilterBlueprints }).Count
        $result.Planned | Should -Be $blueprintCount
        $result.AlreadyExists | Should -Be 0
        $result.Created | Should -Be 0
        ($result.Results | Where-Object Status -eq 'PlanOnly').Count | Should -Be $blueprintCount
    }

    It 'skips blueprints whose display name already exists in the tenant' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            @([pscustomobject]@{ id = 'filter-1'; displayName = 'Windows - Corporate Devices'; platform = 'windows10AndLater'; rule = '(device.deviceOwnership -eq "Corporate")' })
        } -ModuleName NSP.IntuneApps

        $result = New-NSPCookieCutterAssignmentFilters -TenantId 'tenant-1' -ClientId 'client-1'

        $result.AlreadyExists | Should -Be 1
        ($result.Results | Where-Object DisplayName -eq 'Windows - Corporate Devices').Status | Should -Be 'AlreadyExists'
    }

    It 'creates only the missing blueprints when -Execute is passed' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection {
            @([pscustomobject]@{ id = 'filter-1'; displayName = 'Windows - Corporate Devices'; platform = 'windows10AndLater'; rule = '(device.deviceOwnership -eq "Corporate")' })
        } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { [pscustomobject]@{ id = 'filter-new' } } -ModuleName NSP.IntuneApps

        $blueprintCount = @(InModuleScope NSP.IntuneApps { Get-NSPCookieCutterFilterBlueprints }).Count
        $result = New-NSPCookieCutterAssignmentFilters -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.AlreadyExists | Should -Be 1
        $result.Created | Should -Be ($blueprintCount - 1)
        Should -Invoke Invoke-MgGraphRequest -Times ($blueprintCount - 1) -ModuleName NSP.IntuneApps -ParameterFilter {
            $Method -eq 'POST' -and $Uri -eq 'https://graph.microsoft.com/beta/deviceManagement/assignmentFilters'
        }
    }

    It 'restricts consideration to -Include when passed, ignoring the rest of the catalog' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection { @() } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { [pscustomobject]@{ id = 'filter-new' } } -ModuleName NSP.IntuneApps

        $result = New-NSPCookieCutterAssignmentFilters -TenantId 'tenant-1' -ClientId 'client-1' -Include @('Windows - Corporate Devices', 'Windows - Personal Devices') -Execute -Confirm:$false

        $result.Created | Should -Be 2
        ($result.Results.DisplayName | Sort-Object) | Should -Be @('Windows - Corporate Devices', 'Windows - Personal Devices')
    }

    It 'creates nothing under -WhatIf' {
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection { @() } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { throw 'should not be called' } -ModuleName NSP.IntuneApps

        New-NSPCookieCutterAssignmentFilters -TenantId 'tenant-1' -ClientId 'client-1' -Execute -WhatIf | Out-Null

        Should -Invoke Invoke-MgGraphRequest -Times 0 -ModuleName NSP.IntuneApps
    }
}

Describe 'Get-NSPCookieCutterFilterBlueprints' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'contains only rules built from stable properties, never an enrollment profile name' {
        $blueprints = @(InModuleScope NSP.IntuneApps { Get-NSPCookieCutterFilterBlueprints })

        $blueprints.Count | Should -BeGreaterThan 0
        foreach ($blueprint in $blueprints) {
            $blueprint.Rule | Should -Not -Match 'enrollmentProfileName'
            $blueprint.Rule | Should -Not -Match 'deviceName'
            $blueprint.DisplayName | Should -Not -BeNullOrEmpty
            $blueprint.Platform | Should -Not -BeNullOrEmpty
            $blueprint.ManagementType | Should -BeIn @('devices', 'apps')
        }
        ($blueprints.DisplayName | Select-Object -Unique).Count | Should -Be $blueprints.Count
    }
}
