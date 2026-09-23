Describe 'Write-NSPDenseFieldSummary' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'writes nothing for an empty row set' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps { Write-NSPDenseFieldSummary -Rows @() }
        Should -Invoke Write-Host -Times 0 -ModuleName NSP.IntuneApps
    }

    It 'renders every label and value somewhere in the output' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPDenseFieldSummary -Rows @(
                @{ Label = 'TenantId'; Value = 'tenant-1' }
                @{ Label = 'Account'; Value = 'operator@example.com' }
                @{ Label = 'AppCount'; Value = 5 }
            )
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match 'TenantId' -and $Object -match 'tenant-1' }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match 'Account' -and $Object -match 'operator@example.com' }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match 'AppCount' -and $Object -match '5' }
    }

    It 'truncates an over-long value with a trailing ..' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        Mock Get-NSPDenseColumnLayout { [pscustomobject]@{ LabelWidth = 14; ValWidth = 12; Cols = 1; Gutter = 3; ColWidth = 26; RuleWidth = 26 } } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPDenseFieldSummary -Rows @(@{ Label = 'LongValue'; Value = 'This is a very long value that exceeds the column width' })
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match '\.\.' }
    }

    It 'stops truncating a value that fits within the 40-char cap, and truncates less than before for one that does not' {
        # Regression for a real report: TenantId/Account/OutputPath packed into too many columns
        # rendered as "fb279fdc-8913-4359-b94b-fa.." and "BobLoblaw@BobLoblawLawFirm..". A 36-char
        # GUID now fits fully under the fix; a 43-char email is still capped at 40 chars (a
        # deliberate ceiling, not a regression) but shows far more than the ~28 chars it used to.
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPDenseFieldSummary -Rows @(
                @{ Label = 'TenantId'; Value = 'fb279fdc-8913-4359-b94b-facfbd174307' }
                @{ Label = 'Account'; Value = 'BobLoblaw@BobLoblawLawFirm.onmicrosoft.com' }
                @{ Label = 'AppCount'; Value = 4 }
                @{ Label = 'AssignmentCount'; Value = 0 }
                @{ Label = 'FilterCount'; Value = 0 }
                @{ Label = 'OutputPath'; Value = 'C:\GitRepo\NSP-TestIntuneApps\.nsp-intuneapps\assignment-inventory\assignments-fb279fdc-20260923-095012.json' }
            )
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match 'fb279fdc-8913-4359-b94b-facfbd174307' }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match 'BobLoblaw@BobLoblawLawFirm\.onmicrosoft' }
    }

    It 'builds rows from an InputObject''s own properties' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            $obj = [pscustomobject][ordered]@{ Alpha = 'one'; Beta = 'two' }
            Write-NSPDenseFieldSummary -InputObject $obj
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match 'Alpha' -and $Object -match 'one' }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match 'Beta' -and $Object -match 'two' }
    }
}

Describe 'Write-NSPDenseNumberedList' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'writes nothing for an empty item list' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps { Write-NSPDenseNumberedList -Items @() }
        Should -Invoke Write-Host -Times 0 -ModuleName NSP.IntuneApps
    }

    It 'renders every item with its 1-based number' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPDenseNumberedList -Items @('VCred', 'Chrome', 'Adobe')
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match '\[\s*1\]' -and $Object -match 'VCred' }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match '\[\s*2\]' -and $Object -match 'Chrome' }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match '\[\s*3\]' -and $Object -match 'Adobe' }
    }

    It 'prefixes each item with its own marker when provided' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        InModuleScope NSP.IntuneApps {
            Write-NSPDenseNumberedList -Items @('VCred', 'Chrome') -Markers @('[x]', '[ ]')
        }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match '\[x\].*VCred' }
        Should -Invoke Write-Host -ModuleName NSP.IntuneApps -ParameterFilter { $Object -match '\[ \].*Chrome' }
    }

    It 'ignores mismatched marker counts rather than throwing' {
        Mock Write-Host { } -ModuleName NSP.IntuneApps
        { InModuleScope NSP.IntuneApps { Write-NSPDenseNumberedList -Items @('VCred', 'Chrome') -Markers @('[x]') } } | Should -Not -Throw
    }
}
