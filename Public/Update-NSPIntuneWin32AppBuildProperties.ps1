function Update-NSPIntuneWin32AppBuildProperties {
    <#
    .SYNOPSIS
        PATCHes build-time win32LobApp properties an existing app object doesn't get from
        Update-NSPIntuneWin32AppMetadata: InstallExperience, RestartBehavior, and scope tags.
    .DESCRIPTION
        Closes the gap Update-NSPIntuneWin32AppMetadata's own docstring documents: Set-IntuneWin32App
        (the community module) has no cmdlet for these fields, even though Graph's win32LobApp
        resource supports PATCHing them directly. Goes around the module for exactly these fields
        via a raw Graph PATCH on deviceAppManagement/mobileApps/{id}, resolving ScopeTagName to an
        ID through the exact same beta getRoleScopeTagsByResource endpoint Add-IntuneWin32App
        itself uses, so behavior matches creation-time exactly.

        Unlike most plan-then-execute functions here, this one always connects and reads the LIVE
        app object - even without -Execute - because a meaningful plan has to show the real diff
        against current tenant state, not just what the settings file says. Only the actual PATCH
        write is gated behind -Execute and ShouldProcess. Reports NoChange (not an empty PATCH)
        when nothing differs.

        Detection rules and requirement rules are explicitly out of scope here - Graph expects the
        full nested rule object on a PATCH, not a partial merge, so rebuilding those safely is
        future work. Use CreateSupersedingApp for a change significant enough to need them replaced.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$AppName,
        [Parameter(Mandatory)][string]$IntuneObjectId,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [switch]$Execute
    )

    $catalogEntry = Get-NSPIntuneAppCatalog -RepoRoot $RepoRoot | Where-Object Name -eq $AppName
    if (-not $catalogEntry) { throw "App was not found in the catalog: $AppName" }
    if (-not $catalogEntry.SettingsPath) { throw "App does not have one settings file: $AppName" }
    $VariableConfig = $null
    . $catalogEntry.SettingsPath

    $desiredInstallExperience = [string]$VariableConfig.InstallExperience
    $desiredRestartBehavior = [string]$VariableConfig.RestartExperience
    $desiredScopeTagName = [string]$VariableConfig.ScopeTagName
    if ([string]::IsNullOrWhiteSpace($desiredInstallExperience) -or [string]::IsNullOrWhiteSpace($desiredRestartBehavior)) {
        throw "'$AppName' is missing InstallExperience or RestartExperience in its settings file; nothing was compared."
    }

    $graphContext = Connect-NSPGraph -Scopes (Get-NSPGraphRoutineScopes) -Connect -ClientId $ClientId -TenantId $TenantId
    $liveApp = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$IntuneObjectId`?`$select=id,displayName,installExperience,roleScopeTagIds" -ErrorAction Stop

    $desiredScopeTagId = $null
    if (-not [string]::IsNullOrWhiteSpace($desiredScopeTagName)) {
        $escapedScopeTagName = $desiredScopeTagName.Replace("'", "''")
        $scopeTagUri = "https://graph.microsoft.com/beta/deviceManagement/getRoleScopeTagsByResource(resource='MobileApps')?`$filter=displayName eq '$escapedScopeTagName'"
        $scopeTagMatches = @(Invoke-NSPGraphCollection -Uri $scopeTagUri)
        if ($scopeTagMatches.Count -eq 0) { throw "No scope tag named '$desiredScopeTagName' was found in tenant $TenantId." }
        if ($scopeTagMatches.Count -gt 1) { throw "Multiple scope tags named '$desiredScopeTagName' were found in tenant $TenantId; cannot resolve unambiguously." }
        $desiredScopeTagId = [string]$scopeTagMatches[0].id
    }

    $changes = [ordered]@{}
    if ([string]$liveApp.installExperience.runAsAccount -ne $desiredInstallExperience -or [string]$liveApp.installExperience.deviceRestartBehavior -ne $desiredRestartBehavior) {
        $changes.installExperience = @{ runAsAccount = $desiredInstallExperience; deviceRestartBehavior = $desiredRestartBehavior }
    }
    if ($desiredScopeTagId) {
        $liveScopeTagIds = @($liveApp.roleScopeTagIds) | Sort-Object
        $desiredScopeTagIds = @($desiredScopeTagId) | Sort-Object
        if (($liveScopeTagIds -join ',') -ne ($desiredScopeTagIds -join ',')) {
            $changes.roleScopeTagIds = @($desiredScopeTagId)
        }
    }

    if ($changes.Count -eq 0) {
        return [pscustomobject]@{
            Status         = 'NoChange'
            AppName        = $AppName
            IntuneObjectId = $IntuneObjectId
            TenantId       = $graphContext.TenantId
            Message        = "'$AppName' already matches InstallExperience/RestartExperience/ScopeTagName from its settings file. Nothing to patch."
        }
    }

    if (-not $Execute) {
        return [pscustomobject]@{
            Status         = 'PlanOnly'
            AppName        = $AppName
            IntuneObjectId = $IntuneObjectId
            TenantId       = $graphContext.TenantId
            Changes        = [pscustomobject]$changes
            Message        = "Run again with -Execute to PATCH build-time properties for '$AppName' (IntuneObjectId $IntuneObjectId) in tenant $TenantId."
        }
    }

    if (-not $PSCmdlet.ShouldProcess("tenant $TenantId", "PATCH build-time properties for '$AppName' ($IntuneObjectId)")) { return }

    $patchBodyObject = @{ '@odata.type' = '#microsoft.graph.win32LobApp' }
    foreach ($key in $changes.Keys) { $patchBodyObject[$key] = $changes[$key] }
    $patchBody = $patchBodyObject | ConvertTo-Json -Depth 6
    $patchResult = Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$IntuneObjectId" -Body $patchBody -ContentType 'application/json' -ErrorAction Stop
    # Same defense as every other Graph-mutating function here: Invoke-MgGraphRequest does not
    # reliably throw a terminating error for every non-2xx response.
    if ($patchResult -and $patchResult.PSObject.Properties['error']) {
        throw "Graph rejected the build-properties PATCH for '$AppName' ($IntuneObjectId): $($patchResult.error.message)"
    }

    [pscustomobject]@{
        Status         = 'Updated'
        AppName        = $AppName
        IntuneObjectId = $IntuneObjectId
        TenantId       = $graphContext.TenantId
        Changes        = [pscustomobject]$changes
    }
}
