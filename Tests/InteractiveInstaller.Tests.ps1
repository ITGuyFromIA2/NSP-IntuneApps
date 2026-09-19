$repoRoot = Split-Path -Path $PSScriptRoot -Parent

Describe 'Interactive installer capture contract' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
        $templateRoot = Join-Path $repoRoot 'Templates\InteractiveInstaller'
    }

    It 'ships a parseable schema-v2 JSON schema' {
        $schema = Get-Content -LiteralPath (Join-Path $repoRoot 'Schemas\InteractiveInstaller.schema.json') -Raw | ConvertFrom-Json
        $schema.title | Should -Be 'NSP interactive installer capture'
        $schema.properties.SchemaVersion.const | Should -Be '2.0'
    }

    It 'validates every sanitized example' {
        $examples = @(Get-ChildItem -LiteralPath (Join-Path $templateRoot 'Examples') -Filter '*.json' -File)
        $examples.Count | Should -BeGreaterOrEqual 2
        foreach ($example in $examples) {
            $result = Test-NSPInteractiveInstallerCapture -Path $example.FullName
            $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        }
    }

    It 'uses global capture and finish hotkeys instead of a timed focus switch' {
        $source = Get-Content -LiteralPath (Join-Path $repoRoot 'Public\Start-NSPInstallerCapture.ps1') -Raw
        $source | Should -Match 'RegisterHotKey'
        $source | Should -Match 'Ctrl\+Shift\+F12'
        $source | Should -Match 'Ctrl\+Shift\+F11'
        $source | Should -Not -Match 'Start-Sleep\s+-Seconds\s+3'
    }

    It 'represents sensitive example input as a runtime parameter without a value' {
        $path = Join-Path $templateRoot 'Examples\DocumentAssembly.Placeholder.example.json'
        $capture = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        $sensitive = @($capture.RuntimeParameters | Where-Object Sensitive)
        $sensitive.Count | Should -Be 1
        $sensitive[0].PSObject.Properties.Name | Should -Not -Contain 'Value'
        @($capture.Steps | Where-Object { $_.Value.Name -eq $sensitive[0].Name }).Count | Should -BeGreaterThan 0
    }

    It 'rejects an undeclared runtime parameter' {
        $source = Get-Content -LiteralPath (Join-Path $templateRoot 'Examples\DocumentAssembly.Placeholder.example.json') -Raw | ConvertFrom-Json
        $source.Steps[0].Value.Name = 'MissingParameter'
        $temporaryPath = Join-Path $TestDrive 'invalid-capture.json'
        $source | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $temporaryPath
        $result = Test-NSPInteractiveInstallerCapture -Path $temporaryPath
        $result.IsValid | Should -BeFalse
        $result.Errors -join ' ' | Should -Match 'undeclared runtime parameter'
    }
}
