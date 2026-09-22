function Get-NSPIntuneAppAssignmentInventory {
    <#
    .SYNOPSIS
        Saves a read-only inventory of existing Win32 app assignments and assignment filters.
    .DESCRIPTION
        Harvests every Win32 app's current assignments (group, intent, and any assignment
        filter) plus every assignment filter defined in the tenant (display name, platform,
        rule), so an operator can pick from groups/filters already in real use instead of
        hand-typing object IDs. Makes no tenant changes.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [string]$OutputPath,
        [switch]$Connect
    )

    $registrationPath = Join-Path $RepoRoot 'Config\Local\GraphAppRegistration.json'
    $registration = if (Test-Path -LiteralPath $registrationPath) { Get-Content -LiteralPath $registrationPath -Raw | ConvertFrom-Json } else { $null }
    $scope = 'DeviceManagementApps.ReadWrite.All'
    $context = Connect-NSPGraph -Scopes $scope -Connect:$Connect -ClientId ([string]$registration.ClientId) -TenantId ([string]$registration.TenantId)

    $appsUri = "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps?`$filter=isof('microsoft.graph.win32LobApp')&`$select=id,displayName"
    $apps = @(Invoke-NSPGraphCollection -Uri $appsUri)

    $filterCache = @{}
    # Assignment filters are not exposed at v1.0 for every tenant yet ("Resource not found for
    # the segment 'assignmentFilters'"); beta is the reliable endpoint, matching how
    # Publish-NSPCodeSigningTrust already uses beta for device configuration profiles.
    $filtersUri = 'https://graph.microsoft.com/beta/deviceManagement/assignmentFilters'
    $filters = @(Invoke-NSPGraphCollection -Uri $filtersUri | ForEach-Object {
        $filterCache[[string]$_.id] = [string]$_.displayName
        [pscustomobject][ordered]@{
            Id          = [string]$_.id
            DisplayName = [string]$_.displayName
            Platform    = [string]$_.platform
            Rule        = [string]$_.rule
        }
    })

    $groupCache = @{}
    $assignments = @(foreach ($app in $apps) {
        $assignmentUri = "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$($app.id)/assignments"
        foreach ($assignment in @(Invoke-NSPGraphCollection -Uri $assignmentUri)) {
            $groupId = [string]$assignment.target.groupId
            if ($groupId -and -not $groupCache.ContainsKey($groupId)) {
                try {
                    $groupUri = "https://graph.microsoft.com/v1.0/groups/${groupId}?`$select=id,displayName"
                    $group = Invoke-MgGraphRequest -Method GET -Uri $groupUri -ErrorAction Stop
                    $groupCache[$groupId] = [string]$group.displayName
                } catch { $groupCache[$groupId] = $null }
            }
            $filterId = [string]$assignment.target.deviceAndAppManagementAssignmentFilterId

            [pscustomobject][ordered]@{
                AppId             = [string]$app.id
                AppDisplayName    = [string]$app.displayName
                Intent            = [string]$assignment.intent
                TargetType        = [string]$assignment.target.'@odata.type'
                GroupId           = if ($groupId) { $groupId } else { $null }
                GroupDisplayName  = if ($groupId) { $groupCache[$groupId] } else { $null }
                FilterId          = if ($filterId) { $filterId } else { $null }
                FilterDisplayName = if ($filterId -and $filterCache.ContainsKey($filterId)) { $filterCache[$filterId] } else { $null }
                FilterMode        = [string]$assignment.target.deviceAndAppManagementAssignmentFilterType
            }
        }
    })

    $distinctGroups = @($assignments | Where-Object GroupId | Select-Object GroupId, GroupDisplayName -Unique)

    if (-not $OutputPath) {
        $inventoryRoot = Join-Path $RepoRoot '.nsp-intuneapps\assignment-inventory'
        $safeTenant = ([string]$context.TenantId -replace '[^A-Za-z0-9-]', '')
        $OutputPath = Join-Path $inventoryRoot ("assignments-{0}-{1}.json" -f $safeTenant, (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }

    $document = [ordered]@{
        SchemaVersion  = '1.0'
        TenantId       = [string]$context.TenantId
        Account        = [string]$context.Account
        CollectedAt    = (Get-Date).ToString('o')
        Filters        = $filters
        Assignments    = $assignments
        DistinctGroups = $distinctGroups
    }

    if ($PSCmdlet.ShouldProcess($OutputPath, "Save read-only inventory of $($assignments.Count) app assignment(s) and $($filters.Count) filter(s) from tenant $($context.TenantId)")) {
        $parent = Split-Path -Path $OutputPath -Parent
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        $document | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    }

    [pscustomobject]@{
        TenantId        = $document.TenantId
        Account         = $document.Account
        AppCount        = $apps.Count
        AssignmentCount = $assignments.Count
        FilterCount     = $filters.Count
        DistinctGroups  = $distinctGroups
        OutputPath      = $OutputPath
        Filters         = $filters
        Assignments     = $assignments
    }
}
