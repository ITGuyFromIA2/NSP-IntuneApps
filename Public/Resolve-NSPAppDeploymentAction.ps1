function Resolve-NSPAppDeploymentAction {
    <#
    .SYNOPSIS
        Produces a read-only deployment action from desired and discovered Intune app state.
    .DESCRIPTION
        Existing apps without complete NSP management markers are never adopted automatically.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SourceId,
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter(Mandatory)][string]$Publisher,
        [Parameter(Mandatory)][ValidatePattern('^[A-Fa-f0-9]{64}$')][string]$MetadataSha256,
        [Parameter(Mandatory)][ValidatePattern('^[A-Fa-f0-9]{64}$')][string]$ContentSha256,
        [object[]]$ExistingApp = @(),
        [switch]$BreakingChange
    )

    $sourceMarker = "[NSP-IntuneApps:$SourceId]"
    $managedMatches = @($ExistingApp | Where-Object { ([string]$_.Notes).Contains($sourceMarker) })
    if ($managedMatches.Count -gt 0) {
        $matches = $managedMatches
        $matchMethod = 'SourceId'
    } else {
        $matches = @($ExistingApp | Where-Object { [string]$_.DisplayName -eq $DisplayName -and [string]$_.Publisher -eq $Publisher })
        $matchMethod = 'DisplayNamePublisher'
    }

    $action = $null
    $reason = $null
    $canExecute = $false
    $existingId = $null
    if ($matches.Count -eq 0) {
        $action = 'Create'
        $reason = 'No existing app matched the stable source identity or display-name/publisher fallback.'
        $canExecute = $true
    } elseif ($matches.Count -gt 1) {
        $action = 'Conflict'
        $reason = "Found $($matches.Count) possible existing apps. Selection must be resolved manually."
    } else {
        $existing = $matches[0]
        $existingId = [string]$existing.Id
        $notes = [string]$existing.Notes
        $metadataMatch = [regex]::Match($notes, '\[NSP-Metadata-SHA256:([A-Fa-f0-9]{64})\]')
        $contentMatch = [regex]::Match($notes, '\[NSP-Content-SHA256:([A-Fa-f0-9]{64})\]')
        if (-not $notes.Contains($sourceMarker) -or -not $metadataMatch.Success -or -not $contentMatch.Success) {
            $action = 'AdoptOrReview'
            $reason = 'The existing app is not fully marked as NSP-managed. Automatic adoption is prohibited.'
        } else {
            $metadataChanged = $metadataMatch.Groups[1].Value -ne $MetadataSha256
            $contentChanged = $contentMatch.Groups[1].Value -ne $ContentSha256
            if (-not $metadataChanged -and -not $contentChanged) {
                $action = 'NoChange'
                $reason = 'Recorded metadata and content hashes match.'
                $canExecute = $true
            } elseif ($BreakingChange) {
                $action = 'CreateSupersedingApp'
                $reason = 'The proposed change is marked breaking, so it must be introduced side-by-side with an explicit supersedence relationship.'
                $canExecute = $true
            } elseif ($contentChanged) {
                $action = 'UpdateContentInPlace'
                $reason = 'The managed content changed without a declared breaking install contract; preserve the Intune object ID and upload a new content version.'
                $canExecute = $true
            } else {
                $action = 'UpdateMetadataInPlace'
                $reason = 'Only managed metadata changed; preserve the Intune object ID and patch its properties.'
                $canExecute = $true
            }
        }
    }

    [pscustomobject]@{
        SourceId=$SourceId
        DisplayName=$DisplayName
        MatchMethod=$matchMethod
        MatchCount=$matches.Count
        ExistingObjectId=$existingId
        Action=$action
        CanExecute=$canExecute
        Reason=$reason
        ManagementNotes=@($sourceMarker, "[NSP-Metadata-SHA256:$($MetadataSha256.ToUpperInvariant())]", "[NSP-Content-SHA256:$($ContentSha256.ToUpperInvariant())]") -join [Environment]::NewLine
    }
}
