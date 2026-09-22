function Update-NSPIntuneWin32AppContent {
    <#
    .SYNOPSIS
        Uploads a new content version for an existing Win32 app: the UploadContent and
        CommitContent stages of UpdateContentInPlace.
    .DESCRIPTION
        Plan-only is the default. Use -Execute and approve ShouldProcess to actually upload
        the new package content against the tenant. Update-IntuneWin32AppPackageFile performs
        the content-version create/upload/commit sequence as one call, so CommitContent is
        recorded as its own stage transition with no further work, matching how Package is
        already folded into New-NSPAppPackage's own transition for the Create path. The
        object's Intune ID is preserved; no new app is created. Management notes are recorded
        separately by RecordManagementNotes/Set-NSPAppManagementNotes, matching
        docs/DeploymentEngine.md's execution gate of treating the metadata PATCH as its own
        recorded operation.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$AppName,
        [Parameter(Mandatory)][string]$PackagePath,
        [Parameter(Mandatory)][string]$IntuneObjectId,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [switch]$Execute
    )

    if (-not (Test-Path -LiteralPath $PackagePath)) { throw "Package not found: $PackagePath" }

    if (-not $Execute) {
        return [pscustomobject]@{
            Status         = 'PlanOnly'
            AppName        = $AppName
            IntuneObjectId = $IntuneObjectId
            PackagePath    = $PackagePath
            Message        = "Run again with -Execute to upload a new content version for '$AppName' ($IntuneObjectId) in tenant $TenantId."
        }
    }

    if (-not $PSCmdlet.ShouldProcess("tenant $TenantId", "Upload new content version for '$AppName' ($IntuneObjectId)")) { return }

    if (-not (Get-Module -ListAvailable IntuneWin32App)) {
        Import-NSPBootstrap | Out-Null
        Install-NSPModule -Name IntuneWin32App -Scope CurrentUser
    }
    Import-Module IntuneWin32App -ErrorAction Stop
    Connect-MSIntuneGraph -TenantID $TenantId -ClientID $ClientId | Out-Null

    Update-IntuneWin32AppPackageFile -ID $IntuneObjectId -FilePath $PackagePath -ErrorAction Stop | Out-Null

    [pscustomobject]@{
        Status         = 'Updated'
        AppName        = $AppName
        IntuneObjectId = $IntuneObjectId
        TenantId       = $TenantId
        PackagePath    = $PackagePath
    }
}
