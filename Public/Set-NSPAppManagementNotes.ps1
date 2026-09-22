function Set-NSPAppManagementNotes {
    <#
    .SYNOPSIS
        Patches the deterministic NSP management-notes marker onto an existing Intune app:
        the RecordManagementNotes stage for update paths (UpdateContentInPlace,
        UpdateMetadataInPlace).
    .DESCRIPTION
        Plan-only is the default. Use -Execute and approve ShouldProcess to actually patch
        the tenant. Unlike the Create path (where RecordManagementNotes is a no-op because
        CreateApp already patches notes as part of the same write), update paths preserve an
        existing object and do real work here: recomputing the current source hashes and
        writing them, so a subsequent planning pass sees NoChange.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$AppName,
        [Parameter(Mandatory)][string]$IntuneObjectId,
        [switch]$Execute
    )

    $sourceState = Get-NSPAppSourceState -RepoRoot $RepoRoot -AppName $AppName

    if (-not $Execute) {
        return [pscustomobject]@{
            Status          = 'PlanOnly'
            AppName         = $AppName
            IntuneObjectId  = $IntuneObjectId
            ManagementNotes = $sourceState.ManagementNotes
            Message         = "Run again with -Execute to patch management notes onto '$AppName' ($IntuneObjectId)."
        }
    }

    if (-not $PSCmdlet.ShouldProcess($IntuneObjectId, "Patch management notes for '$AppName'")) { return }

    $graphContext = Connect-NSPGraph -Scopes 'DeviceManagementApps.ReadWrite.All' -Connect
    $patchBody = @{ '@odata.type' = '#microsoft.graph.win32LobApp'; notes = $sourceState.ManagementNotes } | ConvertTo-Json
    Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$IntuneObjectId" -Body $patchBody -ContentType 'application/json' -ErrorAction Stop | Out-Null

    [pscustomobject]@{
        Status          = 'Recorded'
        AppName         = $AppName
        IntuneObjectId  = $IntuneObjectId
        TenantId        = $graphContext.TenantId
        ManagementNotes = $sourceState.ManagementNotes
    }
}
