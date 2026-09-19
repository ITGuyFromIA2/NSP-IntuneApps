$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Shortcut.config.json') -Raw | ConvertFrom-Json

function Get-ShortcutDestination {
    param($Config)
    $root = if ($Config.Destination -eq 'StartMenu') {
        [Environment]::GetFolderPath('CommonPrograms')
    } else {
        [Environment]::GetFolderPath('CommonDesktopDirectory')
    }
    Join-Path $root $Config.FileName
}

function Find-ConfiguredBrowser {
    param([string]$Browser)
    $relative = if ($Browser -eq 'Chrome') { 'Google\Chrome\Application\chrome.exe' } else { 'Microsoft\Edge\Application\msedge.exe' }
    $candidates = @(
        Join-Path ${env:ProgramFiles(x86)} $relative
        Join-Path $env:ProgramFiles $relative
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
    if ($candidates.Count -eq 0) { throw "$Browser is not installed in a standard machine-wide location." }
    $candidates[0]
}

$destination = Get-ShortcutDestination -Config $config
New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null

if ($config.Mode -eq 'WebDefault') {
    @('[InternetShortcut]', "URL=$($config.Target)") | Set-Content -LiteralPath $destination -Encoding ASCII
    return
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($destination)
if ($config.Mode -eq 'WebBrowser') {
    $shortcut.TargetPath = Find-ConfiguredBrowser -Browser $config.Browser
    $shortcut.Arguments = '"{0}"' -f $config.Target
} else {
    $shortcut.TargetPath = [Environment]::ExpandEnvironmentVariables([string]$config.Target)
    $shortcut.Arguments = [Environment]::ExpandEnvironmentVariables([string]$config.Arguments)
}
$shortcut.Description = [string]$config.Description
if ($config.IconPath) { $shortcut.IconLocation = [Environment]::ExpandEnvironmentVariables([string]$config.IconPath) }
$shortcut.Save()
