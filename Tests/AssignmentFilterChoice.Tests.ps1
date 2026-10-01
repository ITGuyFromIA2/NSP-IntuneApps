Describe 'Read-NSPAssignmentFilterChoice' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
    }

    It 'never prompts or queries filters for an Exclude assignment' {
        InModuleScope NSP.IntuneApps {
            Mock Get-NSPIntuneAssignmentFilterList { throw 'should not be called' }
            Mock Read-NSPMenuChoice { throw 'should not be called' }
            $result = Read-NSPAssignmentFilterChoice -TenantId 'tenant-1' -ClientId 'client-1' -Mode 'Exclude'
            $result.FilterDisplayName | Should -BeNullOrEmpty
            $result.FilterMode | Should -BeNullOrEmpty
        }
    }

    It 'returns no filter when the tenant has none' {
        InModuleScope NSP.IntuneApps {
            Mock Get-NSPIntuneAssignmentFilterList { @() }
            Mock Read-NSPMenuChoice { throw 'should not be called' }
            (Read-NSPAssignmentFilterChoice -TenantId 'tenant-1' -ClientId 'client-1' -Mode 'Include').FilterDisplayName | Should -BeNullOrEmpty
        }
    }

    It 'returns the chosen filter and mode for an Include assignment' {
        InModuleScope NSP.IntuneApps {
            Mock Get-NSPIntuneAssignmentFilterList { @([pscustomobject]@{ DisplayName = 'Windows - Corporate Devices'; Platform = 'windows10AndLater' }) }
            Mock Read-NSPMenuChoice { '1' } -ParameterFilter { $Prompt -eq 'Filter' }
            Mock Read-NSPMenuChoice { '2' } -ParameterFilter { $Prompt -eq 'Filter mode' }
            $result = Read-NSPAssignmentFilterChoice -TenantId 'tenant-1' -ClientId 'client-1' -Mode 'Include'
            $result.FilterDisplayName | Should -Be 'Windows - Corporate Devices'
            $result.FilterMode | Should -Be 'Exclude'
            Should -Invoke Get-NSPIntuneAssignmentFilterList -Times 1 -ParameterFilter { $Platform -eq 'windows10AndLater' }
        }
    }

    It 'returns no filter when the operator picks N' {
        InModuleScope NSP.IntuneApps {
            Mock Get-NSPIntuneAssignmentFilterList { @([pscustomobject]@{ DisplayName = 'Windows - Corporate Devices'; Platform = 'windows10AndLater' }) }
            Mock Read-NSPMenuChoice { 'N' }
            $result = Read-NSPAssignmentFilterChoice -TenantId 'tenant-1' -ClientId 'client-1' -Mode 'Include'
            $result.FilterDisplayName | Should -BeNullOrEmpty
            $result.FilterMode | Should -BeNullOrEmpty
        }
    }
}
