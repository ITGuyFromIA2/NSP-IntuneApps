function Import-NSPBootstrap {
    [CmdletBinding()]
    param(
        [switch]$InstallIfMissing
    )

    $available = Get-Module -ListAvailable -Name 'NSP.Bootstrap' |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if (-not $available -and $InstallIfMissing) {
        Write-Host "NSP.Bootstrap is not installed. Installing for the current user..." -ForegroundColor Yellow
        Install-Module -Name 'NSP.Bootstrap' -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        $available = Get-Module -ListAvailable -Name 'NSP.Bootstrap' |
            Sort-Object Version -Descending |
            Select-Object -First 1
    }

    if (-not $available) {
        throw "NSP.Bootstrap is required for this operation. Install it with: Install-Module NSP.Bootstrap -Scope CurrentUser"
    }

    Import-Module $available.Path -Force -ErrorAction Stop
    Get-Module -Name 'NSP.Bootstrap'
}
