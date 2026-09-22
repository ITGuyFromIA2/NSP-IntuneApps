Describe 'Format-NSPAppList' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'joins every name when the count is at or below the default limit' {
        InModuleScope NSP.IntuneApps {
            Format-NSPAppList -Names @('VCred', 'Chrome', 'Adobe') | Should -Be 'VCred, Chrome, Adobe'
        }
    }

    It 'truncates and appends a remainder count beyond the limit' {
        InModuleScope NSP.IntuneApps {
            Format-NSPAppList -Names @('VCred', 'Chrome', 'Adobe', 'BitDefender', 'Brother') | Should -Be 'VCred, Chrome, Adobe +2 more'
        }
    }

    It 'reports no apps for an empty list' {
        InModuleScope NSP.IntuneApps {
            Format-NSPAppList -Names @() | Should -Be '(no apps)'
        }
    }

    It 'honors a custom MaxItems' {
        InModuleScope NSP.IntuneApps {
            Format-NSPAppList -Names @('VCred', 'Chrome', 'Adobe') -MaxItems 1 | Should -Be 'VCred +2 more'
        }
    }
}
