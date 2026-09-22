function Remove-NSPIntuneWin32App {
    <#
    .SYNOPSIS
        Permanently deletes an existing Win32 app from Intune.
    .DESCRIPTION
        Plan-only is the default. Use -Execute and approve ShouldProcess to actually delete the
        app. This is a deliberate, explicitly reviewed operation - never invoked automatically by
        planning or execution. Automatic delete/recreate as an update mechanism remains excluded
        by design (see PLAN.md's "Deferred or explicitly excluded"); this exists for genuine,
        human-confirmed cleanup, such as removing a test-tenant app or retiring a superseded
        object once its replacement is confirmed working. It does not create a replacement -
        pair it with New-NSPIntuneWin32App as two separate, separately reviewed steps.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$IntuneObjectId,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [string]$DisplayName,
        [switch]$Execute
    )

    $label = if ($DisplayName) { "'$DisplayName' ($IntuneObjectId)" } else { $IntuneObjectId }

    if (-not $Execute) {
        return [pscustomobject]@{
            Status         = 'PlanOnly'
            IntuneObjectId = $IntuneObjectId
            DisplayName    = $DisplayName
            Message        = "Run again with -Execute to permanently delete $label from tenant $TenantId. This cannot be undone."
        }
    }

    if (-not $PSCmdlet.ShouldProcess("tenant $TenantId", "Permanently delete Win32 app $label")) { return }

    if (-not (Get-Module -ListAvailable IntuneWin32App)) {
        Import-NSPBootstrap | Out-Null
        Install-NSPModule -Name IntuneWin32App -Scope CurrentUser
    }
    Import-Module IntuneWin32App -ErrorAction Stop
    Connect-MSIntuneGraph -TenantID $TenantId -ClientID $ClientId | Out-Null

    Remove-IntuneWin32App -ID $IntuneObjectId -Confirm:$false -ErrorAction Stop

    [pscustomobject]@{
        Status         = 'Deleted'
        IntuneObjectId = $IntuneObjectId
        DisplayName    = $DisplayName
        TenantId       = $TenantId
    }
}
