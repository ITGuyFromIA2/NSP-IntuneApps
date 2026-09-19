function Get-NSPIntuneAppCatalog {
    <#
    .SYNOPSIS
        Inventories and classifies top-level entries in the Intune app catalog.
    .EXAMPLE
        Get-NSPIntuneAppCatalog -RepoRoot C:\GitRepos\NSP-IntuneApps
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot
    )

    $appsRoot = Join-Path $RepoRoot 'Apps'
    if (-not (Test-Path -LiteralPath $appsRoot)) { throw "Apps directory not found: $appsRoot" }

    foreach ($directory in Get-ChildItem -LiteralPath $appsRoot -Directory | Sort-Object Name) {
        $files = @(Get-ChildItem -LiteralPath $directory.FullName -Recurse -File)
        $settings = @($files | Where-Object { $_.Name -like '*_SplitScriptSettings.ps1' })
        $scripts = @($files | Where-Object { $_.Extension -eq '.ps1' })
        $packages = @($files | Where-Object { $_.Extension -eq '.intunewin' })
        $legacyMarkers = @($files | Where-Object { $_.Name -eq 'Build.bat' -or $_.Name -eq 'IntuneWinAppUtil.exe' })
        $configurationMarkers = @($files |
            Where-Object { $_.Extension -in @('.ps1','.psd1','.json','.txt','.reg','.xml','.ini','.cmd','.bat') } |
            Select-String -Pattern 'REPLACE_WITH_|\.invalid' -ErrorAction SilentlyContinue)
        $catalogMetadataPath = Join-Path $directory.FullName '.nsp-catalog.json'
        $catalogMetadata = if (Test-Path -LiteralPath $catalogMetadataPath) { Get-Content -LiteralPath $catalogMetadataPath -Raw | ConvertFrom-Json } else { $null }

        $metadataClassifications = @('RetiredDuplicate', 'RetiredTemplate', 'RequiresRepair')
        if ($catalogMetadata -and $catalogMetadata.Classification -in $metadataClassifications) {
            $classification = [string]$catalogMetadata.Classification
            $reason = [string]$catalogMetadata.Reason
        } elseif ($settings.Count -eq 1 -and $configurationMarkers.Count -gt 0) {
            $classification = 'RequiresConfiguration'
            $reason = 'The app contains explicit placeholder values and is not safe to deploy as-is.'
        } elseif ($settings.Count -eq 1) {
            $classification = 'Deployable'
            $reason = 'One SplitScript settings entry was found.'
        } elseif ($legacyMarkers.Count -gt 0) {
            $classification = 'Legacy'
            $reason = 'Gen1 build markers were found; no current catalog entry exists.'
        } elseif ($directory.Name -match '_Shared$' -or ($files.Count -eq 1 -and $scripts.Count -eq 1)) {
            $classification = 'SharedComponent'
            $reason = 'Shared implementation component; not independently deployable.'
        } elseif ($settings.Count -gt 1) {
            $classification = 'Blocked'
            $reason = 'Multiple SplitScript settings entries were found.'
        } else {
            $classification = 'TemplateOrIncomplete'
            $reason = 'No SplitScript settings entry or legacy marker was found.'
        }

        [pscustomobject]@{
            Name             = $directory.Name
            DisplayName      = if ($settings.Count -eq 1) { Get-NSPSettingsLiteral -SettingsPath $settings[0].FullName -Name DisplayName } else { $null }
            Publisher        = if ($settings.Count -eq 1) { Get-NSPSettingsLiteral -SettingsPath $settings[0].FullName -Name Publisher } else { $null }
            Classification   = $classification
            Reason           = $reason
            SettingsPath     = if ($settings.Count -eq 1) { $settings[0].FullName } else { $null }
            ScriptCount      = $scripts.Count
            PackageCount     = $packages.Count
            LegacyMarkerCount = $legacyMarkers.Count
            ConfigurationMarkerCount = $configurationMarkers.Count
            Path             = $directory.FullName
            Replacement      = if ($catalogMetadata) { [string]$catalogMetadata.Replacement } else { $null }
        }
    }
}
