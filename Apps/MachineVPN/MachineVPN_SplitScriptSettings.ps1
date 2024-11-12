#Begin App Variables
$VariableConfig = @{}

$VariableConfig.VPNSettings = @{}
$VariableConfig.VPNSettings.CompanyName = "HnR"
$VariableConfig.VPNSettings.VPNAddress = "contoso.fortiddns.com"
$VariableConfig.VPNSettings.DNSSuffix = "contoso.com" 
$VariableConfig.VPNSettings.UserTunnel = $false
$VariableConfig.VPNSettings.CAFilter = "CN=contoso-CA" 
$VariableConfig.VPNSettings.DestPrefixes = @("192.168.1.15/32","192.168.1.16/32") 
$VariableConfig.VPNSettings.DeviceTask = $True

$NameRepl = if(!($VariableConfig.VPNSettings.UserTunnel -eq $true)) {"Machine"} else {"User"}


$VariableConfig.DisplayName = "$($VariableConfig.VPNSettings.CompanyName) - $($NameRepl) VPN"
$VariableConfig.Description = "Configures Windows Native VPN Client for $($NameRepl) connection to $($VariableConfig.VPNSettings.CompanyName) VPN"
$VariableConfig.Publisher = "Network Systems Plus, Inc."
$VariableConfig.IsFeatured = $True

#You can choose one or more of the categories. Not sure yet what happens if you choose none
$VariableConfig.Category = @()
    #$VariableConfig.Category += "Books & Reference"
    $VariableConfig.Category += "Business"
    $VariableConfig.Category += "Computer Management"
    #$VariableConfig.Category += "Collaboration & Social"
    #$VariableConfig.Category += "Data Management"
    #$VariableConfig.Category += "Development & Design"
    #$VariableConfig.Category += "Photos & Media"
    #$VariableConfig.Category += "Productivity"
    #$VariableConfig.Category += "Other Apps"


$VariableConfig.SetupType = "PoSH"
#MAYBE make a change, and if empty then assume same as SetupType
    #$VariableConfig.Setup_installSyle = ""
    #$VariableConfig.Setup_uninstallSyle = ""
    
#Can Be: 'system' / 'user'
    $VariableConfig.InstallExperience = 'system' 
    #$VariableConfig.InstallExperience = 'user' 

#Can Be: 'allow' / 'basedOnReturnCode' / 'force' / 'suppress'
    #$VariableConfig.RestartExperience = 'allow'  
    $VariableConfig.RestartExperience = 'basedOnReturnCode'  
    #$VariableConfig.RestartExperience = 'force'  
    #$VariableConfig.RestartExperience = 'suppress'  

#Can Be: 'All' / 'x64' / 'x86'
    $VariableConfig.REQ_Architecture = "All"
    #$VariableConfig.REQ_Architecture = "x64"
    #$VariableConfig.REQ_Architecture = "x86"

#Can Be: 'w10_1607' / 'w10_1703' / 'w10_1709' / 'w10_2004' / 'w10_20H2' / 'w10_21H1' / 'w10_21H2' / 'w11_21H2' / 'w11_22H2' 
    $VariableConfig.REQ_MinWindowsRelase = "W10_1607"  

#Need to flesh out the other styles. I believe two others 'Registry' and 'MSI code'
    $VariableConfig.DetectionStyle = "Script"
    $VariableConfig.Filter_DetectScript = "Detect_*.ps1"

#Assignment collection. This holds ALL assignments
$VariableConfig.AssignmentColl = @()
    #Template for assignments
        <#
        $VariableConfig.AssignmentColl += [pscustomobject]@{
            GroupName_Include = @("GroupNameHere")
            GroupName_Exclude = @()     #Or Leave Empty
            Intent = "required"         #Can Be: 'available' / 'required' / 'uninstall'
            Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
            DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
        }
        #>

$VariableConfig.AssignmentColl += [pscustomobject]@{
    GroupName_Include = @($($MasterSettings.Assign_DeviceGroup))
    GroupName_Exclude = @()     #Or Leave Empty
    GroupOIDs_Include = @()
    GroupOIDs_Exclude = @()
    Intent = "required"         #Can Be: 'available' / 'required' / 'uninstall'
    Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
    DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
}

