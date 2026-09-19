$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Removal.config.json') -Raw | ConvertFrom-Json
$registryPaths = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
$desktop = @(Get-ItemProperty -Path $registryPaths -ErrorAction SilentlyContinue | Where-Object {
    $name = [string]$_.DisplayName
    $config.DisplayNamePatterns | Where-Object { $name -like [string]$_ }
})
$appx = @(Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Where-Object {
    $name = [string]$_.Name
    $fullName = [string]$_.PackageFullName
    $config.AppxNamePatterns | Where-Object { $name -like [string]$_ -or $fullName -like [string]$_ }
})
$provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object {
    $name = [string]$_.DisplayName
    $packageName = [string]$_.PackageName
    $config.AppxNamePatterns | Where-Object { $name -like [string]$_ -or $packageName -like [string]$_ }
})
if ($desktop.Count -eq 0 -and $appx.Count -eq 0 -and $provisioned.Count -eq 0) {
    Write-Output 'Dell Optimizer and related ExpressConnect components are absent.'
    exit 0
}
exit 1
