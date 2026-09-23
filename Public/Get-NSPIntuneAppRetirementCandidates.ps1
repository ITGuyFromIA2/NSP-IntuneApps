function Get-NSPIntuneAppRetirementCandidates {
    <#
    .SYNOPSIS
        Read-only: finds NSP-managed apps that another NSP-managed app already supersedes.
    .DESCRIPTION
        Cleanup of a superseded app is never automatic - CreateSupersedingApp's AddSupersedence
        stage only relates the two objects, it never deletes the old one, so an operator can
        confirm the replacement is actually working first. This harvests every Win32 app's own
        supersedence relationships and reports a candidate only when BOTH the new (superseding)
        and old (superseded) app carry an [NSP-IntuneApps:...] marker in Notes - an app this repo
        did not create/manage is never surfaced here, even if some other relationship happens to
        reference it. Pair with Remove-NSPIntuneWin32App for the actual (separately approved)
        deletion; this function makes no tenant changes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$Connect
    )

    $registrationPath = Join-Path $RepoRoot 'Config\Local\GraphAppRegistration.json'
    $registration = if (Test-Path -LiteralPath $registrationPath) { Get-Content -LiteralPath $registrationPath -Raw | ConvertFrom-Json } else { $null }
    $context = Connect-NSPGraph -Scopes (Get-NSPGraphRoutineScopes) -Connect:$Connect -ClientId ([string]$registration.ClientId) -TenantId ([string]$registration.TenantId)

    $appsUri = "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps?`$filter=isof('microsoft.graph.win32LobApp')&`$select=id,displayName,notes"
    $apps = @(Invoke-NSPGraphCollection -Uri $appsUri)
    $appsById = @{}
    foreach ($app in $apps) { $appsById[[string]$app.id] = $app }

    $sourceIdPattern = '\[NSP-IntuneApps:([^\]]+)\]'
    $candidates = @(foreach ($app in $apps) {
        $newMatch = [regex]::Match([string]$app.notes, $sourceIdPattern)
        if (-not $newMatch.Success) { continue }
        $relationshipsUri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$($app.id)/relationships"
        $relationships = @(Invoke-NSPGraphCollection -Uri $relationshipsUri | Where-Object { [string]$_.'@odata.type' -like '*mobileAppSupersedence' })
        foreach ($relationship in $relationships) {
            $oldApp = $appsById[[string]$relationship.targetId]
            if (-not $oldApp) { continue }
            $oldMatch = [regex]::Match([string]$oldApp.notes, $sourceIdPattern)
            if (-not $oldMatch.Success) { continue }
            [pscustomobject][ordered]@{
                SupersededAppId       = [string]$oldApp.id
                SupersededDisplayName = [string]$oldApp.displayName
                SupersededSourceId    = $oldMatch.Groups[1].Value
                SupersedingAppId      = [string]$app.id
                SupersedingDisplayName = [string]$app.displayName
                SupersedingSourceId   = $newMatch.Groups[1].Value
                SupersedenceType      = [string]$relationship.supersedenceType
            }
        }
    })

    [pscustomobject]@{
        TenantId   = [string]$context.TenantId
        Account    = [string]$context.Account
        Candidates = $candidates
        Count      = $candidates.Count
    }
}
