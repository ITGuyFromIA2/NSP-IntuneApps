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
}
