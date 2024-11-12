param (
    [string]$CompanyName = '', 
    [string]$VPNAddress = '', 
    [string]$DNSSuffix = '', 
    [switch]$UserTunnel = $, 
    [string]$CAFilter = '',
    [string]$DestPrefixes = "",
    [switch]$DeviceTask = $,
    [switch]$DetectOnly = $False,
    [switch]$Remove = $False
    )
#This script NEEDS to have the parameters set first.
<#
#install
param (
    [string]$CompanyName = 'HnR', 
    [string]$VPNAddress = 'hnrconst.fortiddns.com', 
    [string]$DNSSuffix = 'hnrco.com', 
    [switch]$UserTunnel = $False, 
    [string]$CAFilter = 'CN=hnrco-CA',
    [string]$DestPrefixes = "192.168.1.15/32,192.168.1.16/32",
    [switch]$DeviceTask = $True,
    [switch]$DetectOnly = $False,
    [switch]$Remove = $False
    )

#Uninstall
param (
    [string]$CompanyName = 'HnR', 
    [string]$VPNAddress = 'hnrconst.fortiddns.com', 
    [string]$DNSSuffix = 'hnrco.com', 
    [switch]$UserTunnel = $False, 
    [string]$CAFilter = 'CN=hnrco-CA',
    [string]$DestPrefixes = "192.168.1.15/32,192.168.1.16/32",
    [switch]$DeviceTask = $True,
    [switch]$DetectOnly = $False,
    [switch]$Remove = $True
    )
#Detect
param (
    [string]$CompanyName = 'HnR', 
    [string]$VPNAddress = 'hnrconst.fortiddns.com', 
    [string]$DNSSuffix = 'hnrco.com', 
    [switch]$UserTunnel = $False, 
    [string]$CAFilter = 'CN=hnrco-CA',
    [string]$DestPrefixes = "192.168.1.15/32,192.168.1.16/32",
    [switch]$DeviceTask = $True,
    [switch]$DetectOnly = $True,
    [switch]$Remove = $False
    )

#>
$LogSub = if ($DetectOnly -eq $True) {
        "Detect"
    } elseif ($Remove -eq $True) {
        "Uninstall"
    } else {"Install"}

$LogDir = "C:\admin\Installers\MachineVPN"
new-item -path $LogDir -ItemType Directory -Force
$LogFile = "$($LogDir)\Transcript_$($LogSub).log"
start-transcript -Path $LogFile -Append
$SplitDestPrefixes = @($DestPrefixes.Split(","))

    $Status = @{}

#Will have User/Machine sub'd in later
$NameBase = "$($CompanyName) VPN - {0} Tunnel"

if ($UserTunnel -eq $True) {$NameSub = 'User'} else {$NameSub = 'Machine'}
$Name = $($NameBase) -f $($NameSub)

if ($UserTunnel) {
    $EAP = New-EapConfiguration -Tls -UserCertificate
    $EAPType = "Eap"

} else {
    $EAP = New-EapConfiguration -Tls
    $EAPType = "MachineCertificate"

    $MC_EKUFilter = @("1.3.6.1.5.5.7.3.2")
    $MC_IssuerFilter = @(Get-ChildItem Cert:\LocalMachine\Root\ | Where-Object -FilterScript {$_.Subject -like "*$($CAFilter)*"})[-1]
}

$VPNServers = New-VpnServerAddress -ServerAddress $VPNAddress -FriendlyName $VPNAddress

$VPNParams = @{
    ServerAddress = $VPNAddress
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
    AllUserConnection = $(if ($UserTunnel) {$false} else {$true})
    AuthenticationMethod = $EAPType
    EncryptionLevel = "Required"
    UseWinlogonCredential = $false
    EapConfigXmlStream = $(if ($UserTunnel) {$EAP.EapConfigXmlStream} else {})
    MachineCertificateEKUFilter = $(if ($UserTunnel) {} else {$MC_EKUFilter})
    MachineCertificateIssuerFilter = $(if ($UserTunnel) {} else {$MC_IssuerFilter})
}

if (!($DetectOnly)) {
    #Remove the VPN connection before adding
    Remove-VpnConnection -Name $VPNParams.Name -AllUserConnection:$($VPNParams.AllUserConnection) -Force -ErrorAction SilentlyContinue

    if (!($Remove)) {
        $NewConn = Add-VpnConnection @VPNParams 
    }
} else {
    #write-output "Skipping removal / creation due to 'Detect Only'"
    $a = @(get-vpnconnection -name $VPNParams.Name -AllUserConnection:$($VPNParams.AllUserConnection) -ErrorAction SilentlyContinue)
    if ($a.count -gt 0) {
        $Status.VPN = $true
    } else {
        $Status.VPN = $false
    }
}
$IPSecParams = @{
    ConnectionName = $VPNParams.Name
       AuthenticationTransformConstants = "SHA256128"
       CipherTransformConstants = "AES256"
       EncryptionMethod = "AES256"
       IntegrityCheckMethod = "SHA256"
       PfsGroup = "None"
       DHGroup = "Group14"
    }
        
