Describe 'Get-NSPIntuneAppAssignmentInventory' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force

        function New-FixtureMocks {
            Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
            Mock Invoke-NSPGraphCollection {
                if ($Uri -match 'assignmentFilters') {
                    return @([pscustomobject]@{ id = 'filter-1'; displayName = 'Corporate Windows'; platform = 'windows10AndLater'; rule = '(device.deviceOwnership -eq "Corporate")' })
                }
                if ($Uri -match 'mobileApps\?') {
                    return @(
                        [pscustomobject]@{ id = 'app-1'; displayName = 'VCred' }
                        [pscustomobject]@{ id = 'app-2'; displayName = 'Chrome' }
                    )
                }
                if ($Uri -match 'mobileApps/app-1/assignments') {
                    return @([pscustomobject]@{
                        intent = 'required'
                        target = [pscustomobject]@{ '@odata.type' = '#microsoft.graph.groupAssignmentTarget'; groupId = 'group-1'; deviceAndAppManagementAssignmentFilterId = 'filter-1'; deviceAndAppManagementAssignmentFilterType = 'include' }
                    })
                }
                if ($Uri -match 'mobileApps/app-2/assignments') {
                    return @([pscustomobject]@{
                        intent = 'available'
                        target = [pscustomobject]@{ '@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget' }
                    })
                }
                return @()
            } -ModuleName NSP.IntuneApps
            Mock Invoke-MgGraphRequest { [pscustomobject]@{ id = 'group-1'; displayName = 'All Sales Laptops' } } -ModuleName NSP.IntuneApps
        }
    }

    It 'harvests assignments, resolves group names, and pairs filters by ID' {
        New-FixtureMocks
        $repoRoot = Join-Path $TestDrive 'Harvest'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null

        $result = Get-NSPIntuneAppAssignmentInventory -RepoRoot $repoRoot -Connect

        $result.AppCount | Should -Be 2
        $result.AssignmentCount | Should -Be 2
        $result.FilterCount | Should -Be 1
        $result.DistinctGroups.GroupDisplayName | Should -Contain 'All Sales Laptops'

        # Format-Table/Format-List only resolve real PSObject properties, not hashtable keys -
        # a bare [ordered]@{} here would report FilterCount correctly but render every column
        # blank in the dashboard. Assert the actual type, not just dot-access, to catch that.
        $result.Filters[0] | Should -BeOfType ([System.Management.Automation.PSCustomObject])
        $result.Filters[0].DisplayName | Should -Be 'Corporate Windows'
        ($result.Filters[0].PSObject.Properties.Name) | Should -Contain 'DisplayName'

        $groupAssignment = $result.Assignments | Where-Object GroupId -eq 'group-1'
        $groupAssignment.AppDisplayName | Should -Be 'VCred'
        $groupAssignment.GroupDisplayName | Should -Be 'All Sales Laptops'
        $groupAssignment.FilterDisplayName | Should -Be 'Corporate Windows'
        $groupAssignment.FilterMode | Should -Be 'include'

        $allDevicesAssignment = $result.Assignments | Where-Object TargetType -match 'allDevices'
        $allDevicesAssignment.AppDisplayName | Should -Be 'Chrome'
        $allDevicesAssignment.GroupId | Should -BeNullOrEmpty

        Test-Path -LiteralPath $result.OutputPath | Should -BeTrue
        $saved = Get-Content -LiteralPath $result.OutputPath -Raw | ConvertFrom-Json
        $saved.Assignments.Count | Should -Be 2
    }

    It 'saves nothing under -WhatIf' {
        New-FixtureMocks
        $repoRoot = Join-Path $TestDrive 'WhatIf'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null

        $outputPath = Join-Path $repoRoot 'out.json'
        Get-NSPIntuneAppAssignmentInventory -RepoRoot $repoRoot -OutputPath $outputPath -Connect -WhatIf | Out-Null

        Test-Path -LiteralPath $outputPath | Should -BeFalse
    }
}