$VariableConfig.AssignmentColl += [pscustomobject]@{
    GroupName_Include = @($($MasterSettings.Available_PeopleGroup))
    GroupName_Exclude = @()     #Or Leave Empty
        GroupOIDs_Include = @()
    GroupOIDs_Exclude = @()
    Intent = "available"         #Can Be: 'available' / 'required' / 'uninstall'
    Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
    DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
}



$VariableConfig.PoSH = @{}
$VariableConfig.DetectScript_Filter = "Detect_*.ps1"
$VariableConfig.PoSH.Sign_SourceFilter = "*.ps1"

$VariableConfig.SetupFile_Filter = "Download*.ps1"
$VariableConfig.PoSH.UninstallFile_Filter = "Uninstall*.ps1"

$VariableCOnfig.EnforceSignature_Detection = $True
$VariableConfig.RunAs32Bit_Detection = $False

<#
$VariableConfig.PoSH.Args_String = @"
-DNSSuffix $($VariableConfig.VPNSettings.DNSSuffix) -DestPrefixes "$([string]::join(",",$VariableConfig.VPNSettings.DestPrefixes))" -VPNAddress "$($VariableConfig.VPNSettings.VPNAddress)" -DeviceTask:`$$($VariableConfig.VPNSettings.DeviceTask) -UserTunnel:`$$($VariableConfig.VPNSettings.UserTunnel) -CompanyName "$($VariableConfig.VPNSettings.CompanyName)" -CAFilter "$($VariableConfig.VPNSettings.CAFilter)"
"@
#>
$Del = @"
    -DNSSuffix $($VariableConfig.VPNSettings.DNSSuffix) 
    -DestPrefixes "$([string]::join(",",$VariableConfig.VPNSettings.DestPrefixes))" 
    -VPNAddress "$($VariableConfig.VPNSettings.VPNAddress)" 
    -DeviceTask:`$$($VariableConfig.VPNSettings.DeviceTask) 
    -UserTunnel:`$$($VariableConfig.VPNSettings.UserTunnel) 
    -CompanyName "$($VariableConfig.VPNSettings.CompanyName)" 
    -CAFilter "$($VariableConfig.VPNSettings.CAFilter)"
"@


$Params = @{}
$params.install = @"
param (
    [string]`$CompanyName = '$($VariableConfig.VPNSettings.CompanyName)', 
    [string]`$VPNAddress = '$($VariableConfig.VPNSettings.VPNAddress)', 
    [string]`$DNSSuffix = '$($VariableConfig.VPNSettings.DNSSuffix)', 
    [switch]`$UserTunnel = `$$($VariableConfig.VPNSettings.UserTunnel), 
    [string]`$CAFilter = '$($VariableConfig.VPNSettings.CAFilter)',
    [string]`$DestPrefixes = "$([string]::join(",",$VariableConfig.VPNSettings.DestPrefixes))",
    [switch]`$DeviceTask = `$$($VariableConfig.VPNSettings.DeviceTask),
    [switch]`$DetectOnly = `$False,
    [switch]`$Remove = `$False
    )
"@

$params.uninstall = @"
param (
    [string]`$CompanyName = '$($VariableConfig.VPNSettings.CompanyName)', 
    [string]`$VPNAddress = '$($VariableConfig.VPNSettings.VPNAddress)', 
    [string]`$DNSSuffix = '$($VariableConfig.VPNSettings.DNSSuffix)', 
    [switch]`$UserTunnel = `$$($VariableConfig.VPNSettings.UserTunnel), 
    [string]`$CAFilter = '$($VariableConfig.VPNSettings.CAFilter)',
    [string]`$DestPrefixes = "$([string]::join(",",$VariableConfig.VPNSettings.DestPrefixes))",
    [switch]`$DeviceTask = `$$($VariableConfig.VPNSettings.DeviceTask),
    [switch]`$DetectOnly = `$False,
    [switch]`$Remove = `$True
    )
"@


