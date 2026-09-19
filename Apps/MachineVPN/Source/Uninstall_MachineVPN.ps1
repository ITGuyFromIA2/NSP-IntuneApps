[CmdletBinding()]
param(
    [string]$CompanyName = 'Contoso',
    [string]$VPNAddress = 'vpn.contoso.invalid',
    [string]$DNSSuffix = 'contoso.invalid',
    [switch]$UserTunnel = $false,
    [string]$CAFilter = '',
    [string]$DestPrefixes = '',
    [switch]$DeviceTask = $true
)

$installScript = Join-Path $PSScriptRoot 'DownloadInstall_MachineVPN.ps1'
& $installScript -CompanyName $CompanyName -VPNAddress $VPNAddress -DNSSuffix $DNSSuffix -UserTunnel:$UserTunnel -CAFilter $CAFilter -DestPrefixes $DestPrefixes -DeviceTask:$DeviceTask -Remove
exit $LASTEXITCODE
