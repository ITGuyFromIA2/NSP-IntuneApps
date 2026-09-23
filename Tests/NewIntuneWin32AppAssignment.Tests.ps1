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

    It 'throws when GroupId is missing for TargetType Group' {
        { New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -Mode Include -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw '*GroupId is required*'
    }

    It 'throws when Exclude is requested for TargetType AllUsers' {
        { New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -TargetType AllUsers -Mode Exclude -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw '*Exclude is not supported*'
    }

    It 'throws when availableWithoutEnrollment is requested for TargetType AllDevices' {
        { New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -TargetType AllDevices -Mode Include -Intent availableWithoutEnrollment -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw "*Intent 'availableWithoutEnrollment' is not supported*"
    }

    It 'reports an All Users plan without requiring a GroupId' {
        $result = New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -AppDisplayName 'Fixture' -TargetType AllUsers -Mode Include -Intent required -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.TargetType | Should -Be 'AllUsers'
        $result.Message | Should -Match "Include-assign 'Fixture' to 'All Users'"
    }

    It 'creates an All Users assignment' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppAssignmentAllUsers { } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -TargetType AllUsers -Mode Include -Intent required -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Assigned'
        $result.TargetType | Should -Be 'AllUsers'
        Should -Invoke Add-IntuneWin32AppAssignmentAllUsers -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $ID -eq 'app-1' -and $Intent -eq 'required'
        }
    }

    It 'creates an All Devices assignment scoped by a filter' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppAssignmentAllDevices { } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -TargetType AllDevices -Mode Include -Intent required -FilterDisplayName 'Corporate Windows' -FilterMode Include -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Assigned'
        $result.TargetType | Should -Be 'AllDevices'
        Should -Invoke Add-IntuneWin32AppAssignmentAllDevices -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $FilterName -eq 'Corporate Windows' -and $FilterMode -eq 'Include'
        }
    }

    It 'passes notification/delivery/restart-grace knobs through to Add-IntuneWin32AppAssignmentGroup when set' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppAssignmentGroup { } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -GroupId 'group-1' -Mode Include -Intent required -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false `
            -Notification showReboot -DeliveryOptimizationPriority foreground -UseLocalTime $true -EnableRestartGracePeriod $true -RestartGracePeriod 1440 -RestartCountDownDisplay 15 -RestartNotificationSnooze 240

        $result.Status | Should -Be 'Assigned'
        Should -Invoke Add-IntuneWin32AppAssignmentGroup -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Notification -eq 'showReboot' -and $DeliveryOptimizationPriority -eq 'foreground' -and $UseLocalTime -eq $true -and
            $EnableRestartGracePeriod -eq $true -and $RestartGracePeriod -eq 1440 -and $RestartCountDownDisplay -eq 15 -and $RestartNotificationSnooze -eq 240
        }
    }

    It 'omits every optional knob when none are set, preserving today''s behavior' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppAssignmentGroup { } -ModuleName NSP.IntuneApps

        New-NSPIntuneWin32AppAssignment -IntuneObjectId 'app-1' -GroupId 'group-1' -Mode Include -Intent required -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false | Out-Null

        Should -Invoke Add-IntuneWin32AppAssignmentGroup -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            -not $PSBoundParameters.ContainsKey('Notification') -and -not $PSBoundParameters.ContainsKey('DeliveryOptimizationPriority') -and -not $PSBoundParameters.ContainsKey('RestartGracePeriod')
        }
    }
}