$params.detect = @"
param (
    [string]`$CompanyName = '$($VariableConfig.VPNSettings.CompanyName)', 
    [string]`$VPNAddress = '$($VariableConfig.VPNSettings.VPNAddress)', 
    [string]`$DNSSuffix = '$($VariableConfig.VPNSettings.DNSSuffix)', 
    [switch]`$UserTunnel = `$$($VariableConfig.VPNSettings.UserTunnel), 
    [string]`$CAFilter = '$($VariableConfig.VPNSettings.CAFilter)',
    [string]`$DestPrefixes = "$([string]::join(",",$VariableConfig.VPNSettings.DestPrefixes))",
    [switch]`$DeviceTask = `$$($VariableConfig.VPNSettings.DeviceTask),
    [switch]`$DetectOnly = `$True,
    [switch]`$Remove = `$False
    )
"@

<#
$BaseScript = @"
    `$SplitDestPrefixes = @(`$DestPrefixes.Split(","))

    `$Status = @{}

`$NameBase = "`$(`$CompanyName) VPN - {0} Tunnel"

if (`$UserTunnel -eq `$True) {`$NameSub = 'User'} else {`$NameSub = 'Machine'}
`$Name = `$(`$NameBase) -f `$(`$NameSub)

if (`$UserTunnel) {
    `$EAP = New-EapConfiguration -Tls -UserCertificate
    `$EAPType = "Eap"

} else {
    `$EAP = New-EapConfiguration -Tls
    `$EAPType = "MachineCertificate"

    `$MC_EKUFilter = @("1.3.6.1.5.5.7.3.2")
    `$MC_IssuerFilter = @(Get-ChildItem Cert:\LocalMachine\Root\ | Where-Object -FilterScript {`$_.Subject -like "*`$(`$CAFilter)*"})[-1]
}

`$VPNServers = New-VpnServerAddress -ServerAddress `$VPNAddress -FriendlyName `$VPNAddress

`$VPNParams = @{
    ServerAddress = `$VPNAddress
    TunnelType = "Ikev2"
    
    Name = `$Name
    RememberCredential = `$False
    Force = `$False
    PassThru = `$False
    ServerList = `$VPNServers

    DNSSuffix  = `$DNSSuffix
    IdleDisconnectSeconds = 300
    ThrottleLimit = 0
    SplitTunneling = `$true
    AllUserConnection = `$(if (`$UserTunnel) {`$false} else {`$true})
    AuthenticationMethod = `$EAPType
    EncryptionLevel = "Required"
    UseWinlogonCredential = `$false
    EapConfigXmlStream = `$(if (`$UserTunnel) {`$EAP.EapConfigXmlStream} else {})
    MachineCertificateEKUFilter = `$(if (`$UserTunnel) {} else {`$MC_EKUFilter})
    MachineCertificateIssuerFilter = `$(if (`$UserTunnel) {} else {`$MC_IssuerFilter})
}

if (!(`$DetectOnly)) {
    #Remove the VPN connection before adding
    Remove-VpnConnection -Name `$VPNParams.Name -AllUserConnection:`$(`$VPNParams.AllUserConnection) -Force -ErrorAction SilentlyContinue

    if (!(`$Remove)) {
        `$NewConn = Add-VpnConnection @VPNParams 
    }
} else {
    #write-output "Skipping removal / creation due to 'Detect Only'"
    `$a = @(get-vpnconnection -name `$VPNParams.Name -AllUserConnection:`$(`$VPNParams.AllUserConnection) -ErrorAction SilentlyContinue)
    if (`$a.count -gt 0) {
        `$Status.VPN = `$true
    } else {
        `$Status.VPN = `$false
    }
}
`$IPSecParams = @{
    ConnectionName = `$VPNParams.Name
       AuthenticationTransformConstants = "SHA256128"
       CipherTransformConstants = "AES256"
       EncryptionMethod = "AES256"
       IntegrityCheckMethod = "SHA256"
       PfsGroup = "None"
       DHGroup = "Group14"
    }
        
