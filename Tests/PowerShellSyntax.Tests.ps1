$repoRoot = Split-Path -Path $PSScriptRoot -Parent

Describe 'PowerShell source' {
    $files = @(Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Filter '*.ps1' | Where-Object FullName -notlike '*\.git\*')
    It 'contains PowerShell files' {
        @(Get-ChildItem -LiteralPath (Split-Path -Path $PSScriptRoot -Parent) -Recurse -File -Filter '*.ps1' |
            Where-Object FullName -notlike '*\.git\*').Count | Should -BeGreaterThan 0
    }

    foreach ($file in $files) {
        It "parses $($file.FullName.Substring($repoRoot.Length + 1))" {
            $tokens = $null
            $errors = $null
            [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
            @($errors).Count | Should -Be 0
        }
    }
}
