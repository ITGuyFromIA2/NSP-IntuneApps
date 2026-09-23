function Resolve-NSPIntuneWin32AppIdByDisplayName {
    <#
    .SYNOPSIS
        Resolves a Win32 app's Intune object ID by an exact DisplayName match, live from Graph.
    .DESCRIPTION
        Used by dependency resolution (AppDependency in a settings file) and anywhere else a
        settings file names a related app by its catalog DisplayName rather than a raw object ID.
        Throws rather than guessing when zero or more than one win32LobApp matches - matching this
        repo's "stop on ambiguity" safety contract (docs/Architecture.md).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId
    )

    Connect-NSPGraph -Scopes (Get-NSPGraphRoutineScopes) -Connect -ClientId $ClientId -TenantId $TenantId | Out-Null

    $escapedName = $DisplayName.Replace("'", "''")
    $uri = "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps?`$filter=isof('microsoft.graph.win32LobApp') and displayName eq '$escapedName'&`$select=id,displayName"
    $matches = @(Invoke-NSPGraphCollection -Uri $uri)
    if ($matches.Count -eq 0) { throw "No Win32 app named '$DisplayName' was found in tenant $TenantId." }
    if ($matches.Count -gt 1) { throw "Multiple Win32 apps named '$DisplayName' were found in tenant $TenantId; cannot resolve unambiguously." }
    [string]$matches[0].id
}
