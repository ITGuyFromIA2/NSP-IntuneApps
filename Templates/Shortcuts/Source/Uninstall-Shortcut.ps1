$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Shortcut.config.json') -Raw | ConvertFrom-Json
$root = if ($config.Destination -eq 'StartMenu') {
    [Environment]::GetFolderPath('CommonPrograms')
} else {
    [Environment]::GetFolderPath('CommonDesktopDirectory')
}
$destination = Join-Path $root $config.FileName
Remove-Item -LiteralPath $destination -Force -ErrorAction SilentlyContinue
