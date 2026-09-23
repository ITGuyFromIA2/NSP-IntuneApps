function Add-NSPIntuneWin32AppSupersedence {
    <#
    .SYNOPSIS
        Relates a newly created Win32 app to the app it supersedes.
    .DESCRIPTION
        Plan-only is the default; use -Execute and approve ShouldProcess to write. Wraps
        IntuneWin32App's New-IntuneWin32AppSupersedence/Add-IntuneWin32AppSupersedence.
        SupersedenceType is an explicit operator choice, recorded at plan-approval time (see
        Set-NSPAppDeploymentDecisions) rather than guessed here: 'Update' keeps the old app's
        install/config state in place (a newer version of the same product - the common case),
        'Replace' uninstalls the old app first (an unrelated product being swapped in).

        Before writing, walks the existing supersedence graph outward from the superseded app
        (each node's own Get-IntuneWin32AppSupersedence targets, breadth-first, cycle-safe) and
        refuses if this new relationship would bring the total node count over Intune's hard
        10-node cap. IntuneWin32App's own Add-IntuneWin32AppSupersedence only checks the count of
        the array passed in a single call - it has no way to know about a longer chain the new
        relationship would join, since it never looks past the one app it is called against.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$NewIntuneObjectId,
        [string]$NewAppDisplayName,
        [Parameter(Mandatory)][string]$SupersededIntuneObjectId,
        [string]$SupersededAppDisplayName,
        [ValidateSet('Update', 'Replace')][string]$SupersedenceType = 'Update',
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [switch]$Execute
    )

    $newLabel = if ($NewAppDisplayName) { $NewAppDisplayName } else { $NewIntuneObjectId }
    $oldLabel = if ($SupersededAppDisplayName) { $SupersededAppDisplayName } else { $SupersededIntuneObjectId }
    $actionLabel = "$SupersedenceType-supersede '$oldLabel' with '$newLabel'"

    if (-not $Execute) {
        return [pscustomobject]@{
            Status                   = 'PlanOnly'
            NewIntuneObjectId        = $NewIntuneObjectId
            SupersededIntuneObjectId = $SupersededIntuneObjectId
            SupersedenceType         = $SupersedenceType
            Message                  = "Run again with -Execute to $actionLabel in tenant $TenantId. The combined supersedence graph will be checked against Intune's 10-node limit first."
        }
    }

    if (-not $PSCmdlet.ShouldProcess("tenant $TenantId", $actionLabel)) { return }

    if (-not (Get-Module -ListAvailable IntuneWin32App)) {
        Import-NSPBootstrap | Out-Null
        Install-NSPModule -Name IntuneWin32App -Scope CurrentUser
    }
    Import-Module IntuneWin32App -ErrorAction Stop
    Connect-MSIntuneGraph -TenantID $TenantId -ClientID $ClientId | Out-Null

    $visited = [Collections.Generic.HashSet[string]]::new()
    $frontier = [Collections.Generic.Queue[string]]::new()
    $frontier.Enqueue($SupersededIntuneObjectId)
    while ($frontier.Count -gt 0) {
        $current = $frontier.Dequeue()
        if (-not $visited.Add($current)) { continue }
        $relations = @(Get-IntuneWin32AppSupersedence -ID $current)
        foreach ($relation in $relations) {
            if ($relation.targetId -and -not $visited.Contains($relation.targetId)) { $frontier.Enqueue($relation.targetId) }
        }
    }
    $projectedNodeCount = $visited.Count + 1
    if ($projectedNodeCount -gt 10) {
        throw "Adding this relationship would bring the supersedence graph to $projectedNodeCount node(s), over Intune's 10-node limit. Existing chain: $($visited -join ', ')."
    }

    $descriptor = New-IntuneWin32AppSupersedence -ID $SupersededIntuneObjectId -SupersedenceType $SupersedenceType
    Add-IntuneWin32AppSupersedence -ID $NewIntuneObjectId -Supersedence @($descriptor) -ErrorAction Stop | Out-Null

    [pscustomobject]@{
        Status                   = 'Related'
        NewIntuneObjectId        = $NewIntuneObjectId
        SupersededIntuneObjectId = $SupersededIntuneObjectId
        SupersedenceType         = $SupersedenceType
        GraphNodeCount           = $projectedNodeCount
        TenantId                 = $TenantId
    }
}
