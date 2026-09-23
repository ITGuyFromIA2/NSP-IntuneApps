function Register-NSPIntuneWin32AppRegistration {
    <#
    .SYNOPSIS
        One-time tenant bootstrap: registers the Azure AD application IntuneWin32App
        authenticates as, and grants it admin consent.
    .DESCRIPTION
        Plan-only is the default. Use -Execute and approve ShouldProcess to actually
        create the application, service principal, and admin consent grant. If a
        registration is already recorded and still exists in the tenant, no duplicate
        is created. -TenantId is optional: the interactive login already resolves the
        tenant, so it is read from the connected Graph context. Pass -TenantId only as
        a safety check to fail fast if you land in the wrong tenant.

        Also asserts the Windows broker (WAM) redirect URI is registered, repairing an
        existing registration with -Execute if it's missing. Without it, delegated sign-in
        as this app fails with AADSTS50011 as soon as anything (Connect-NSPGraph) connects
        using this app's ClientId instead of a Microsoft-owned default app.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [string]$TenantId,
        [switch]$Execute
    )

    $graphAppId = '00000003-0000-0000-c000-000000000000'
    $appName = 'NSP-IntuneApps-Win32AppDeployment'
    # Grants exactly what Get-NSPGraphRoutineScopes requests - a literal duplicate list here would
    # silently drift out of sync with it, and admin consent that's missing even one scope Connect-
    # NSPGraph later requests forces a fresh interactive reconnect (the exact "random prompts"
    # failure mode this repo has already chased down once).
    $requiredPermissionNames = @(Get-NSPGraphRoutineScopes)
    $recordPath = Join-Path $RepoRoot 'Config\Local\GraphAppRegistration.json'

    $connectScopes = @('Application.ReadWrite.All', 'Directory.ReadWrite.All', 'DelegatedPermissionGrant.ReadWrite.All')
    $context = Connect-NSPGraph -Scopes $connectScopes -Connect
    if ($TenantId -and $context.TenantId -ne $TenantId) {
        throw "Connected to tenant $($context.TenantId), which does not match the requested TenantId $TenantId. Reconnect against the correct tenant."
    }
    $TenantId = $context.TenantId

    # A GUID alone isn't identifiable at a glance; resolve the tenant's default verified
    # domain (e.g. contoso.onmicrosoft.com or a custom domain) via a plain Graph call so it
    # can travel alongside the TenantId in the console output and the saved record. Best
    # effort - a lookup failure here shouldn't block registration itself.
    $tenantDomain = try {
        $organization = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/organization?$select=verifiedDomains' -ErrorAction Stop
        $defaultDomain = @($organization.value[0].verifiedDomains) | Where-Object { $_.isDefault } | Select-Object -First 1
        if ($defaultDomain) { $defaultDomain.name } else { $null }
    } catch { $null }

    if (Test-Path -LiteralPath $recordPath) {
        $record = Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json
        $existingApp = @(Get-MgApplication -Filter "appId eq '$($record.ClientId)'")
        if (@($existingApp).Count -gt 0) {
            # Windows tries native broker sign-in (WAM) when Connect-MgGraph authenticates as
            # a specific app, which needs this exact redirect URI registered or sign-in fails
            # with AADSTS50011. Microsoft's own default apps already have it; ours needs it
            # added explicitly. Always assert the full desired set rather than trusting
            # whatever the filtered read happened to return, so a partial/empty read can never
            # silently drop 'http://localhost' (IntuneWin32App's own redirect URI) on repair.
            $brokerRedirectUri = "ms-appx-web://Microsoft.AAD.BrokerPlugin/$($record.ClientId)"
            $desiredRedirectUris = @('http://localhost', $brokerRedirectUri)
            $currentRedirectUris = @($existingApp[0].PublicClient.RedirectUris)
            $missingRedirectUris = @($desiredRedirectUris | Where-Object { $_ -notin $currentRedirectUris })

            if (@($missingRedirectUris).Count -gt 0) {
                if (-not $Execute) {
                    return [pscustomobject]@{
                        Status       = 'NeedsRedirectUriRepair'
                        TenantId     = [string]$record.TenantId
                        TenantDomain = $tenantDomain
                        ClientId     = [string]$record.ClientId
                        AppName      = [string]$record.AppName
                        RecordPath   = $recordPath
                        Message      = "This registration is missing the Windows broker redirect URI and will fail sign-in with AADSTS50011. Run again with -Execute to repair it."
                    }
                }
                if (-not $PSCmdlet.ShouldProcess("tenant $($context.TenantId)", "Add the Windows broker redirect URI to app registration '$($record.AppName)'")) { return }
                Update-MgApplication -ApplicationId $existingApp[0].Id -PublicClient @{ RedirectUris = @($currentRedirectUris + $missingRedirectUris | Select-Object -Unique) } -ErrorAction Stop
                return [pscustomobject]@{
                    Status       = 'RedirectUriRepaired'
                    TenantId     = [string]$record.TenantId
                    TenantDomain = $tenantDomain
                    ClientId     = [string]$record.ClientId
                    AppName      = [string]$record.AppName
                    RecordPath   = $recordPath
                    Message      = 'Added the Windows broker redirect URI. Sign-in should now succeed.'
                }
            }

            # Permission requirements grow over time (e.g. adding enrollment-profile lookups
            # needed DeviceManagementServiceConfig.ReadWrite.All after this app was already
            # registered). Compare the existing admin-consent grant's scope string against the
            # current required list and top it up rather than requiring a full re-registration.
            $graphServicePrincipalForRepair = Get-MgServicePrincipal -Filter "appId eq '$graphAppId'" | Select-Object -First 1
            $existingGrant = if ($graphServicePrincipalForRepair) {
                Get-MgOauth2PermissionGrant -Filter "clientId eq '$($existingApp[0].Id)' and resourceId eq '$($graphServicePrincipalForRepair.Id)' and consentType eq 'AllPrincipals'" -ErrorAction SilentlyContinue | Select-Object -First 1
            } else { $null }
            $grantedScopeNames = if ($existingGrant) { @([string]$existingGrant.Scope -split '\s+' | Where-Object { $_ }) } else { @() }
            $missingPermissionNames = @($requiredPermissionNames | Where-Object { $_ -notin $grantedScopeNames })

            if (@($missingPermissionNames).Count -gt 0) {
                if (-not $Execute) {
                    return [pscustomobject]@{
                        Status       = 'NeedsPermissionRepair'
                        TenantId     = [string]$record.TenantId
                        TenantDomain = $tenantDomain
                        ClientId     = [string]$record.ClientId
                        AppName      = [string]$record.AppName
                        RecordPath   = $recordPath
                        Message      = "This registration is missing admin consent for: $($missingPermissionNames -join ', '). Run again with -Execute to grant it."
                    }
                }
                if (-not $PSCmdlet.ShouldProcess("tenant $($context.TenantId)", "Grant admin consent for $($missingPermissionNames -join ', ') on app registration '$($record.AppName)'")) { return }
                $mergedScope = (@($grantedScopeNames) + $missingPermissionNames | Select-Object -Unique) -join ' '
                if ($existingGrant) {
                    Update-MgOauth2PermissionGrant -OAuth2PermissionGrantId $existingGrant.Id -BodyParameter @{ Scope = $mergedScope } -ErrorAction Stop | Out-Null
                } else {
                    New-MgOauth2PermissionGrant -BodyParameter @{
                        ClientId    = $existingApp[0].Id
                        ConsentType = 'AllPrincipals'
                        ResourceId  = $graphServicePrincipalForRepair.Id
                        Scope       = $mergedScope
                    } -ErrorAction Stop | Out-Null
                }
                return [pscustomobject]@{
                    Status       = 'PermissionsRepaired'
                    TenantId     = [string]$record.TenantId
                    TenantDomain = $tenantDomain
                    ClientId     = [string]$record.ClientId
                    AppName      = [string]$record.AppName
                    RecordPath   = $recordPath
                    Message      = "Granted admin consent for: $($missingPermissionNames -join ', ')."
                }
            }

            return [pscustomobject]@{
                Status       = 'AlreadyRegistered'
                TenantId     = [string]$record.TenantId
                TenantDomain = $tenantDomain
                ClientId     = [string]$record.ClientId
                AppName      = [string]$record.AppName
                RecordPath   = $recordPath
            }
        }
        Write-Warning "The recorded registration $($record.ClientId) at $recordPath no longer exists in tenant $($context.TenantId). A new registration is required."
    }

    $graphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$graphAppId'" | Select-Object -First 1
    if (-not $graphServicePrincipal) { throw 'The Microsoft Graph service principal could not be resolved in this tenant.' }
    $availableScopes = @($graphServicePrincipal.Oauth2PermissionScopes)
    $resolvedScopes = foreach ($name in $requiredPermissionNames) {
        $scope = $availableScopes | Where-Object { $_.Value -eq $name } | Select-Object -First 1
        if (-not $scope) { throw "Permission '$name' was not found on the Microsoft Graph service principal in this tenant." }
        [pscustomobject]@{ Name = $name; Id = $scope.Id }
    }

    if (-not $Execute) {
        return [pscustomobject]@{
            Status         = 'PlanOnly'
            TenantId       = $context.TenantId
            TenantDomain   = $tenantDomain
            AppName        = $appName
            RequiredScopes = $requiredPermissionNames
            RecordPath     = $recordPath
            Message        = "Run again with -Execute to create application '$appName', grant org-wide admin consent for $($requiredPermissionNames -join ', '), and record $recordPath."
        }
    }

    if (-not $PSCmdlet.ShouldProcess("tenant $($context.TenantId)", "Create app registration '$appName' and grant admin consent for $($requiredPermissionNames -join ', ')")) {
        return
    }

    $requiredResourceAccess = @(
        @{
            ResourceAppId  = $graphAppId
            ResourceAccess = @($resolvedScopes | ForEach-Object { @{ Id = $_.Id; Type = 'Scope' } })
        }
    )
    $application = New-MgApplication -DisplayName $appName -SignInAudience 'AzureADMyOrg' `
        -RequiredResourceAccess $requiredResourceAccess `
        -IsFallbackPublicClient `
        -PublicClient @{ RedirectUris = @('http://localhost') } `
        -ErrorAction Stop
    # The broker redirect URI embeds the AppId, which only exists after creation, so it needs
    # a follow-up update rather than being included in the create call above. See the
    # AlreadyRegistered branch above for why this URI is needed at all (AADSTS50011/WAM).
    Update-MgApplication -ApplicationId $application.Id -PublicClient @{ RedirectUris = @('http://localhost', "ms-appx-web://Microsoft.AAD.BrokerPlugin/$($application.AppId)") } -ErrorAction Stop
    $servicePrincipal = New-MgServicePrincipal -AppId $application.AppId -ErrorAction Stop
    New-MgOauth2PermissionGrant -BodyParameter @{
        ClientId    = $servicePrincipal.Id
        ConsentType = 'AllPrincipals'
        ResourceId  = $graphServicePrincipal.Id
        Scope       = ($requiredPermissionNames -join ' ')
    } -ErrorAction Stop | Out-Null

    $record = [ordered]@{
        TenantId      = $context.TenantId
        TenantDomain  = $tenantDomain
        ClientId      = $application.AppId
        AppName       = $appName
        CreatedAtUtc  = (Get-Date).ToUniversalTime().ToString('o')
        GrantedScopes = $requiredPermissionNames
    }
    $parent = Split-Path -Path $recordPath -Parent
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $record | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $recordPath -Encoding UTF8

    [pscustomobject]@{
        Status        = 'Created'
        TenantId      = $record.TenantId
        TenantDomain  = $record.TenantDomain
        ClientId      = $record.ClientId
        AppName       = $record.AppName
        GrantedScopes = $record.GrantedScopes
        RecordPath    = $recordPath
    }
}
