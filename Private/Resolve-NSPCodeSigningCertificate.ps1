function Resolve-NSPCodeSigningCertificate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Configuration,
        [switch]$ImportIfMissing
    )

    if ([string]::IsNullOrWhiteSpace([string]$Configuration.Current.Thumbprint)) {
        throw 'No active code-signing thumbprint is configured. Generate or activate a certificate first.'
    }

    $expectedThumbprint = ([string]$Configuration.Current.Thumbprint).Replace(' ', '').ToUpperInvariant()
    $certificate = Get-ChildItem -Path 'Cert:\LocalMachine\My' |
        Where-Object { $_.Thumbprint -eq $expectedThumbprint -and $_.HasPrivateKey } |
        Select-Object -First 1

    if (-not $certificate -and $ImportIfMissing) {
        Import-NSPBootstrap | Out-Null
        $configuredPfxPath = [string]$Configuration.Current.PfxFile
        if ([string]::IsNullOrWhiteSpace($configuredPfxPath)) {
            throw 'No operator-local PFX path is configured. Restore the encrypted PFX from Password Boss or the approved private recovery location.'
        }
        $pfxPath = if ([IO.Path]::IsPathRooted($configuredPfxPath)) {
            $configuredPfxPath
        } else {
            Join-Path $Configuration.RepoRoot $configuredPfxPath
        }
        if (-not (Test-Path -LiteralPath $pfxPath)) {
            throw "Configured PFX was not found: $pfxPath"
        }

        $secretName = [string]$Configuration.Current.PasswordSecretName
        try {
            $password = Get-NSPSecret -Name $secretName -Source Vault -ErrorAction Stop
        } catch {
            Write-Host "Password Boss remains the recovery source. NSP.Bootstrap could not resolve '$secretName' from its vault." -ForegroundColor Yellow
            $password = Read-Host -Prompt "Enter the PFX password for '$secretName'" -AsSecureString
        }

        $imported = Import-PfxCertificate -FilePath $pfxPath -Password $password -CertStoreLocation 'Cert:\LocalMachine\My' -ErrorAction Stop
        $certificate = @($imported | Where-Object { $_.Thumbprint -eq $expectedThumbprint -and $_.HasPrivateKey }) | Select-Object -First 1
    }

    if (-not $certificate) {
        throw "The exact configured certificate $expectedThumbprint with a private key is not installed in Cert:\LocalMachine\My."
    }
    if ($certificate.NotAfter -le (Get-Date)) {
        throw "The configured certificate expired on $($certificate.NotAfter)."
    }

    $certificate
}