if (!($DetectOnly)) {
    #Set our IPSec Pararms
    if (!($Remove)) {
        Set-VpnConnectionIPsecConfiguration @IPSecParams -Force  | Out-Null
    

        #Add our Routes to each DestPrefix
        foreach ($Dest in $SplitDestPrefixes) {
            add-vpnconnectionroute -ConnectionName "$($VPNParams.Name)" -DestinationPrefix "$($Dest)" -PassThru  | Out-Null
        }
    }

} else {
    #Checking for our IPSec Config
    if ($a.IPSecCustomPolicy.AuthenticationTransformConstants -ne $IPSecParams.AuthenticationTransformConstants) {
        $Status.IPsec_AuthTransformOK = $false
    } else {
       $Status.IPsec_AuthTransformOK = $true
    }

    if ($a.IPSecCustomPolicy.CipherTransformConstants -ne $IPSecParams.CipherTransformConstants) {
        $Status.IPsec_CipherTransformOK = $false
    } else {
       $Status.IPsec_CipherTransformOK = $true
    }

    if ($a.IPSecCustomPolicy.DHGroup -ne $IPSecParams.DHGroup) {
        $Status.IPsec_DHGroupOK = $false
    } else {
       $Status.IPsec_DHGroupOK = $true
    }

    if ($a.IPSecCustomPolicy.IntegrityCheckMethod -ne $IPSecParams.IntegrityCheckMethod) {
        $Status.IPsec_IntegrityCheckMethodOK = $false
    } else {
       $Status.IPsec_IntegrityCheckMethodOK = $true
    }

    if ($a.IPSecCustomPolicy.PfsGroup -ne $IPSecParams.PfsGroup) {
        $Status.IPsec_PFSGroupOK = $false
    } else {
       $Status.IPsec_PFSGroupOK = $true
    }

    if ($a.IPSecCustomPolicy.EncryptionMethod -ne $IPSecParams.EncryptionMethod) {
        $Status.IPsec_EncryptionMethodOK = $false
    } else {
       $Status.IPsec_EncryptionMethodOK = $true
    }


    $Dests = $a.routes.DestinationPrefix | Sort-Object
    $Unmatched = $false
    foreach ($inputPrefix in $SplitDestPrefixes) {
        $Matched = $false
        foreach ($FoundDest in $Dests) {
            if ($FoundDest -match $inputPrefix) {
                $Matched = $true
            }
        
        }

        if (!($Matched)) {
            $Unmatched = $true
        }
    
    }

    if (!($Matched)) {
        
        $Status.Routes = $false
        } else {
            $Status.Routes = $true
        }
}

$TaskParams = @{
        TaskName = "$($CompanyName) VPN - Connect Device Tunnel"
        Trigger = New-ScheduledTaskTrigger -AtStartup
        Action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument ('/c rasdial "{0}"' -f $VPNParams.Name)
        Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -WakeToRun
        principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
        }

if (((!($UserTunnel)) -and ($DeviceTask)) -and (!$($DetectOnly))) {
    
    Unregister-ScheduledTask -TaskName $TaskParams.TaskName -ErrorAction SilentlyContinue -Confirm:$false | Out-Null
    if (!($Remove)) {
        Register-ScheduledTask @TaskParams | Out-Null
    }
} else {
    $TaskOK = $false
    if ($DeviceTask) {
        $FoundTask = Get-ScheduledTask -TaskName "$($TaskParams.TaskName)" -ErrorAction SilentlyContinue
        if ($FoundTask) {
            if (($FoundTask.Principal.userid -eq $TaskParams.principal.userid) -and 
                ($FoundTask.Principal.RunLevel -eq $TaskParams.principal.RunLevel)) {
                        $Status.Task_Principal = $true
                    } else {
                        $Status.Task_Principal = $false
                    }
        
        } else {
            $TaskOK = $false
        }
    
    }
    #write-output "Skipping Task Creation due to DetectOnly"
}





$NotOK = @(($Status.GetEnumerator() | Where-Object -FilterScript {$_.Value -ne $true} | Sort-Object | Select-Object -Unique))
if ($notOK.Count -gt 0) {
    $ExitCode = 1
    write-output "NOT Installed Properly"
} else {
    $ExitCode = 0
    Write-Output "Installed Properly"
}
write-output "Exit Code: $($ExitCode)"
Stop-Transcript
[Environment]::Exit($ExitCode)
