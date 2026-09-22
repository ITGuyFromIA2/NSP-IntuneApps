function Get-NSPIntuneAppInventory {
    <#
    .SYNOPSIS
        Saves a read-only inventory of Intune Win32 apps for deployment planning.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [string]$OutputPath,
        [switch]$Connect
    )

    $scope = 'DeviceManagementApps.Read.All'
    $context = Connect-NSPGraph -Scopes $scope -Connect:$Connect

    $uri = "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps?`$filter=isof('microsoft.graph.win32LobApp')&`$select=id,displayName,publisher,notes,committedContentVersion,lastModifiedDateTime,publishingState"
    $apps = @(Invoke-NSPGraphCollection -Uri $uri | ForEach-Object {
        [ordered]@{
            Id=[string]$_.id
            DisplayName=[string]$_.displayName
            Publisher=[string]$_.publisher
            Notes=[string]$_.notes
            CommittedContentVersion=[string]$_.committedContentVersion
            LastModifiedDateTime=$_.lastModifiedDateTime
            PublishingState=[string]$_.publishingState
        }
    })
    if (-not $OutputPath) {
        $inventoryRoot = Join-Path $RepoRoot '.nsp-intuneapps\inventory'
        $safeTenant = ([string]$context.TenantId -replace '[^A-Za-z0-9-]', '')
        $OutputPath = Join-Path $inventoryRoot ("intune-apps-{0}-{1}.json" -f $safeTenant, (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }
    $document = [ordered]@{
        SchemaVersion='1.0'
        TenantId=[string]$context.TenantId
        Account=[string]$context.Account
        CollectedAt=(Get-Date).ToString('o')
        GraphApi='v1.0'
        RequiredScope=$scope
        Apps=$apps
    }
    if ($PSCmdlet.ShouldProcess($OutputPath, "Save read-only inventory of $($apps.Count) Win32 app(s) from tenant $($context.TenantId)")) {
        $parent = Split-Path -Path $OutputPath -Parent
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        $document | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    }
    [pscustomobject]@{
        TenantId=$document.TenantId
        Account=$document.Account
        AppCount=$apps.Count
        ManagedCount=@($apps | Where-Object { $_.Notes -match '\[NSP-IntuneApps:' }).Count
        OutputPath=$OutputPath
        Apps=$apps
    }
}
