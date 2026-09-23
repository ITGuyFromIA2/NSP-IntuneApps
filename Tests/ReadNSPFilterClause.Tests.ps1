Describe 'Read-NSPFilterClause' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'collects Property/Operator/Value straight through when no back is requested' {
        InModuleScope NSP.IntuneApps {
            $script:queue = [System.Collections.Generic.Queue[string]]::new()
            @('2', '1', 'Dell') | ForEach-Object { $script:queue.Enqueue($_) }
            Mock Read-Host { $script:queue.Dequeue() } -ModuleName NSP.IntuneApps

            $result = Read-NSPFilterClause -TenantId 'tenant-1' -ClientId 'client-1' -Platform 'windows10AndLater'

            $result.Property | Should -Be 'device.manufacturer'
            $result.Operator | Should -Be 'eq'
            $result.Value | Should -Be 'Dell'
            $script:queue.Count | Should -Be 0
        }
    }

    It 'steps back from Operator to Property, discarding the earlier Property pick' {
        InModuleScope NSP.IntuneApps {
            # Property=2 (manufacturer) -> Operator=B (back) -> Property=3 (model) -> Operator=5 (contains, a list operator) -> Value
            $script:queue = [System.Collections.Generic.Queue[string]]::new()
            @('2', 'B', '3', '5', 'Latitude,XPS') | ForEach-Object { $script:queue.Enqueue($_) }
            Mock Read-Host { $script:queue.Dequeue() } -ModuleName NSP.IntuneApps

            $result = Read-NSPFilterClause -TenantId 'tenant-1' -ClientId 'client-1' -Platform 'windows10AndLater'

            $result.Property | Should -Be 'device.model'
            $result.Operator | Should -Be 'contains'
            $result.Value | Should -Be @('Latitude', 'XPS')
            $script:queue.Count | Should -Be 0
        }
    }

    It 'steps back from Value to Operator, discarding the earlier Operator pick' {
        InModuleScope NSP.IntuneApps {
            # Property=2 (manufacturer) -> Operator=1 (eq) -> Value=B (back) -> Operator=2 (ne) -> Value
            $script:queue = [System.Collections.Generic.Queue[string]]::new()
            @('2', '1', 'B', '2', 'HP') | ForEach-Object { $script:queue.Enqueue($_) }
            Mock Read-Host { $script:queue.Dequeue() } -ModuleName NSP.IntuneApps

            $result = Read-NSPFilterClause -TenantId 'tenant-1' -ClientId 'client-1' -Platform 'windows10AndLater'

            $result.Property | Should -Be 'device.manufacturer'
            $result.Operator | Should -Be 'ne'
            $result.Value | Should -Be 'HP'
            $script:queue.Count | Should -Be 0
        }
    }

    It 'a literal Back typed at the Value prompt also steps back (not just the bare letter B)' {
        InModuleScope NSP.IntuneApps {
            $script:queue = [System.Collections.Generic.Queue[string]]::new()
            @('2', '1', 'Back', '3', 'ThinkPad') | ForEach-Object { $script:queue.Enqueue($_) }
            Mock Read-Host { $script:queue.Dequeue() } -ModuleName NSP.IntuneApps

            $result = Read-NSPFilterClause -TenantId 'tenant-1' -ClientId 'client-1' -Platform 'windows10AndLater'

            $result.Operator | Should -Be 'in'
            $result.Value | Should -Be 'ThinkPad'
        }
    }
}
