[CmdletBinding()]
param()

$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Rdp.config.json') -Raw | ConvertFrom-Json
$destinationRoot = if ($config.Destination -eq 'StartMenu') {
    Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs'
} else {
    [Environment]::GetFolderPath('CommonDesktopDirectory')
}
$destination = Join-Path $destinationRoot ([string]$config.FileName)
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Connection.rdp') -Destination $destination -Force
