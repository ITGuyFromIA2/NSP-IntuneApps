$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Removal.config.json') -Raw | ConvertFrom-Json

function Get-DesktopTarget {
    $paths = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
    @(Get-ItemProperty -Path $paths -ErrorAction SilentlyContinue | Where-Object {
        $name = [string]$_.DisplayName
        $config.DisplayNamePatterns | Where-Object { $name -like [string]$_ }
    })
}
function Get-AppxTarget {
    $installed = @(Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue)
    @($installed | Where-Object {
        $name = [string]$_.Name
        $fullName = [string]$_.PackageFullName
        $config.AppxNamePatterns | Where-Object { $name -like [string]$_ -or $fullName -like [string]$_ }
    })
}
function Get-ProvisionedTarget {
    $provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue)
    @($provisioned | Where-Object {
        $name = [string]$_.DisplayName
        $packageName = [string]$_.PackageName
        $config.AppxNamePatterns | Where-Object { $name -like [string]$_ -or $packageName -like [string]$_ }
    })
}

foreach ($pattern in @($config.ProcessNamePatterns)) {
    Get-Process -ErrorAction SilentlyContinue | Where-Object ProcessName -Like ([string]$pattern) | Stop-Process -Force -ErrorAction SilentlyContinue
}
foreach ($package in @(Get-ProvisionedTarget)) {
    Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -AllUsers -ErrorAction Stop | Out-Null
}
foreach ($package in @(Get-AppxTarget)) {
    Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
}
foreach ($entry in @(Get-DesktopTarget)) {
    $productCode = [string]$entry.PSChildName
    if ($productCode -match '^\{[0-9A-Fa-f-]{36}\}$') {
        $process = Start-Process -FilePath "$env:SystemRoot\System32\msiexec.exe" -ArgumentList @('/x', $productCode, '/qn', '/norestart') -Wait -PassThru
    } else {
        $registeredCommand = if ($entry.QuietUninstallString) { [string]$entry.QuietUninstallString } else { [string]$entry.UninstallString }
        if ([string]::IsNullOrWhiteSpace($registeredCommand)) { throw "No uninstall command was registered for '$($entry.DisplayName)'." }
        $command = if ($entry.QuietUninstallString) { $registeredCommand } else { "$registeredCommand $([string]$config.FallbackUninstallArguments)" }
        $process = Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList @('/d', '/s', '/c', $command) -Wait -PassThru
    }
    if ($process.ExitCode -notin @(0, 1605, 1614, 3010)) { throw "Uninstall of '$($entry.DisplayName)' failed with exit code $($process.ExitCode)." }
}

Start-Sleep -Seconds 3
if (@(Get-DesktopTarget).Count -gt 0 -or @(Get-AppxTarget).Count -gt 0 -or @(Get-ProvisionedTarget).Count -gt 0) {
    throw 'One or more Dell Optimizer components remain after removal.'
}
Write-Output 'Dell Optimizer and related ExpressConnect components are absent.'
