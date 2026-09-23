Describe 'Get-NSPCodeSigningTrustPlan' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force

        # A real X509Certificate2 is required even for mocked tests - the thumbprint match check
        # loads the actual .cer file from disk and compares real Thumbprint values.
        $fixtureCertificate = New-SelfSignedCertificate -Type Custom -Subject 'CN=NSP-IntuneApps Test Trust Plan' `
            -CertStoreLocation 'Cert:\CurrentUser\My' -KeyAlgorithm RSA -KeyLength 2048 -HashAlgorithm SHA256 `
            -KeyUsage DigitalSignature -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3')

        function New-FixtureCodeSigningConfig {
            param([string]$Root)
            $codeSigningDir = Join-Path $Root 'CodeSigning'
            New-Item -ItemType Directory -Path $codeSigningDir -Force | Out-Null
            $cerPath = Join-Path $codeSigningDir 'NSP-CodeSigning.cer'
            Export-Certificate -Cert $fixtureCertificate -FilePath $cerPath -Type CERT | Out-Null
            [pscustomobject]@{
                CodeSigningDir = $codeSigningDir
                Current        = [pscustomobject]@{
                    Thumbprint    = $fixtureCertificate.Thumbprint
                    PublicCerFile = 'NSP-CodeSigning.cer'
                }
            }
        }
    }

    AfterAll {
        Remove-Item -LiteralPath "Cert:\CurrentUser\My\$($fixtureCertificate.Thumbprint)" -Force -ErrorAction SilentlyContinue
    }

    It 'passes ClientId and TenantId through to Connect-NSPGraph' {
        $root = Join-Path $TestDrive 'ClientIdPassthrough'
        Mock Get-NSPCodeSigningConfiguration { New-FixtureCodeSigningConfig -Root $root } -ModuleName NSP.IntuneApps
        Mock Connect-NSPGraph { $null } -ModuleName NSP.IntuneApps

        Get-NSPCodeSigningTrustPlan -RepoRoot $root -TenantId 'tenant-1' -ClientId 'client-1' -Connect | Out-Null

        Should -Invoke Connect-NSPGraph -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $ClientId -eq 'client-1' -and $TenantId -eq 'tenant-1'
        }
    }

    It 'reports IsConnected false and Action ConnectToInspect when no context is available' {
        $root = Join-Path $TestDrive 'NotConnected'
        Mock Get-NSPCodeSigningConfiguration { New-FixtureCodeSigningConfig -Root $root } -ModuleName NSP.IntuneApps
        Mock Connect-NSPGraph { $null } -ModuleName NSP.IntuneApps

        $plan = Get-NSPCodeSigningTrustPlan -RepoRoot $root -TenantId 'tenant-1' -ClientId 'client-1'

        $plan.IsConnected | Should -BeFalse
        $plan.Action | Should -Be 'ConnectToInspect'
        $plan.Thumbprint | Should -Be $fixtureCertificate.Thumbprint
    }

    It 'plans Create when connected and no existing profile is found' {
        $root = Join-Path $TestDrive 'PlanCreate'
        Mock Get-NSPCodeSigningConfiguration { New-FixtureCodeSigningConfig -Root $root } -ModuleName NSP.IntuneApps
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-NSPGraphCollection { @() } -ModuleName NSP.IntuneApps

        $plan = Get-NSPCodeSigningTrustPlan -RepoRoot $root -TenantId 'tenant-1' -ClientId 'client-1' -Connect

        $plan.IsConnected | Should -BeTrue
        $plan.Action | Should -Be 'Create'
        $plan.CanExecute | Should -BeTrue
    }

    It 'throws when GroupId is missing for AssignmentTarget Group' {
        $root = Join-Path $TestDrive 'MissingGroupId'
        Mock Get-NSPCodeSigningConfiguration { New-FixtureCodeSigningConfig -Root $root } -ModuleName NSP.IntuneApps

        { Get-NSPCodeSigningTrustPlan -RepoRoot $root -AssignmentTarget Group -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw '*GroupId is required*'
    }
}

Describe 'Publish-NSPCodeSigningTrust' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'passes ClientId and TenantId through to Get-NSPCodeSigningTrustPlan' {
        Mock Get-NSPCodeSigningTrustPlan {
            [pscustomobject]@{ IsConnected = $false; Action = 'ConnectToInspect'; Conflicts = @(); CanExecute = $false; TenantId = $null }
        } -ModuleName NSP.IntuneApps

        Publish-NSPCodeSigningTrust -RepoRoot 'C:\Fake' -TenantId 'tenant-1' -ClientId 'client-1' | Out-Null

        Should -Invoke Get-NSPCodeSigningTrustPlan -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $ClientId -eq 'client-1' -and $TenantId -eq 'tenant-1'
        }
    }
}