if (!(`$DetectOnly)) {
    #Set our IPSec Pararms
    if (!(`$Remove)) {
        Set-VpnConnectionIPsecConfiguration @IPSecParams -Force  | Out-Null
    

        #Add our Routes to each DestPrefix
        foreach (`$Dest in `$SplitDestPrefixes) {
            add-vpnconnectionroute -ConnectionName "`$(`$VPNParams.Name)" -DestinationPrefix "`$(`$Dest)" -PassThru  | Out-Null
        }
    }

} else {
    #Checking for our IPSec Config
    if (`$a.IPSecCustomPolicy.AuthenticationTransformConstants -ne `$IPSecParams.AuthenticationTransformConstants) {
        `$Status.IPsec_AuthTransformOK = `$false
    } else {
       `$Status.IPsec_AuthTransformOK = `$true
    }

    if (`$a.IPSecCustomPolicy.CipherTransformConstants -ne `$IPSecParams.CipherTransformConstants) {
        `$Status.IPsec_CipherTransformOK = `$false
    } else {
       `$Status.IPsec_CipherTransformOK = `$true
    }

    if (`$a.IPSecCustomPolicy.DHGroup -ne `$IPSecParams.DHGroup) {
        `$Status.IPsec_DHGroupOK = `$false
    } else {
       `$Status.IPsec_DHGroupOK = `$true
    }

    if (`$a.IPSecCustomPolicy.IntegrityCheckMethod -ne `$IPSecParams.IntegrityCheckMethod) {
        `$Status.IPsec_IntegrityCheckMethodOK = `$false
    } else {
       `$Status.IPsec_IntegrityCheckMethodOK = `$true
    }

    if (`$a.IPSecCustomPolicy.PfsGroup -ne `$IPSecParams.PfsGroup) {
        `$Status.IPsec_PFSGroupOK = `$false
    } else {
       `$Status.IPsec_PFSGroupOK = `$true
    }

    if (`$a.IPSecCustomPolicy.EncryptionMethod -ne `$IPSecParams.EncryptionMethod) {
        `$Status.IPsec_EncryptionMethodOK = `$false
    } else {
       `$Status.IPsec_EncryptionMethodOK = `$true
    }


    `$Dests = `$a.routes.DestinationPrefix | Sort-Object
    `$Unmatched = `$false
    foreach (`$inputPrefix in `$SplitDestPrefixes) {
        `$Matched = `$false
        foreach (`$FoundDest in `$Dests) {
            if (`$FoundDest -match `$inputPrefix) {
                `$Matched = `$true
            }
        
        }

        if (!(`$Matched)) {
            `$Unmatched = `$true
        }
    
    }

    if (!(`$Matched)) {
        
        `$Status.Routes = `$false
        } else {
            `$Status.Routes = `$true
        }
}

`$TaskParams = @{
        TaskName = "`$(`$CompanyName) VPN - Connect Device Tunnel"
        Trigger = New-ScheduledTaskTrigger -AtStartup
        Action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument ('/c rasdial "{0}"' -f `$VPNParams.Name)
        Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -WakeToRun
        principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
        }

if (((!(`$UserTunnel)) -and (`$DeviceTask)) -and (!`$(`$DetectOnly))) {
    
    Unregister-ScheduledTask -TaskName `$TaskParams.TaskName -ErrorAction SilentlyContinue -Confirm:`$false | Out-Null
    if (!(`$Remove)) {
        Register-ScheduledTask @TaskParams | Out-Null
    }
} else {
    `$TaskOK = `$false
    if (`$DeviceTask) {
        `$FoundTask = Get-ScheduledTask -TaskName "`$(`$TaskParams.TaskName)" -ErrorAction SilentlyContinue
        if (`$FoundTask) {
            if ((`$FoundTask.Principal.userid -eq `$TaskParams.principal.userid) -and `
                (`$FoundTask.Principal.RunLevel -eq `$TaskParams.principal.RunLevel)) {
                        `$Status.Task_Principal = `$true
                    } else {
                        `$Status.Task_Principal = `$false
                    }
        
        } else {
            `$TaskOK = `$false
        }
    
    }
    #write-output "Skipping Task Creation due to DetectOnly"
}





`$NotOK = @((`$Status.GetEnumerator() | Where-Object -FilterScript {`$_.Value -ne `$true} | Sort-Object | Select-Object -Unique))
if (`$notOK.Count -gt 0) {
    `$ExitCode = 1
    write-output "NOT Installed Properly"
} else {
    `$ExitCode = 0
    Write-Output "Installed Properly"
}
[Environment]::Exit(`$ExitCode)
"@
#>

$BaseScript = get-content -path "$($TempBase)\VPN_BaseScript.ps1"

set-content -Path "$($TempBase)\Source\DownloadInstall_MachineVPN.ps1" -Value $($Params.install) -Force
$BaseScript | add-content -Path "$($TempBase)\Source\DownloadInstall_MachineVPN.ps1"


set-content -Path "$($TempBase)\Source\Uninstall_MachineVPN.ps1" -Value $($Params.uninstall) -Force
$BaseScript | add-content -Path 

set-content -Path "$($TempBase)\Detect\Detect_MachineVPN.ps1" -Value $($Params.detect) -Force
$BaseScript | add-content -Path 