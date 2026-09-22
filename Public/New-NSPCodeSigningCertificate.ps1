function New-NSPCodeSigningCertificate {
    <#
    .SYNOPSIS
        Creates, exports, and optionally activates a new NSP code-signing generation.
    .DESCRIPTION
        Uses NSP.Bootstrap for password generation. The encrypted PFX is written only
        to ignored operator-local storage. Its password must be saved separately in
        Password Boss. No private key or secret is written to repository source, the
        console, or a transcript.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [ValidateRange(1, 5)][int]$ValidityYears,
        [switch]$Activate
    )

    if (-not $IsWindows -and $PSVersionTable.PSVersion.Major -ge 6) {
        throw 'Certificate generation is supported only on Windows.'
    }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run PowerShell as Administrator to create a LocalMachine code-signing certificate.'
    }

    $config = Get-NSPCodeSigningConfiguration -RepoRoot $RepoRoot
    if (-not $PSBoundParameters.ContainsKey('ValidityYears')) {
        $ValidityYears = [int]$config.Policy.DefaultValidityYears
    }
    if ($ValidityYears -lt [int]$config.Policy.MinimumValidityYears -or $ValidityYears -gt [int]$config.Policy.MaximumValidityYears) {
        throw "ValidityYears must be between $($config.Policy.MinimumValidityYears) and $($config.Policy.MaximumValidityYears)."
    }
    if (-not $PSCmdlet.ShouldProcess('LocalMachine certificate stores and repository certificate artifacts', "Create a $ValidityYears-year code-signing generation")) {
        return
    }

    Import-NSPBootstrap | Out-Null
    $plainPassword = New-NSPRandomPassword -Length 32
    if ($plainPassword -isnot [string]) { $plainPassword = [string]$plainPassword.Password }
    if ([string]::IsNullOrWhiteSpace($plainPassword)) { throw 'NSP.Bootstrap did not return a password.' }
    $securePassword = ConvertTo-SecureString -String $plainPassword -AsPlainText -Force

    $notBefore = Get-Date
    $notAfter = $notBefore.AddYears($ValidityYears)
    $token = $notAfter.ToString('MM-yyyy')
    $stem = "NSPCodeSigning_${token}Expire"
    $pfxFile = "$stem.pfx"
    $cerFile = "${stem}_Public.cer"
    $omaFile = "${stem}_OMA-URI.txt"
    $pfxDirectory = Join-Path $RepoRoot 'Config\Local\CodeSigning'
    if (-not (Test-Path -LiteralPath $pfxDirectory)) {
        New-Item -ItemType Directory -Path $pfxDirectory -Force | Out-Null
    }
    $pfxPath = Join-Path $pfxDirectory $pfxFile
    $cerPath = Join-Path $config.CodeSigningDir $cerFile
    $omaPath = Join-Path $config.CodeSigningDir $omaFile
    $collisions = @(@($pfxPath, $cerPath, $omaPath) | Where-Object { Test-Path -LiteralPath $_ })
    if ($collisions) { throw "Refusing to overwrite an existing certificate generation: $($collisions -join ', ')" }
    $certificate = $null
    try {
        $certificate = New-SelfSignedCertificate `
            -Type Custom `
            -Subject ([string]$config.Policy.Subject) `
            -FriendlyName ([string]$config.Policy.FriendlyName) `
            -CertStoreLocation 'Cert:\LocalMachine\My' `
            -KeyAlgorithm RSA `
            -KeyLength 4096 `
            -HashAlgorithm SHA256 `
            -KeyUsage DigitalSignature `
            -KeyExportPolicy ExportableEncrypted `
            -NotBefore $notBefore `
            -NotAfter $notAfter `
            -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3', '2.5.29.19={critical}{text}ca=FALSE') `
            -ErrorAction Stop

        foreach ($storeName in @('Root', 'TrustedPublisher')) {
            $store = [Security.Cryptography.X509Certificates.X509Store]::new($storeName, 'LocalMachine')
            try {
                $store.Open([Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
                $store.Add($certificate)
            } finally {
                $store.Close()
            }
        }

        Export-PfxCertificate -Cert $certificate -FilePath $pfxPath -Password $securePassword -ErrorAction Stop | Out-Null
        Export-Certificate -Cert $certificate -FilePath $cerPath -ErrorAction Stop | Out-Null
        $encoded = [Convert]::ToBase64String($certificate.RawData)
        Set-Content -LiteralPath $omaPath -Value $encoded -Encoding Ascii -NoNewline

        $secretName = "NSP Code Signing - $token - $($certificate.Thumbprint.Substring($certificate.Thumbprint.Length - 8))"
        if ($Activate) {
            $config.Current.Token = $token
            $config.Current.Thumbprint = $certificate.Thumbprint
            $config.Current.PfxFile = "Config/Local/CodeSigning/$pfxFile"
            $config.Current.PublicCerFile = $cerFile
            $config.Current.OmaUriFile = $omaFile
            $config.Current.PasswordSecretName = $secretName
            $config.Current.NotBefore = $certificate.NotBefore.ToString('o')
            $config.Current.NotAfter = $certificate.NotAfter.ToString('o')
            $config.PSObject.Properties.Remove('ConfigPath')
            $config.PSObject.Properties.Remove('CodeSigningDir')
            $config.PSObject.Properties.Remove('RepoRoot')
            $config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $RepoRoot 'Z-MiscSetup\CodeSigning\CodeSigning.config.json') -Encoding UTF8
        }

        if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
            Set-Clipboard -Value $plainPassword
            Write-Warning "The PFX password is on the clipboard. Save it now in Password Boss as '$secretName', then clear the clipboard. This password will not be displayed or saved by the repository."
        } else {
            Write-Warning "Set-Clipboard is unavailable. Save the generated password in Password Boss as '$secretName' during an interactive run that supports secure handoff."
        }

        [pscustomobject]@{
            Token=$token; Thumbprint=$certificate.Thumbprint; NotAfter=$certificate.NotAfter
            PfxPath=$pfxPath; PublicCerPath=$cerPath; OmaUriPath=$omaPath
            PasswordBossEntry=$secretName; Activated=[bool]$Activate
        }
    } finally {
        $plainPassword = $null
        $securePassword = $null
    }
}
