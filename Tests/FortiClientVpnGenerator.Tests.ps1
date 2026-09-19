$repoRoot = Split-Path -Path $PSScriptRoot -Parent
Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force

Describe 'FortiClient VPN configuration generator' {
    It 'creates a self-contained configuration app without modifying the upstream template' {
        $templateHashBefore = (Get-FileHash -LiteralPath (Join-Path $repoRoot 'Apps\FortiClient_ImportConfig\Source\VPNConfig_Add.reg') -Algorithm SHA256).Hash
        $result = New-NSPFortiClientVpnConfigApp -RepoRoot $repoRoot -TunnelName 'Example VPN' -Server 'https://vpn.example.invalid:8443' -Description 'Example tunnel' -EnableSso $true -UseExternalBrowser $true -OutputRoot $TestDrive

        Test-Path -LiteralPath $result.SettingsPath | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $result.Path 'Source\Install-FortiClientVpnConfig.ps1') | Should -BeTrue
        $registry = Get-Content -LiteralPath (Join-Path $result.Path 'Source\VPNConfig_Add.reg') -Raw
        $registry | Should -Match 'Tunnels\\Example VPN'
        $registry | Should -Match 'https://vpn\.example\.invalid:8443/'
        $registry | Should -Match 'sso_enabled"=dword:00000001'
        $registry | Should -Match 'use_external_browser"=dword:00000001'
        (Get-FileHash -LiteralPath (Join-Path $repoRoot 'Apps\FortiClient_ImportConfig\Source\VPNConfig_Add.reg') -Algorithm SHA256).Hash | Should -Be $templateHashBefore
    }

    It 'rejects non-HTTPS endpoints' {
        { New-NSPFortiClientVpnConfigApp -RepoRoot $repoRoot -TunnelName 'Unsafe VPN' -Server 'http://vpn.example.invalid' -OutputRoot $TestDrive } | Should -Throw '*absolute HTTPS URL*'
    }

    It 'rejects tunnel names that can break a registry key header' {
        { New-NSPFortiClientVpnConfigApp -RepoRoot $repoRoot -TunnelName 'Bad]Name' -Server 'https://vpn.example.invalid' -OutputRoot $TestDrive } | Should -Throw '*cannot contain*'
    }
}
