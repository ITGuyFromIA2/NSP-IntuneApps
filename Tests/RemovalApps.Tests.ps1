$repoRoot = Split-Path -Path $PSScriptRoot -Parent

Describe 'Preinstalled app removal packages' {
    It '<Name> is an honest removal package without copied Chrome behavior' -ForEach @(
        @{ Name='Remove-LGEasyGuide' }
        @{ Name='Remove-LGMyGram' }
        @{ Name='Remove-DellOptimizer' }
    ) {
            $root = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "Apps\$Name"
            $sourceText = (Get-ChildItem -LiteralPath $root -Recurse -File |
                Where-Object Extension -in @('.ps1','.json') |
                ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
            $sourceText | Should -Not -Match 'Chrome|GoogleChrome|dl\.google\.com'
            $sourceText | Should -Match 'DisplayNamePatterns'
            $sourceText | Should -Match 'AssignmentColl = @\(\)'
    }
}
