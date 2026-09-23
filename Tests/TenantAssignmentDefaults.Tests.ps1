Describe 'Get-NSPTenantAssignmentDefaults / Set-NSPTenantAssignmentDefaults' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'returns an empty list when no defaults file exists yet' {
        $root = Join-Path $TestDrive 'NoDefaults'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        $result = Get-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1'

        $result.DefaultAssignments.Count | Should -Be 0
    }

    It 'saves and reads back default assignments for a tenant' {
        $root = Join-Path $TestDrive 'SaveRead'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        $saveResult = Set-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1' -DefaultAssignments @(
            @{ TargetType = 'Group'; GroupId = 'device-group-1'; GroupDisplayName = 'AutoPilot Devices'; Mode = 'Include'; Intent = 'required' }
            @{ TargetType = 'AllUsers'; Mode = 'Include'; Intent = 'available' }
        ) -Confirm:$false

        $saveResult.Status | Should -Be 'Saved'
        $saveResult.Count | Should -Be 2

        $result = Get-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1'
        $result.DefaultAssignments.Count | Should -Be 2
        $result.DefaultAssignments[0] | Should -BeOfType ([System.Management.Automation.PSCustomObject])
        $result.DefaultAssignments[0].GroupDisplayName | Should -Be 'AutoPilot Devices'
        $result.DefaultAssignments[1].TargetType | Should -Be 'AllUsers'
    }

    It 'returns an empty list when the saved file belongs to a different tenant' {
        $root = Join-Path $TestDrive 'WrongTenant'
        New-Item -ItemType Directory -Path $root -Force | Out-Null
        Set-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1' -DefaultAssignments @(
            @{ TargetType = 'Group'; GroupId = 'device-group-1'; Mode = 'Include'; Intent = 'required' }
        ) -Confirm:$false | Out-Null

        $result = Get-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-2'

        $result.DefaultAssignments.Count | Should -Be 0
    }

    It 'throws when a Group entry has no GroupId' {
        $root = Join-Path $TestDrive 'MissingGroupId'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        { Set-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1' -DefaultAssignments @(
            @{ TargetType = 'Group'; Mode = 'Include'; Intent = 'required' }
        ) -Confirm:$false } | Should -Throw '*GroupId is required*'
    }

    It 'throws when Exclude is combined with a filter' {
        $root = Join-Path $TestDrive 'ExcludeFilter'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        { Set-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1' -DefaultAssignments @(
            @{ TargetType = 'Group'; GroupId = 'group-1'; Mode = 'Exclude'; FilterDisplayName = 'Corporate Windows' }
        ) -Confirm:$false } | Should -Throw '*cannot be combined with an Exclude*'
    }

    It 'throws for an unsupported TargetType' {
        $root = Join-Path $TestDrive 'BadTargetType'
        New-Item -ItemType Directory -Path $root -Force | Out-Null

        { Set-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1' -DefaultAssignments @(
            @{ TargetType = 'Everyone'; Mode = 'Include'; Intent = 'required' }
        ) -Confirm:$false } | Should -Throw '*Unsupported TargetType*'
    }

    It 'overwrites previously saved defaults for the same tenant' {
        $root = Join-Path $TestDrive 'Overwrite'
        New-Item -ItemType Directory -Path $root -Force | Out-Null
        Set-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1' -DefaultAssignments @(
            @{ TargetType = 'Group'; GroupId = 'group-1'; Mode = 'Include'; Intent = 'required' }
        ) -Confirm:$false | Out-Null

        Set-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1' -DefaultAssignments @(
            @{ TargetType = 'AllDevices'; Mode = 'Include'; Intent = 'required' }
        ) -Confirm:$false | Out-Null

        $result = Get-NSPTenantAssignmentDefaults -RepoRoot $root -TenantId 'tenant-1'
        $result.DefaultAssignments.Count | Should -Be 1
        $result.DefaultAssignments[0].TargetType | Should -Be 'AllDevices'
    }
}
