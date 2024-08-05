$NameBase = "HR VPN - Custom"
$Address = "hnrconst.fortiddns.com"
$DNSSuffix = 'hnrco.com'
#$UserorMach = "User"
$UserorMach = "Machine"

$Name = "$($NameBase) $($UserorMach)"

$IssuingCAFilter = "*CN=hnrco-CA*"

New-EapConfiguration -Tls


if ($UserorMach -eq "User") {
    $EAP = New-EapConfiguration -Tls -UserCertificate
    $EAPType = "Eap"

} else {
    $EAP = New-EapConfiguration -Tls
    #$eap.EapConfigXmlStream.EapHostConfig.Config.Eap
    $EAPType = "Eap"

    $MC_EKUFilter = @("1.3.6.1.5.5.7.3.2")
    $MC_IssuerFilter = Get-ChildItem Cert:\LocalMachine\Root\ | Where-Object -FilterScript {$_.Subject -like "$($IssuingCAFilter)"}
}
<#
$EAP.EapConfigXmlStream

$EAP.EapConfigXmlStream.EapHostConfig.Config.Eap.Type
$EAP.EapConfigXmlStream.EapHostConfig.Config.Eap.EapType
#>
$VPNServers = New-VpnServerAddress -ServerAddress $Address -FriendlyName $Address

$VPNParams = @{
    ServerAddress = $Address
    TunnelType = "Ikev2"
    
    Name = $Name
    RememberCredential = $False
    Force = $False
    PassThru = $False
    ServerList = $VPNServers

    DNSSuffix  = $DNSSuffix
    IdleDisconnectSeconds = 300
   ThrottleLimit = 0
   SplitTunneling = $true
   AllUserConnection = $(if ($UserorMach -eq "User") {$false} else {$true})
   AuthenticationMethod = $EAPType
   EncryptionLevel = "Required"
   UseWinlogonCredential = $false
   EapConfigXmlStream = $(if ($UserorMach -eq "User") {$EAP.EapConfigXmlStream} else {})
   MachineCertificateEKUFilter = $(if ($UserorMach -eq "User") {} else {$MC_EKUFilter})
    MachineCertificateIssuerFilter = $(if ($UserorMach -eq "User") {} else {$MC_IssuerFilter})
}

Remove-VpnConnection -Name $VPNParams.Name -AllUserConnection
$NewConn = Add-VpnConnection @VPNParams

$IPSecParams = @{
    ConnectionName = $VPNParams.Name
       AuthenticationTransformConstants = "SHA256128"
       CipherTransformConstants = "AES256"
       EncryptionMethod = "AES256"
       IntegrityCheckMethod = "SHA256"
       PfsGroup = "None"
       DHGroup = "Group14"
    }

Set-VpnConnectionIPsecConfiguration @IPSecParams
