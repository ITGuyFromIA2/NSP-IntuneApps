function Get-NSPAppSourceState {
    <#
    .SYNOPSIS
        Returns stable metadata and content fingerprints for a catalog app.
    .DESCRIPTION
        Authenticode blocks and line-ending differences are normalized so certificate
        renewal or Git checkout settings do not appear as app-content changes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$AppName
    )

    $entry = Get-NSPIntuneAppCatalog -RepoRoot $RepoRoot | Where-Object Name -eq $AppName
    if (-not $entry) { throw "App was not found in the catalog: $AppName" }
    if (-not $entry.SettingsPath) { throw "App does not have one settings file: $AppName" }

    $contentFiles = @(
        foreach ($folderName in @('Source','Detect')) {
            $folder = Join-Path $entry.Path $folderName
            if (Test-Path -LiteralPath $folder) {
                Get-ChildItem -LiteralPath $folder -Recurse -File | Where-Object Extension -ne '.intunewin'
            }
        }
    )
    $metadataFile = Get-Item -LiteralPath $entry.SettingsPath
    $metadataHash = Get-NSPDeterministicTreeHash -Root $entry.Path -File @($metadataFile)
    $contentHash = Get-NSPDeterministicTreeHash -Root $entry.Path -File $contentFiles
    $sourceId = $entry.Name
    $displayName = Get-NSPSettingsLiteral -SettingsPath $entry.SettingsPath -Name DisplayName
    $publisher = Get-NSPSettingsLiteral -SettingsPath $entry.SettingsPath -Name Publisher

    [pscustomobject]@{
        SourceId=$sourceId
        AppName=$entry.Name
        DisplayName=$displayName
        Publisher=$publisher
        Classification=$entry.Classification
        SettingsPath=$entry.SettingsPath
        MetadataSha256=$metadataHash
        ContentSha256=$contentHash
        ContentFileCount=$contentFiles.Count
        ManagementNotes=@("[NSP-IntuneApps:$sourceId]", "[NSP-Metadata-SHA256:$metadataHash]", "[NSP-Content-SHA256:$contentHash]") -join [Environment]::NewLine
    }
}
