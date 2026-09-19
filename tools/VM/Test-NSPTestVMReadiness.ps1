[CmdletBinding()]
param([string]$OutputPath)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
if (-not $OutputPath) {
    $resultRoot = Join-Path $repoRoot 'Config\Local\VMResults'
    New-Item -ItemType Directory -Path $resultRoot -Force | Out-Null
    $OutputPath = Join-Path $resultRoot ("Readiness-{0}.json" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
}

$os = Get-CimInstance -ClassName Win32_OperatingSystem
$computer = Get-CimInstance -ClassName Win32_ComputerSystem
$isAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
$defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
$snapshot = [pscustomobject][ordered]@{
    CapturedAtUtc            = (Get-Date).ToUniversalTime().ToString('o')
    ComputerName             = $env:COMPUTERNAME
    Manufacturer             = $computer.Manufacturer
    Model                    = $computer.Model
    OperatingSystem          = $os.Caption
    OperatingSystemVersion   = $os.Version
    BuildNumber              = $os.BuildNumber
    PowerShellVersion        = $PSVersionTable.PSVersion.ToString()
    WindowsPowerShell51      = [bool](Get-Command powershell.exe -ErrorAction SilentlyContinue)
    PowerShell7              = [bool](Get-Command pwsh.exe -ErrorAction SilentlyContinue)
    Git                      = [bool](Get-Command git.exe -ErrorAction SilentlyContinue)
    IsAdministrator          = $isAdministrator
    PendingReboot            = [bool](
        (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') -or
        (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
    )
    DefenderAvailable        = [bool]$defender
    DefenderAntivirusEnabled = if ($defender) { [bool]$defender.AntivirusEnabled } else { $null }
    DefenderRealTimeEnabled  = if ($defender) { [bool]$defender.RealTimeProtectionEnabled } else { $null }
    DefenderTamperProtected  = if ($defender) { [bool]$defender.IsTamperProtected } else { $null }
    AutoItInstalled          = [bool](Get-Command AutoIt3.exe -ErrorAction SilentlyContinue)
    AutoItCompilerInstalled  = [bool](Get-Command Aut2Exe.exe -ErrorAction SilentlyContinue)
    AutoHotkeyInstalled      = [bool](Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue)
    ParallelsClientInstalled = [bool](@(
        Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue
        Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue
    ) | Where-Object DisplayName -Like '*Parallels*Client*')
}

$parent = Split-Path -Path $OutputPath -Parent
if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$snapshot | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
$snapshot
Write-Host "Readiness snapshot: $OutputPath" -ForegroundColor Cyan

