$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Shortcut.config.json') -Raw | ConvertFrom-Json
$root = if ($config.Destination -eq 'StartMenu') {
    [Environment]::GetFolderPath('CommonPrograms')
} else {
    [Environment]::GetFolderPath('CommonDesktopDirectory')
}
$destination = Join-Path $root $config.FileName
if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) { exit 1 }

if ($config.Mode -eq 'WebDefault') {
    $expected = "URL=$($config.Target)"
    if (Get-Content -LiteralPath $destination | Where-Object { $_ -ceq $expected }) {
        Write-Output "Managed shortcut is current: $destination"
        exit 0
    }
    exit 1
}

function Find-ConfiguredBrowser {
    param([string]$Browser)
    $relative = if ($Browser -eq 'Chrome') { 'Google\Chrome\Application\chrome.exe' } else { 'Microsoft\Edge\Application\msedge.exe' }
    @(
        Join-Path ${env:ProgramFiles(x86)} $relative
        Join-Path $env:ProgramFiles $relative
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($destination)
if ($config.Mode -eq 'WebBrowser') {
    $expectedTarget = Find-ConfiguredBrowser -Browser $config.Browser
    $expectedArguments = '"{0}"' -f $config.Target
} else {
    $expectedTarget = [Environment]::ExpandEnvironmentVariables([string]$config.Target)
    $expectedArguments = [Environment]::ExpandEnvironmentVariables([string]$config.Arguments)
}
if ($expectedTarget -and
    $shortcut.TargetPath -ieq $expectedTarget -and
    $shortcut.Arguments -ceq $expectedArguments -and
    $shortcut.Description -ceq [string]$config.Description) {
    Write-Output "Managed shortcut is current: $destination"
    exit 0
}
exit 1
