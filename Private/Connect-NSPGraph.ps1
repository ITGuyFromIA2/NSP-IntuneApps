function Connect-NSPGraph {
    <#
    .SYNOPSIS
        Connects to Microsoft Graph or validates an existing delegated context, with the required scopes.
    .DESCRIPTION
        Pass -ClientId/-TenantId (the recorded NSP-IntuneApps-Win32AppDeployment registration) to
        authenticate as that app instead of the Microsoft Graph PowerShell SDK's own default app.
        Since that app already has org-wide admin consent for everything this tool needs, Azure AD
        recognizes it as pre-consented and can pass through silently instead of prompting - the
        same benefit IntuneWin32App's Connect-MSIntuneGraph already gets from using one app
        consistently. Without them, this falls back to the SDK's own default app (unchanged
        behavior for callers that don't yet know a registration exists).

        -Connect only actually calls Connect-MgGraph when the existing session (if any) is
        insufficient - missing a scope, or authenticated as a different app/tenant than
        requested. Reconnecting unconditionally on every call was itself a source of repeated
        sign-in prompts even when a perfectly good session already existed this process.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]]$Scopes,
        [switch]$Connect,
        [switch]$Optional,
        [string]$ClientId,
        [string]$TenantId
    )

    if ($Connect) {
        if (-not (Get-Module -ListAvailable Microsoft.Graph.Authentication)) {
            Import-NSPBootstrap | Out-Null
            Install-NSPModule -Name Microsoft.Graph.Authentication -Scope CurrentUser
        }
        Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

        $existingContext = if (Get-Command Get-MgContext -ErrorAction SilentlyContinue) { Get-MgContext } else { $null }
        $hasRequiredScopes = $existingContext -and (@($Scopes | Where-Object { $_ -notin @($existingContext.Scopes) })).Count -eq 0
        $matchesRequestedApp = (-not $ClientId -or $existingContext.ClientId -eq $ClientId) -and (-not $TenantId -or $existingContext.TenantId -eq $TenantId)

        if (-not ($existingContext -and $hasRequiredScopes -and $matchesRequestedApp)) {
            $connectArgs = @{ Scopes = $Scopes; NoWelcome = $true }
            if ($ClientId) { $connectArgs.ClientId = $ClientId }
            if ($TenantId) { $connectArgs.TenantId = $TenantId }
            Connect-MgGraph @connectArgs | Out-Null
        }
    }

    $context = if (Get-Command Get-MgContext -ErrorAction SilentlyContinue) { Get-MgContext } else { $null }
    if (-not $context) {
        if ($Optional) { return $null }
        throw 'No Microsoft Graph context is available. Use -Connect for delegated interactive login.'
    }
    if (-not $Optional) {
        $missingScopes = @($Scopes | Where-Object { $_ -notin @($context.Scopes) })
        if (@($missingScopes).Count -gt 0) {
            throw "The current Graph context lacks required scope(s): $($missingScopes -join ', '). Reconnect with -Connect."
        }
    }
    $context
}
