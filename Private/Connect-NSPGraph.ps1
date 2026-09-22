function Connect-NSPGraph {
    <#
    .SYNOPSIS
        Connects to Microsoft Graph or validates an existing delegated context, with the required scopes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]]$Scopes,
        [switch]$Connect,
        [switch]$Optional
    )

    if ($Connect) {
        if (-not (Get-Module -ListAvailable Microsoft.Graph.Authentication)) {
            Import-NSPBootstrap | Out-Null
            Install-NSPModule -Name Microsoft.Graph.Authentication -Scope CurrentUser
        }
        Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
        Connect-MgGraph -Scopes $Scopes -NoWelcome | Out-Null
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
