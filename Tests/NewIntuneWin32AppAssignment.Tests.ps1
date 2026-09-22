$script:intuneWin32AppAvailable = [bool](Get-Module -ListAvailable IntuneWin32App)

Describe 'New-NSPIntuneWin32AppAssignment' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
        if ($script:intuneWin32AppAvailable) { Import-Module IntuneWin32App -Force }
    }

    It 'reports a plan without connecting to any tenant when -Execute is not passed' {
        $result = New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -AppDisplayName 'Fixture' -GroupId 'group-1' -GroupDisplayName 'Sales' -Mode Include -Intent required -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.Message | Should -Match "Include-assign 'Fixture' to 'Sales'"
    }

    It 'throws when a filter is combined with an Exclude assignment' {
        { New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -GroupId 'group-1' -Mode Exclude -FilterDisplayName 'Corporate Windows' -FilterMode Include -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw '*cannot be combined with an Exclude*'
    }

    It 'throws when a filter is given without a FilterMode' {
        { New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -GroupId 'group-1' -Mode Include -FilterDisplayName 'Corporate Windows' -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw '*FilterMode is required*'
    }

    It 'creates a plain group assignment' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppAssignmentGroup { } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -GroupId 'group-1' -Mode Include -Intent required -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Assigned'
        Should -Invoke Add-IntuneWin32AppAssignmentGroup -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $ID -eq 'app-1' -and $GroupID -eq 'group-1' -and $Include -eq $true -and $Intent -eq 'required' -and $null -eq $FilterName
        }
    }

    It 'creates a filter-scoped include assignment' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppAssignmentGroup { } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -GroupId 'group-1' -Mode Include -Intent available -FilterDisplayName 'Corporate Windows' -FilterMode Include -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Assigned'
        Should -Invoke Add-IntuneWin32AppAssignmentGroup -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $FilterName -eq 'Corporate Windows' -and $FilterMode -eq 'Include'
        }
    }

    It 'creates an exclude assignment' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppAssignmentGroup { } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -GroupId 'group-1' -Mode Exclude -Intent required -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Assigned'
        Should -Invoke Add-IntuneWin32AppAssignmentGroup -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter { $Exclude -eq $true }
    }
}
