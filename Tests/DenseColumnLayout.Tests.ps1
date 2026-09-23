Describe 'Get-NSPDenseColumnLayout' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'falls back to a single wide column on a narrow (~80-col) console' {
        InModuleScope NSP.IntuneApps {
            $layout = Get-NSPDenseColumnLayout -ConsoleWidth 80 -MaxLabelLen 20
            $layout.Cols | Should -Be 1
        }
    }

    It 'prefers more columns on a wide console' {
        InModuleScope NSP.IntuneApps {
            $layout = Get-NSPDenseColumnLayout -ConsoleWidth 200 -MaxLabelLen 14
            $layout.Cols | Should -BeGreaterThan 1
            $layout.Cols | Should -BeLessOrEqual 4
        }
    }

    It 'never lets the value width drop below 12' {
        InModuleScope NSP.IntuneApps {
            1..6 | ForEach-Object {
                $layout = Get-NSPDenseColumnLayout -ConsoleWidth (60 + $_ * 20) -MaxLabelLen 25
                $layout.ValWidth | Should -BeGreaterOrEqual 12
            }
        }
    }

    It 'clamps the label width between 14 and 30 regardless of the requested length' {
        InModuleScope NSP.IntuneApps {
            (Get-NSPDenseColumnLayout -ConsoleWidth 120 -MaxLabelLen 3).LabelWidth | Should -Be 14
            (Get-NSPDenseColumnLayout -ConsoleWidth 120 -MaxLabelLen 100).LabelWidth | Should -Be 30
        }
    }

    It 'never returns a rule width wider than the console' {
        InModuleScope NSP.IntuneApps {
            $layout = Get-NSPDenseColumnLayout -ConsoleWidth 90 -MaxLabelLen 30
            $layout.RuleWidth | Should -BeLessOrEqual (90 - 3)
        }
    }

    It 'settles on fewer columns when the actual values are long (GUIDs/emails), not just the labels' {
        InModuleScope NSP.IntuneApps {
            # Short labels (TenantId, Account) but 36+ char GUID/email values: on a wide console
            # that could otherwise fit 3-4 short-labeled columns, long values should still pull
            # the layout down to fewer, wider columns instead of truncating every one of them.
            $wide = Get-NSPDenseColumnLayout -ConsoleWidth 200 -MaxLabelLen 10 -MaxValueLen 8
            $narrow = Get-NSPDenseColumnLayout -ConsoleWidth 200 -MaxLabelLen 10 -MaxValueLen 36

            $narrow.Cols | Should -BeLessThan $wide.Cols
            $narrow.ValWidth | Should -BeGreaterThan $wide.ValWidth
        }
    }

    It 'defaults MaxValueLen to a short value when not specified, preserving prior label-only behavior' {
        InModuleScope NSP.IntuneApps {
            $withDefault = Get-NSPDenseColumnLayout -ConsoleWidth 120 -MaxLabelLen 14
            $withExplicitShort = Get-NSPDenseColumnLayout -ConsoleWidth 120 -MaxLabelLen 14 -MaxValueLen 18
            $withDefault.Cols | Should -Be $withExplicitShort.Cols
            $withDefault.ValWidth | Should -Be $withExplicitShort.ValWidth
        }
    }

    It 'caps the value-driven minimum at 40, same as the existing value-width ceiling' {
        InModuleScope NSP.IntuneApps {
            $layout = Get-NSPDenseColumnLayout -ConsoleWidth 300 -MaxLabelLen 10 -MaxValueLen 500
            $layout.ValWidth | Should -BeLessOrEqual 40
        }
    }
}
