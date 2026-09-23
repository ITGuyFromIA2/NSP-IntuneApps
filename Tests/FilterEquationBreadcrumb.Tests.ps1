Describe 'Write-NSPFilterEquationBreadcrumb' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'shows only a placeholder when no clauses are completed yet' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPFilterEquationBreadcrumb -OuterClauses @() -CurrentPlaceholder 'Clause1'
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -eq '(Clause1)' -and $ForegroundColor -eq 'Yellow' }
    }

    It 'renders a completed clause before the highlighted placeholder' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPFilterEquationBreadcrumb -OuterClauses @(
                @{ Property = 'device.deviceOwnership'; Operator = 'eq'; Value = 'Corporate' }
            ) -CurrentPlaceholder 'Clause2'
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -eq '(device.deviceOwnership -eq "Corporate")' -and $ForegroundColor -eq 'Gray' }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -eq ' and ' -and $ForegroundColor -eq 'DarkGray' }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -eq '(Clause2)' -and $ForegroundColor -eq 'Yellow' }
    }

    It 'uses the outer operator between completed clauses when given or' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPFilterEquationBreadcrumb -OuterClauses @(
                @{ Property = 'device.manufacturer'; Operator = 'eq'; Value = 'Dell' }
            ) -CurrentPlaceholder 'Clause2' -OuterOperator 'or'
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -eq ' or ' -and $ForegroundColor -eq 'DarkGray' }
    }

    It 'nests an in-progress group''s own completed sub-clauses inside the highlighted placeholder' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPFilterEquationBreadcrumb -OuterClauses @(
                @{ Property = 'device.osVersion'; Operator = 'startsWith'; Value = '10.0' }
            ) -CurrentGroupClauses @(
                @{ Property = 'device.manufacturer'; Operator = 'eq'; Value = 'Dell' }
            ) -CurrentGroupOperator 'or' -CurrentPlaceholder 'SubClause2'
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter {
            $Object -eq '((device.manufacturer -eq "Dell") or (SubClause2))' -and $ForegroundColor -eq 'Yellow'
        }
    }

    It 'shows a bare group placeholder when the group has no completed sub-clauses yet' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPFilterEquationBreadcrumb -CurrentGroupClauses @() -CurrentGroupOperator 'or' -CurrentPlaceholder 'SubClause1'
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -eq '(SubClause1)' -and $ForegroundColor -eq 'Yellow' }
    }
}
