function Invoke-NSPCodeSigningSetupMenu {
    <#
    .SYNOPSIS
        Interactive dashboard flow that gets a usable code-signing certificate onto this machine.
    .DESCRIPTION
        Returns $true when the configured certificate resolves (installed, private key present,
        not expired) by the time the flow ends, and $false otherwise. When no generation is
        configured it offers New-NSPCodeSigningCertificate -Activate; when one is configured but
        not installed here it offers importing the operator-local PFX (the -ImportIfMissing
        path) or creating a replacement generation. Both write to Cert:\LocalMachine, so both
        require an elevated session - this checks up front instead of letting the underlying
        command throw mid-prompt. Shared by Code Signing > Set up and the deployment run's
        Sign-stage precheck so the two never drift.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot
    )

    $config = Get-NSPCodeSigningConfiguration -RepoRoot $RepoRoot
    $configured = -not [string]::IsNullOrWhiteSpace([string]$config.Current.Thumbprint)
    $problem = $null
    if ($configured) {
        try {
            $certificate = Resolve-NSPCodeSigningCertificate -Configuration $config
            Write-Host "Active certificate $($certificate.Thumbprint) is installed (expires $($certificate.NotAfter))." -ForegroundColor Green
            return $true
        } catch {
            $problem = $_.Exception.Message
        }
    }

    if ($configured) {
        Write-Warning $problem
        Write-Host '  [I] Import the configured certificate from its operator-local PFX'
        Write-Host '  [N] Create and activate a new certificate generation instead'
        Write-Host '  [C] Cancel'
        $choice = Read-NSPMenuChoice -Prompt 'Choice' -Allowed @('I', 'N', 'C') -Default 'C'
    } else {
        Write-Warning 'No code-signing certificate generation is configured yet.'
        Write-Host '  [N] Create and activate a new certificate generation'
        Write-Host '  [C] Cancel'
        $choice = Read-NSPMenuChoice -Prompt 'Choice' -Allowed @('N', 'C') -Default 'C'
    }
    if ($choice -eq 'C') {
        Write-Host 'No changes were made.' -ForegroundColor Yellow
        return $false
    }

    $principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning 'Installing a certificate into Cert:\LocalMachine requires an elevated session. Restart PowerShell as Administrator, reopen the dashboard, and choose Code Signing > Set up the code-signing certificate.'
        return $false
    }

    if ($choice -eq 'I') {
        $certificate = Get-NSPCodeSigningCertificate -RepoRoot $RepoRoot -ImportIfMissing
        Write-Host "Imported certificate $($certificate.Thumbprint) (expires $($certificate.NotAfter))." -ForegroundColor Green
        return $true
    }

    $policy = $config.Policy
    $yearsAllowed = @([int]$policy.MinimumValidityYears..[int]$policy.MaximumValidityYears | ForEach-Object { [string]$_ })
    $years = [int](Read-NSPMenuChoice -Prompt "Validity in years ($($policy.MinimumValidityYears)-$($policy.MaximumValidityYears))" -Allowed $yearsAllowed -Default ([string]$policy.DefaultValidityYears))
    Write-Host "This creates a $years-year self-signed certificate for '$($policy.Subject)' in Cert:\LocalMachine\My, trusts it in this machine's Root and TrustedPublisher stores, exports the encrypted PFX to Config\Local\CodeSigning, writes the public .cer/OMA-URI files to Z-MiscSetup\CodeSigning, and makes it the active generation." -ForegroundColor Yellow
    if ($configured) { Write-Host "It replaces the configured generation $($config.Current.Thumbprint) as the active one." -ForegroundColor Yellow }
    $confirm = Read-NSPMenuChoice -Prompt 'Create it now? [Y/N]' -Allowed @('Y', 'N') -Default 'N'
    if ($confirm -ne 'Y') {
        Write-Host 'No changes were made.' -ForegroundColor Yellow
        return $false
    }

    $result = New-NSPCodeSigningCertificate -RepoRoot $RepoRoot -ValidityYears $years -Activate -Confirm:$false
    $result | Select-Object Token, Thumbprint, NotAfter, PfxPath, PublicCerPath, OmaUriPath, PasswordBossEntry | Format-List
    if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
        Read-Host "Save the clipboard password in Password Boss as '$($result.PasswordBossEntry)', then press Enter to clear the clipboard" | Out-Null
        Set-Clipboard -Value ' '
    }
    Write-Host 'Next: commit the new public .cer/OMA-URI files and CodeSigning.config.json, then use Code Signing > Plan certificate trust upload so managed devices trust scripts signed with it.' -ForegroundColor Cyan
    $true
}
