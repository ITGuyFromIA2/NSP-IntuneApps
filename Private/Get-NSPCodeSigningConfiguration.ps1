function Get-NSPCodeSigningConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot
    )

    $path = Join-Path $RepoRoot 'Z-MiscSetup\CodeSigning\CodeSigning.config.json'
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Code-signing configuration not found: $path"
    }

    $config = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $config | Add-Member -NotePropertyName ConfigPath -NotePropertyValue $path -Force
    $config | Add-Member -NotePropertyName CodeSigningDir -NotePropertyValue (Split-Path -Path $path -Parent) -Force
    $config | Add-Member -NotePropertyName RepoRoot -NotePropertyValue $RepoRoot -Force
    $config
}
