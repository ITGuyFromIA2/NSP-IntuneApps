function Register-NSPIntuneWin32AppRegistration {
    <#
    .SYNOPSIS
        One-time tenant bootstrap: registers the Azure AD application IntuneWin32App
        authenticates as, and grants it admin consent.
    .DESCRIPTION
        Plan-only is the default. Use -Execute and approve ShouldProcess to actually
        create the application, service principal, and admin consent grant. If a
        registration is already recorded and still exists in the tenant, no duplicate
        is created.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$TenantId,
        [switch]$Execute
    )

    $graphAppId = '00000003-0000-0000-c000-000000000000'
    $appName = 'NSP-IntuneApps-Win32AppDeployment'
    $requiredPermissionNames = @(
        'DeviceManagementApps.ReadWrite.All'
        'DeviceManagementConfiguration.ReadWrite.All'
        'DeviceManagementRBAC.Read.All'
        'Group.Read.All'
    )
    $recordPath = Join-Path $RepoRoot 'Config\Local\GraphAppRegistration.json'

    $connectScopes = @('Application.ReadWrite.All', 'Directory.ReadWrite.All', 'DelegatedPermissionGrant.ReadWrite.All')
    $context = Connect-NSPGraph -Scopes $connectScopes -Connect
    if ($context.TenantId -ne $TenantId) {
        throw "Connected to tenant $($context.TenantId), which does not match the requested TenantId $TenantId. Reconnect against the correct tenant."
    }

    if (Test-Path -LiteralPath $recordPath) {
        $record = Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json
        $existingApp = @(Get-MgApplication -Filter "appId eq '$($record.ClientId)'")
        if (@($existingApp).Count -gt 0) {
            return [pscustomobject]@{
                Status       = 'AlreadyRegistered'
                TenantId     = [string]$record.TenantId
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
    $servicePrincipal = New-MgServicePrincipal -AppId $application.AppId -ErrorAction Stop
    New-MgOauth2PermissionGrant -BodyParameter @{
        ClientId    = $servicePrincipal.Id
        ConsentType = 'AllPrincipals'
        ResourceId  = $graphServicePrincipal.Id
        Scope       = ($requiredPermissionNames -join ' ')
    } -ErrorAction Stop | Out-Null

    $record = [ordered]@{
        TenantId      = $context.TenantId
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
        ClientId      = $record.ClientId
        AppName       = $record.AppName
        GrantedScopes = $record.GrantedScopes
        RecordPath    = $recordPath
    }
}
