Describe 'New-NSPInteractiveInstallerRunner' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
        $examplesRoot = Join-Path $repoRoot 'Templates\InteractiveInstaller\Examples'
    }

    It 'compiles the InstallShield multi-screen example into an AutoIt script' {
        $outputPath = Join-Path $TestDrive 'InstallShield.au3'
        $result = New-NSPInteractiveInstallerRunner -CapturePath (Join-Path $examplesRoot 'InstallShield.MultiScreen.example.json') -OutputPath $outputPath -Confirm:$false

        $result.Status | Should -Be 'Compiled'
        $result.StepCount | Should -Be 2
        Test-Path -LiteralPath $outputPath | Should -BeTrue
        $script = Get-Content -LiteralPath $outputPath -Raw

        $script | Should -Match 'UNVALIDATED against a real installer'
        $script | Should -Match 'Opt\("WinTitleMatchMode", 2\)'
        $script | Should -Match 'WinWait\("Example Setup", "Welcome", 60\)'
        # AutoItSelector is empty and AutomationId "NextButton" is not numeric, so this falls
        # back to a text selector built from Control.Name - exercising the third selector tier.
        $script | Should -Match 'ControlClick\("Example Setup", "Welcome", "\[TEXT:Next\]"\)'
        $script | Should -Match 'WinWait\("Example Setup", "Installation Complete", 600\) = 0'
    }

    It 'compiles the DocumentAssembly example, wiring RuntimeParameter values to environment reads' {
        $outputPath = Join-Path $TestDrive 'DocumentAssembly.au3'
        $result = New-NSPInteractiveInstallerRunner -CapturePath (Join-Path $examplesRoot 'DocumentAssembly.Placeholder.example.json') -OutputPath $outputPath -Confirm:$false

        $result.StepCount | Should -Be 2
        $script = Get-Content -LiteralPath $outputPath -Raw

        $script | Should -Match 'Local \$LicenseKey = EnvGet\("NSP_RUNTIMEPARAM_LicenseKey"\)'
        $script | Should -Match 'ControlSetText\("Document Assembly Setup", "License", "\[TEXT:License key\]", \$LicenseKey\)'
        $script | Should -Match 'ControlCommand\("Document Assembly Setup", "Word processor", "\[TEXT:Word processor\]", "SelectString", \$WordProcessor\)'
        # Never embed a runtime parameter's actual value/name-as-literal for a sensitive one -
        # only the $LicenseKey variable reference should appear, never a raw secret string.
        $script | Should -Not -Match 'LicenseKey.*=.*"[^"]*Key[^"]*"\s*$'
    }

    It 'uses an optional step''s timeout as a warning instead of a fatal exit' {
        $outputPath = Join-Path $TestDrive 'Optional.au3'
        New-NSPInteractiveInstallerRunner -CapturePath (Join-Path $examplesRoot 'DocumentAssembly.Placeholder.example.json') -OutputPath $outputPath -Confirm:$false | Out-Null
        $script = Get-Content -LiteralPath $outputPath -Raw

        $script | Should -Match 'Step 2: window not found within timeout \(optional, continuing\)\.'
        $script | Should -Match 'Step 1: window not found within timeout\.'
    }

    It 'prefers a non-empty AutoItSelector over any other control identification' {
        $capturePath = Join-Path $TestDrive 'selector-tier1.json'
        [ordered]@{
            SchemaVersion = '2.0'
            Installer = @{ File = 'Setup.exe'; Sha256 = '1' * 64; SignatureStatus = 'Valid' }
            CapturedAtUtc = '2026-01-01T00:00:00Z'; ExecutionEngine = 'AutoIt'; RuntimeParameters = @()
            Steps = @(
                @{ Order = 1; Window = @{ Title = 'Setup'; Text = ''; MatchMode = 'Exact' }; Control = @{ Name = 'Next'; AutomationId = '55'; ControlType = 'ControlType.Button'; AutoItSelector = '[CLASS:Button; INSTANCE:2]' }; Action = 'Click'; Value = $null; TimeoutSeconds = 30; Optional = $false; Note = 'tier1' }
            )
        } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $capturePath

        $outputPath = Join-Path $TestDrive 'tier1.au3'
        New-NSPInteractiveInstallerRunner -CapturePath $capturePath -OutputPath $outputPath -Confirm:$false | Out-Null
        $script = Get-Content -LiteralPath $outputPath -Raw

        $script | Should -Match 'ControlClick\("Setup", "", "\[CLASS:Button; INSTANCE:2\]"\)'
        $script | Should -Match 'Opt\("WinTitleMatchMode", 1\)'
    }

    It 'falls back to an ID selector when AutoItSelector is empty and AutomationId is numeric' {
        $capturePath = Join-Path $TestDrive 'selector-tier2.json'
        [ordered]@{
            SchemaVersion = '2.0'
            Installer = @{ File = 'Setup.exe'; Sha256 = '2' * 64; SignatureStatus = 'Valid' }
            CapturedAtUtc = '2026-01-01T00:00:00Z'; ExecutionEngine = 'AutoIt'; RuntimeParameters = @()
            Steps = @(
                @{ Order = 1; Window = @{ Title = 'Setup'; Text = ''; MatchMode = 'Contains' }; Control = @{ Name = ''; AutomationId = '1200'; ControlType = 'ControlType.Pane'; AutoItSelector = '' }; Action = 'Click'; Value = $null; TimeoutSeconds = 30; Optional = $false; Note = 'tier2' }
            )
        } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $capturePath

        $outputPath = Join-Path $TestDrive 'tier2.au3'
        New-NSPInteractiveInstallerRunner -CapturePath $capturePath -OutputPath $outputPath -Confirm:$false | Out-Null
        $script = Get-Content -LiteralPath $outputPath -Raw

        $script | Should -Match 'ControlClick\("Setup", "", "\[ID:1200\]"\)'
    }

    It 'omits process tracking by default' {
        $outputPath = Join-Path $TestDrive 'NoTracking.au3'
        New-NSPInteractiveInstallerRunner -CapturePath (Join-Path $examplesRoot 'InstallShield.MultiScreen.example.json') -OutputPath $outputPath -Confirm:$false | Out-Null
        $script = Get-Content -LiteralPath $outputPath -Raw

        $script | Should -Not -Match 'Run\('
        $script | Should -Not -Match 'ProcessExists'
    }

    It 'launches and tracks the installer process when -InstallerExecutablePath is given' {
        $outputPath = Join-Path $TestDrive 'Tracking.au3'
        New-NSPInteractiveInstallerRunner -CapturePath (Join-Path $examplesRoot 'InstallShield.MultiScreen.example.json') -OutputPath $outputPath -InstallerExecutablePath 'C:\Temp\ExampleSetup.exe' -Confirm:$false | Out-Null
        $script = Get-Content -LiteralPath $outputPath -Raw

        $script | Should -Match 'Local \$NSPInstallerPid = Run\("C:\\Temp\\ExampleSetup\.exe"\)'
        $script | Should -Match 'If Not ProcessExists\(\$NSPInstallerPid\) Then'
        $script | Should -Match 'Step 1: installer process is no longer running\.'
        $script | Should -Match 'Step 2: installer process is no longer running\.'
    }

    It 'throws for a capture that fails schema validation' {
        $capturePath = Join-Path $TestDrive 'invalid.json'
        '{ "SchemaVersion": "1.0" }' | Set-Content -LiteralPath $capturePath

        { New-NSPInteractiveInstallerRunner -CapturePath $capturePath -OutputPath (Join-Path $TestDrive 'invalid.au3') -Confirm:$false } |
            Should -Throw '*is not valid*'
    }

    It 'throws for an AutoHotkey-only capture' {
        $capturePath = Join-Path $TestDrive 'ahk.json'
        [ordered]@{
            SchemaVersion = '2.0'
            Installer = @{ File = 'Setup.exe'; Sha256 = '3' * 64; SignatureStatus = 'Valid' }
            CapturedAtUtc = '2026-01-01T00:00:00Z'; ExecutionEngine = 'AutoHotkey'; RuntimeParameters = @()
            Steps = @(
                @{ Order = 1; Window = @{ Title = 'Setup'; Text = ''; MatchMode = 'Contains' }; Control = @{ Name = 'Next'; AutomationId = ''; ControlType = 'ControlType.Button'; AutoItSelector = '' }; Action = 'Click'; Value = $null; TimeoutSeconds = 30; Optional = $false; Note = 'n/a' }
            )
        } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $capturePath

        { New-NSPInteractiveInstallerRunner -CapturePath $capturePath -OutputPath (Join-Path $TestDrive 'ahk.au3') -Confirm:$false } |
            Should -Throw '*only compiles AutoIt scripts*'
    }

    It 'requires -Force to overwrite an existing output file' {
        $examplesRoot = Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'Templates\InteractiveInstaller\Examples'
        $outputPath = Join-Path $TestDrive 'Dup.au3'
        New-NSPInteractiveInstallerRunner -CapturePath (Join-Path $examplesRoot 'InstallShield.MultiScreen.example.json') -OutputPath $outputPath -Confirm:$false | Out-Null

        { New-NSPInteractiveInstallerRunner -CapturePath (Join-Path $examplesRoot 'InstallShield.MultiScreen.example.json') -OutputPath $outputPath -Confirm:$false } |
            Should -Throw '*already exists*'
    }

    It 'writes nothing under -WhatIf' {
        $examplesRoot = Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'Templates\InteractiveInstaller\Examples'
        $outputPath = Join-Path $TestDrive 'WhatIf.au3'

        New-NSPInteractiveInstallerRunner -CapturePath (Join-Path $examplesRoot 'InstallShield.MultiScreen.example.json') -OutputPath $outputPath -WhatIf | Out-Null

        Test-Path -LiteralPath $outputPath | Should -BeFalse
    }
}
