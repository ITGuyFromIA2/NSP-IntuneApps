$repoRoot = Split-Path -Path $PSScriptRoot -Parent

Describe 'PowerShell source' {
    $files = @(Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Filter '*.ps1' | Where-Object FullName -notlike '*\.git\*')
    $cases = @($files | ForEach-Object {
        @{
            FullName = $_.FullName
            RelativePath = $_.FullName.Substring($repoRoot.Length + 1)
        }
    })

    It 'contains PowerShell files' {
        @(Get-ChildItem -LiteralPath (Split-Path -Path $PSScriptRoot -Parent) -Recurse -File -Filter '*.ps1' |
            Where-Object FullName -notlike '*\.git\*').Count | Should -BeGreaterThan 0
    }

    It 'parses <RelativePath>' -ForEach $cases {
        $tokens = $null
        $errors = $null
        [Management.Automation.Language.Parser]::ParseFile($FullName, [ref]$tokens, [ref]$errors) | Out-Null
        @($errors).Count | Should -Be 0
    }
}
