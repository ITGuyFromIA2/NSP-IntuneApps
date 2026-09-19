[CmdletBinding()]
param()

$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'DriveMap.config.json') -Raw | ConvertFrom-Json
$destination = Join-Path $env:ProgramData ('NSP\DriveMaps\{0}' -f $config.Id)
$task = Get-ScheduledTask -TaskName ([string]$config.TaskName) -ErrorAction SilentlyContinue
$installedConfig = Join-Path $destination 'DriveMap.config.json'
if ($task -and (Test-Path -LiteralPath $installedConfig)) {
    $actual = Get-Content -LiteralPath $installedConfig -Raw | ConvertFrom-Json
    if ($actual.DriveLetter -eq $config.DriveLetter -and $actual.Path -eq $config.Path) {
        Write-Output "Drive map '$($config.DisplayName)' is configured."
        exit 0
    }
}
exit 1
