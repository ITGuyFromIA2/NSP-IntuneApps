Describe 'Get-NSPAppAssignmentOverride / Set-NSPAppAssignmentOverride' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'reports no override when nothing has been saved for the app' {
        $root = Join-Path $TestDrive 'NoOverride'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        $result = Get-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture'

        $result.HasOverride | Should -BeFalse
        $result.AssignmentOverride.Count | Should -Be 0
    }

    It 'saves and reads back an override for one app' {
        $root = Join-Path $TestDrive 'SaveRead'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        $saveResult = Set-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture' -AssignmentOverride @(
            @{ TargetType = 'Group'; GroupId = 'override-group'; GroupDisplayName = 'Override Group'; Mode = 'Include'; Intent = 'required' }
        ) -Confirm:$false

        $saveResult.Status | Should -Be 'Saved'
        $saveResult.Count | Should -Be 1

        $result = Get-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture'
        $result.HasOverride | Should -BeTrue
        $result.AssignmentOverride.Count | Should -Be 1
        $result.AssignmentOverride[0] | Should -BeOfType ([System.Management.Automation.PSCustomObject])
        $result.AssignmentOverride[0].GroupDisplayName | Should -Be 'Override Group'
    }

    It 'treats an explicit empty override as recorded, not "no override"' {
        $root = Join-Path $TestDrive 'EmptyOverride'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        Set-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture' -AssignmentOverride @() -Confirm:$false | Out-Null

        $result = Get-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture'
        $result.HasOverride | Should -BeTrue
        $result.AssignmentOverride.Count | Should -Be 0
    }

    It 'keeps overrides for different apps independent' {
        $root = Join-Path $TestDrive 'MultiApp'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        Set-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'AppOne' -AssignmentOverride @(
            @{ TargetType = 'AllUsers'; Mode = 'Include'; Intent = 'available' }
        ) -Confirm:$false | Out-Null
        Set-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'AppTwo' -AssignmentOverride @() -Confirm:$false | Out-Null

        $one = Get-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'AppOne'
        $two = Get-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'AppTwo'
        $three = Get-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'AppThree'

        $one.AssignmentOverride[0].TargetType | Should -Be 'AllUsers'
        $two.HasOverride | Should -BeTrue
        $two.AssignmentOverride.Count | Should -Be 0
        $three.HasOverride | Should -BeFalse
    }

    It 'clears a saved override, restoring the tenant-default fallback' {
        $root = Join-Path $TestDrive 'ClearOverride'
        New-Item -ItemType Directory -Path $root -Force | Out-Null
        Set-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture' -AssignmentOverride @(
            @{ TargetType = 'AllDevices'; Mode = 'Include'; Intent = 'required' }
        ) -Confirm:$false | Out-Null

        Set-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture' -Clear -Confirm:$false | Out-Null

        $result = Get-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture'
        $result.HasOverride | Should -BeFalse
    }

    It 'ignores a saved file that belongs to a different tenant' {
        $root = Join-Path $TestDrive 'WrongTenant'
        New-Item -ItemType Directory -Path $root -Force | Out-Null
        Set-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture' -AssignmentOverride @(
            @{ TargetType = 'AllUsers'; Mode = 'Include'; Intent = 'required' }
        ) -Confirm:$false | Out-Null

        $result = Get-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-2' -AppName 'Fixture'

        $result.HasOverride | Should -BeFalse
    }

    It 'throws when a Group entry has no GroupId' {
        $root = Join-Path $TestDrive 'MissingGroupId'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        { Set-NSPAppAssignmentOverride -RepoRoot $root -TenantId 'tenant-1' -AppName 'Fixture' -AssignmentOverride @(
            @{ TargetType = 'Group'; Mode = 'Include'; Intent = 'required' }
        ) -Confirm:$false } | Should -Throw '*GroupId is required*'
    }
}
