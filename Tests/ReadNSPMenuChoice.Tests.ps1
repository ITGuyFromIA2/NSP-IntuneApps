Describe 'Read-NSPMenuChoice' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'returns the matching allowed value' {
        InModuleScope NSP.IntuneApps {
            Mock Read-Host { '2' } -ModuleName NSP.IntuneApps
            Read-NSPMenuChoice -Prompt 'Pick' -Allowed @('1', '2', '3') | Should -Be '2'
        }
    }

    It 'returns Default on blank input' {
        InModuleScope NSP.IntuneApps {
            Mock Read-Host { '' } -ModuleName NSP.IntuneApps
            Read-NSPMenuChoice -Prompt 'Pick' -Allowed @('1', '2') -Default '1' | Should -Be '1'
        }
    }

    It 'does not accept B when -AllowBack is not set' {
        InModuleScope NSP.IntuneApps {
            $script:queue = [System.Collections.Generic.Queue[string]]::new()
            @('B', '2') | ForEach-Object { $script:queue.Enqueue($_) }
            Mock Read-Host { $script:queue.Dequeue() } -ModuleName NSP.IntuneApps
            Read-NSPMenuChoice -Prompt 'Pick' -Allowed @('1', '2') | Should -Be '2'
            $script:queue.Count | Should -Be 0
        }
    }

    It 'accepts B and returns it literally when -AllowBack is set' {
        InModuleScope NSP.IntuneApps {
            Mock Read-Host { 'B' } -ModuleName NSP.IntuneApps
            Read-NSPMenuChoice -Prompt 'Pick' -Allowed @('1', '2') -AllowBack | Should -Be 'B'
        }
    }

    It 'is case-insensitive for the back answer' {
        InModuleScope NSP.IntuneApps {
            Mock Read-Host { 'b' } -ModuleName NSP.IntuneApps
            Read-NSPMenuChoice -Prompt 'Pick' -Allowed @('1', '2') -AllowBack | Should -Be 'B'
        }
    }

    It 'still works when the caller already included B in -Allowed' {
        InModuleScope NSP.IntuneApps {
            Mock Read-Host { 'B' } -ModuleName NSP.IntuneApps
            Read-NSPMenuChoice -Prompt 'Pick' -Allowed @('1', 'B') -AllowBack | Should -Be 'B'
        }
    }
}
