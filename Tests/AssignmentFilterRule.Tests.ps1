Describe 'Build-NSPAssignmentFilterRule' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'builds a single eq clause matching real Intune syntax' {
        InModuleScope NSP.IntuneApps {
            $rule = Build-NSPAssignmentFilterRule -Clauses @(@{ Property = 'device.deviceOwnership'; Operator = 'eq'; Value = 'Personal' })
            $rule | Should -Be '(device.deviceOwnership -eq "Personal")'
        }
    }

    It 'builds an in clause with a single value as a one-element array' {
        InModuleScope NSP.IntuneApps {
            $rule = Build-NSPAssignmentFilterRule -Clauses @(@{ Property = 'device.manufacturer'; Operator = 'in'; Value = @('Samsung') })
            $rule | Should -Be '(device.manufacturer -in ["Samsung"])'
        }
    }

    It 'builds an in clause with multiple values' {
        InModuleScope NSP.IntuneApps {
            $rule = Build-NSPAssignmentFilterRule -Clauses @(@{ Property = 'device.deviceName'; Operator = 'in'; Value = @('SIM-AH-8NR5WB4', 'SIM-AH-9NR5WB4') })
            $rule | Should -Be '(device.deviceName -in ["SIM-AH-8NR5WB4","SIM-AH-9NR5WB4"])'
        }
    }

    It 'joins multiple clauses with and' {
        InModuleScope NSP.IntuneApps {
            $rule = Build-NSPAssignmentFilterRule -Clauses @(
                @{ Property = 'device.deviceOwnership'; Operator = 'eq'; Value = 'Corporate' }
                @{ Property = 'device.enrollmentProfileName'; Operator = 'in'; Value = @('Corporate Owned - Dedicated Device WITHOUT Shared AzureAD') }
            )
            $rule | Should -Be '(device.deviceOwnership -eq "Corporate") and (device.enrollmentProfileName -in ["Corporate Owned - Dedicated Device WITHOUT Shared AzureAD"])'
        }
    }

    It 'renders the literal Null keyword unquoted' {
        InModuleScope NSP.IntuneApps {
            $rule = Build-NSPAssignmentFilterRule -Clauses @(@{ Property = 'device.enrollmentProfileName'; Operator = 'eq'; Value = 'Null' })
            $rule | Should -Be '(device.enrollmentProfileName -eq Null)'
        }
    }

    It 'throws for an unsupported operator' {
        InModuleScope NSP.IntuneApps {
            { Build-NSPAssignmentFilterRule -Clauses @(@{ Property = 'device.model'; Operator = 'like'; Value = 'x' }) } | Should -Throw '*Unsupported operator*'
        }
    }

    It 'throws when no clauses are given' {
        InModuleScope NSP.IntuneApps {
            # A Mandatory array parameter rejects @() as unsatisfying at the binder level, before
            # the function body's own "At least one clause" check ever runs - so this exercises
            # PowerShell's own parameter validation, not custom logic.
            { Build-NSPAssignmentFilterRule -Clauses @() } | Should -Throw '*Clauses*because it is an empty array*'
        }
    }
}
