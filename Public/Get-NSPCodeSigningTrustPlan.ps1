function Get-NSPCodeSigningTrustPlan {
    <#
    .SYNOPSIS
        Produces a read-only plan for the combined NSP code-signing trust profile.
    .DESCRIPTION
        -ClientId/-TenantId are threaded through to Connect-NSPGraph like every other routine
        function here - omitting them (as this function used to) makes Connect-NSPGraph's own
        app-match check a no-op ("-not $ClientId" is always true when $ClientId is unset), so a
        Connect-MgGraph call from here would silently authenticate as the Microsoft Graph
        PowerShell SDK's own default app instead of the registered one. Any later action that
        correctly requests the registered app then sees a different ClientId on the existing
        context and force-reconnects - a real, previously-unaudited source of unexpected mid-
        session reconnect prompts, not the scope-list class of bug fixed elsewhere in this repo.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [ValidateSet('AllDevices','Group','None')][string]$AssignmentTarget = 'AllDevices',
        [string]$GroupId,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [switch]$Connect
    )

    $config = Get-NSPCodeSigningConfiguration -RepoRoot $RepoRoot
    if ([string]::IsNullOrWhiteSpace([string]$config.Current.Thumbprint)) { throw 'No active certificate generation is configured.' }
    $cerPath = Join-Path $config.CodeSigningDir ([string]$config.Current.PublicCerFile)
    if (-not (Test-Path -LiteralPath $cerPath)) { throw "Public certificate not found: $cerPath" }
    $certificate = [Security.Cryptography.X509Certificates.X509Certificate2]::new($cerPath)
    $thumbprint = $certificate.Thumbprint.ToUpperInvariant()
    if ($thumbprint -ne ([string]$config.Current.Thumbprint).Replace(' ', '').ToUpperInvariant()) {
        throw 'The configured thumbprint does not match the configured public certificate.'
    }
    if ($AssignmentTarget -eq 'Group' -and [string]::IsNullOrWhiteSpace($GroupId)) { throw 'GroupId is required when AssignmentTarget is Group.' }

    # Requesting the shared routine scope set (not a narrower ad-hoc list) matches every other
    # routine Connect-NSPGraph call, so this action doesn't force a second sign-in mid-session
    # when it runs alongside others that already requested the full set - see
    # Get-NSPGraphRoutineScopes for why a different scope string reprompts even mid-session.
    $requiredScopes = Get-NSPGraphRoutineScopes
    $context = Connect-NSPGraph -Scopes $requiredScopes -Connect:$Connect -ClientId $ClientId -TenantId $TenantId -Optional
    $assignmentDisplayName = if ($AssignmentTarget -eq 'AllDevices') { 'All devices' } elseif ($AssignmentTarget -eq 'None') { 'No assignment' } else { $null }
    if ($context -and $AssignmentTarget -eq 'Group') {
        try {
            $group = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/groups/${GroupId}?`$select=id,displayName" -OutputType PSObject -ErrorAction Stop
            $assignmentDisplayName = $group.displayName
        } catch {
            throw "The selected assignment group '$GroupId' could not be resolved in tenant $($context.TenantId). $($_.Exception.Message)"
        }
    }

    $rootUri = "./Device/Vendor/MSFT/RootCATrustedCertificates/Root/$thumbprint/EncodedCertificate"
    $publisherUri = "./Device/Vendor/MSFT/RootCATrustedCertificates/TrustedPublisher/$thumbprint/EncodedCertificate"
    $profileName = 'NSP Code Signing'
    $conflicts = @()
    $existing = @()
    $existingProfile = $null
    $existingSettings = @()
    if ($context) {
        $existing = @(Invoke-NSPGraphCollection -Uri 'https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?$select=id,displayName,description')
        foreach ($profile in $existing) {
            if ($profile.displayName -eq $profileName) {
                if ($existingProfile) { $conflicts += "More than one profile is named '$profileName'."; continue }
                $existingProfile = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($profile.id)" -OutputType PSObject
                $existingSettings = @($existingProfile.omaSettings)
            }
        }
        foreach ($profile in $existing) {
            $detail = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($profile.id)" -OutputType PSObject
            foreach ($setting in @($detail.omaSettings)) {
                if ($setting.omaUri -in @($rootUri, $publisherUri) -and $profile.displayName -ne $profileName) {
                    $conflicts += "Thumbprint URI already exists in '$($profile.displayName)' ($($profile.id))."
                }
            }
        }
    }

    $existingUris = @($existingSettings | ForEach-Object omaUri)
    $missingUris = @($rootUri, $publisherUri) | Where-Object { $_ -notin $existingUris }
    $action = if (-not $context) { 'ConnectToInspect' } elseif (-not $existingProfile) { 'Create' } elseif (@($missingUris).Count -gt 0) { 'AddGeneration' } else { 'NoChange' }

    [pscustomobject]@{
        IsConnected=$null -ne $context
        TenantId=if ($context) { $context.TenantId } else { $null }
        Account=if ($context) { $context.Account } else { $null }
        RequiredScopes=$requiredScopes
        ProfileName=$profileName
        Thumbprint=$thumbprint
        CertificateExpires=$certificate.NotAfter
        CertificateBase64=[Convert]::ToBase64String($certificate.RawData)
        RootOmaUri=$rootUri
        TrustedPublisherOmaUri=$publisherUri
        AssignmentTarget=$AssignmentTarget
        AssignmentDisplayName=$assignmentDisplayName
        GroupId=$GroupId
        ExistingProfile=$existingProfile
        ExistingSettings=$existingSettings
        MissingUris=@($missingUris)
        Action=$action
        Conflicts=@($conflicts | Select-Object -Unique)
        CanExecute=($null -ne $context -and @($conflicts).Count -eq 0)
    }
}
