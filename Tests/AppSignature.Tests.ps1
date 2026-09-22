Describe 'Set-NSPAppSignature' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force

        function New-FixtureRepo {
            param([string]$Root)
            $appRoot = Join-Path $Root 'Apps\Fixture'
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Source') -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Detect') -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\DownloadInstall_Fixture.ps1') -Value '# setup'
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\Uninstall_Fixture.ps1') -Value '# uninstall'
            Set-Content -LiteralPath (Join-Path $appRoot 'Detect\Detect_Fixture.ps1') -Value '# detect'
            $settings = @'
$VariableConfig = @{}
$VariableConfig.DisplayName = 'Fixture App'
$VariableConfig.Publisher = 'Fixture Publisher'
$VariableConfig.SetupType = 'PoSH'
$VariableConfig.DetectionStyle = 'Script'
$VariableConfig.DetectScript_Filter = 'Detect_*.ps1'
$VariableConfig.SetupFile_Filter = 'DownloadInstall_*.ps1'
$VariableConfig.PoSH = @{ Sign_SourceFilter = '*.ps1'; UninstallFile_Filter = 'Uninstall_*.ps1' }
$VariableConfig.REQ_Architecture = 'All'
$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
'@
            Set-Content -LiteralPath (Join-Path $appRoot 'Fixture_SplitScriptSettings.ps1') -Value $settings
        }

        # A real X509Certificate2 is required even for the mocked tests below: Set-AuthenticodeSignature's
        # -Certificate parameter is strongly typed, so Pester's mock proxy still enforces that type on bind.
        $fixtureCertificate = New-SelfSignedCertificate -Type Custom -Subject 'CN=NSP-IntuneApps Test Signing' `
            -CertStoreLocation 'Cert:\CurrentUser\My' -KeyAlgorithm RSA -KeyLength 2048 -HashAlgorithm SHA256 `
            -KeyUsage DigitalSignature -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3')
    }

    AfterAll {
        Remove-Item -LiteralPath "Cert:\CurrentUser\My\$($fixtureCertificate.Thumbprint)" -Force -ErrorAction SilentlyContinue
    }

    It 'signs every matched Detect and Source file and reports Valid results' {
        $repoRoot = Join-Path $TestDrive 'SignHappyPath'
        New-FixtureRepo -Root $repoRoot
        Mock Get-NSPCodeSigningCertificate { $fixtureCertificate } -ModuleName NSP.IntuneApps
        Mock Get-NSPCodeSigningConfiguration { [pscustomobject]@{ Policy = [pscustomobject]@{ TimestampServer = 'http://timestamp.example.test' } } } -ModuleName NSP.IntuneApps
        Mock Set-AuthenticodeSignature { [pscustomobject]@{ Status = 'Valid'; StatusMessage = 'Signature verified.' } } -ModuleName NSP.IntuneApps

        $result = Set-NSPAppSignature -RepoRoot $repoRoot -AppName 'Fixture' -Confirm:$false

        $result.Thumbprint | Should -Be $fixtureCertificate.Thumbprint
        $result.SignedFiles.Count | Should -Be 3
        $result.SignedFiles.Status | Should -Not -Contain 'UnknownError'
        Should -Invoke Set-AuthenticodeSignature -Times 3 -ModuleName NSP.IntuneApps
    }

    It 'throws with the offending file and status message when a signature is not Valid' {
        $repoRoot = Join-Path $TestDrive 'SignFailure'
        New-FixtureRepo -Root $repoRoot
        Mock Get-NSPCodeSigningCertificate { $fixtureCertificate } -ModuleName NSP.IntuneApps
        Mock Get-NSPCodeSigningConfiguration { [pscustomobject]@{ Policy = [pscustomobject]@{ TimestampServer = '' } } } -ModuleName NSP.IntuneApps
        Mock Set-AuthenticodeSignature { [pscustomobject]@{ Status = 'UnknownError'; StatusMessage = 'chain not trusted' } } -ModuleName NSP.IntuneApps

        { Set-NSPAppSignature -RepoRoot $repoRoot -AppName 'Fixture' -Confirm:$false } | Should -Throw '*chain not trusted*'
    }

    It 'signs nothing under -WhatIf' {
        $repoRoot = Join-Path $TestDrive 'SignWhatIf'
        New-FixtureRepo -Root $repoRoot
        Mock Get-NSPCodeSigningCertificate { $fixtureCertificate } -ModuleName NSP.IntuneApps
        Mock Get-NSPCodeSigningConfiguration { [pscustomobject]@{ Policy = [pscustomobject]@{ TimestampServer = '' } } } -ModuleName NSP.IntuneApps
        Mock Set-AuthenticodeSignature { [pscustomobject]@{ Status = 'Valid'; StatusMessage = '' } } -ModuleName NSP.IntuneApps

        $result = Set-NSPAppSignature -RepoRoot $repoRoot -AppName 'Fixture' -WhatIf
        $result.SignedFiles.Count | Should -Be 0
        Should -Invoke Set-AuthenticodeSignature -Times 0 -ModuleName NSP.IntuneApps
    }

    It 'fails a real untrusted self-signed certificate with a genuine Authenticode error' {
        $repoRoot = Join-Path $TestDrive 'SignRealCert'
        New-FixtureRepo -Root $repoRoot
        Mock Get-NSPCodeSigningCertificate { $fixtureCertificate } -ModuleName NSP.IntuneApps
        Mock Get-NSPCodeSigningConfiguration { [pscustomobject]@{ Policy = [pscustomobject]@{ TimestampServer = '' } } } -ModuleName NSP.IntuneApps

        { Set-NSPAppSignature -RepoRoot $repoRoot -AppName 'Fixture' -Confirm:$false } | Should -Throw '*Signing failed for*'
    }
}
