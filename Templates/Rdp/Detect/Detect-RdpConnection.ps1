[CmdletBinding()]
param()

$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Rdp.config.json') -Raw | ConvertFrom-Json
$destinationRoot = if ($config.Destination -eq 'StartMenu') {
    Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs'
} else {
    [Environment]::GetFolderPath('CommonDesktopDirectory')
}
$destination = Join-Path $destinationRoot ([string]$config.FileName)
if ((Test-Path -LiteralPath $destination) -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'Connection.rdp'))) {
    $expected = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'Connection.rdp') -Algorithm SHA256).Hash
    $actual = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
    if ($expected -eq $actual) { Write-Output "$($config.DisplayName) is installed."; exit 0 }
}
exit 1
