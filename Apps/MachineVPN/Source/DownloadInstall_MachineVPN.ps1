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

    $SplitDestPrefixes = @($DestPrefixes.Split(","))

    $Status = @{}

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
    $MC_IssuerFilter = Get-ChildItem Cert:\LocalMachine\Root\ | Where-Object -FilterScript {$_.Subject -like "*$($CAFilter)*"}
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
[Environment]::Exit($ExitCode)

# SIG # Begin signature block
# MIIbyQYJKoZIhvcNAQcCoIIbujCCG7YCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiFI+NQzOCSqLwWxQLMzUpbZ+
# r0egghY1MIIDKDCCAhCgAwIBAgIQXp50wvfoo4ZEs021q1HySzANBgkqhkiG9w0B
# AQsFADAlMSMwIQYDVQQDDBpOZXR3b3JrIFN5c3RlbXMgUGx1cywgSW5jLjAeFw0y
# NDA2MDYxNzM0MTlaFw0yNTA2MDYxNzU0MTlaMCUxIzAhBgNVBAMMGk5ldHdvcmsg
# U3lzdGVtcyBQbHVzLCBJbmMuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEA3mXzLK0fHvD10CxXTACZBTJtEenpjsFi8QS28EH7WMOeUmYsFZVOQWiltVbY
# eamfy5hrYMYDurS0WlOPcC/GV1UiyGyz/06awzxt7K6GS8LcxZVRwVVZvD109yJp
# SFaus4nHRHeaXUvtZDEGJF9o13/7Y4FT3B+7uNHlNEJyZi/kSMmItX4ki6cdBtm1
# ayQF52RmvgJlyk6ZNE6romF6pxaJaE15Js5OGp2X6BmULeltIwznmG5q/rjJfvFf
# TJ7iLpcBtyJ0D09sj2dts/aIyl0aEJOxFCUKlAeWgv3UY12dqXnltAab9kHZPT4x
# DJuhaSt0/75Onulld1YVaWqIQQIDAQABo1QwUjAOBgNVHQ8BAf8EBAMCB4AwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQUAFVzB2dA
# Xn7UrxdfREYDpNPyGJswDQYJKoZIhvcNAQELBQADggEBAL0KVv0QLdNIhVydcvaO
# Mjk+8c3sMVhocMVagj2aIoP+1FVKkxgPkCe25z4yUkaz4+hx7yrDRuRHmQswTS64
# fkk/YYiCZ+Q8q7gR9/VReQEweatliceflcz1W0HEF186roVjku0ri2z98UdxqgPE
# wCrfsv8aTueAEolq2FL9qqFZb8wEaHPfUvO8N2EEcQ4wRCYiIgaxyBoPgPrIzZYk
# Dmit3yxWdopNgxQBFUIm8wYvwryfkvBBJUUJj4hZBPDmUHAwstnShlWH4LZV9c/u
# E/eQKoBywWWtR1TQPNNFplkivZ1ink/XI+u0eew/xbEm4xrzHrDV0zpHSRQ6cHla
# kiMwggWNMIIEdaADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUA
# MGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
# EHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQg
# Um9vdCBDQTAeFw0yMjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqcl
# LskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YF
# PFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceIt
# DBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZX
# V59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1
# ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2Tox
# RJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdp
# ekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF
# 30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9
# t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQ
# UOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXk
# aS+YHS312amyHeUbAgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1Ud
# DgQWBBTs1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEt
# UYunpyGd823IDzAOBgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAw
# DQYJKoZIhvcNAQEMBQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyF
# XqkauyL4hxppVCLtpIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76
# LVbP+fT3rDB6mouyXtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8L
# punyNDzs9wPHh6jSTEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2
# CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si
# /xK4VC0nftg62fC2h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQwggauMIIElqADAgEC
# AhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMw
# MDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0
# MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la
# 9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4r
# gISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/Z
# kIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y
# 3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6ws
# OeKlSNbwsDETqVcplicu9Yemj052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz
# 9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4
# xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB
# 7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhK
# WD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8e
# CXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQAB
# o4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3Mp
# dpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYD
# VR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGsw
# aTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUF
# BzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVk
# Um9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeB
# DAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQi
# AX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+Vc
# W9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/
# q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6Wvep
# ELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoar
# CkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJS
# pzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrk
# nq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f5
# 6PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2Bn
# FqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ
# 8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW
# +6kvRBVK5xMOHds3OBqhK/bt1nz8MIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/
# X+VhFjANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5
# NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAx
# MzIzNTk1OVowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMu
# MSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOX
# ejsqnGfcYhVYwamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbj
# aedp/lvD1isgHMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7
# ReoNYWyd/nFexAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PB
# uOZSlbVH13gpOWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu
# 6QXuqvYk9R28mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769Sg
# LDSb495uZBkHNwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUG
# FOpiCBPTaR58ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZc
# ClhMAD6FaXXHg2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmh
# cbJsca8+uG+W1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U2
# 0clfCKRwo+wK8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qD
# y0B7AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAW
# BgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglg
# hkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0O
# BBYEFKW27xPn783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6
# Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEy
# NTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZT
# SEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6g
# qbWYF7xwjU+KPGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s
# 1+FgnCvt7T1IjrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0q
# BXqEKZi2V3mP2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp4
# 4pMadqJpddNQ5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6w
# QSbd3lqXTzON1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4Z
# iQPq1JE3701S88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wn
# LEHQmjNKqDbUuXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5Adza
# ROY63jg7B145WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy
# 0tg6uLFGhmu6F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDA
# dwrUAuBcYLso/zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2Xl
# G3O2mflrLAZG70Ee8PBf4NvZrZCARK+AEEGKMYIE/jCCBPoCAQEwOTAlMSMwIQYD
# VQQDDBpOZXR3b3JrIFN5c3RlbXMgUGx1cywgSW5jLgIQXp50wvfoo4ZEs021q1Hy
# SzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAjBgkqhkiG9w0BCQQxFgQUIRAw0fi8PXz94KGkSrACbf9wMjswDQYJKoZIhvcN
# AQEBBQAEggEAFNzWm8b8vjtVlAXtZobBNP05dgaPvSkCPYq3hUGuW2hEY0WoISlK
# vlTMmLX7mbs7rI5uLg6p3m/9awyKi4widrUVN4dR3n8Vh4JD9+1+/esx53AdtDuD
# zTBziC55g8/bC5QNn3JLApKJgesvqw2O8P0la7hl7kFtocU3Ypiw4oXGMJyHG+cL
# jT4VO5dKKD+I3EYBkx4jkkXu2G0gX97Gknfc++34f7+tiT0lhQyTbNg6ZHgrMQhr
# HSH8vrp4HdNvmXE1guTh+xMTHmDkbsAbiAXPSUzUxtPU2S30yxPn4lmTecHaoyGp
# fS595okXdLckML1+FCirfjSVMMx4wvmkz6GCAyAwggMcBgkqhkiG9w0BCQYxggMN
# MIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0ECEAVEr/OUnQg5pr/bP1/lYRYwDQYJYIZIAWUDBAIBBQCg
# aTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yNDA4
# MDUxNzM1MTdaMC8GCSqGSIb3DQEJBDEiBCBC9CKyyQfvqyDtP8+l3eP0NdiQEdZf
# lA54QCOBrbiIUDANBgkqhkiG9w0BAQEFAASCAgBIVWy2Umes0qA36MqxlwM9Y99r
# RLyK3iNSzoicdwNgP+ctQDaANDx50wJSav8MPPKJVd7kh82lCjnVtTsRIazlSmvg
# YMCNpFf/qTcezCEX3q0wd0d2Zu512AcGcRzT4DR6ywK7RRkSIMgLs8CHu8rSrRkF
# CM4fSQcylD10kmSj4InGPzyXB+8qHpqaD9jGVRamJ5v99X2UGajkFPiZ1P2+dqcC
# 8Fqy89L14O+Nz0j1wwG+tg9U990jKDlSg4pJxgkyoo8gBpVdqhkp4qvDHRsUfBLE
# mXZEoigPWCR9KRBKXLFEHzl/0dSUyhPxzQBFN9Rc9gnXJO6D4fjcVkDU6GXH3Sby
# Qdh6ZzpTPhH+PWKhaD2lJA20lTtHu1O9Bf1UTezpAoxFMr2vi+LD7+466+3+NUHm
# gjsMWmr7UC7uUmHoAGW7hvkw8cxRtmTjZZ4vuMERlWaGZ5+LaNxVl1W++l6OnkT4
# 3V+Gtbu+XN3cgnw5hV2WqYXSRKtef+WZal1W5iNIMVge29IGpuO4WTvY26IiZXCl
# kJyDDXUWurbUh9eBlWkrnVCuby36kG4fSJV21hqncgFME57zBAkymBCGcD86gFc7
# +c2dqjPaXi5DZ++xIbDF5HkmJc8/76GecAAHfw0W5ItiQNCoKHMR8Q0c9rDhOcb1
# dEvya7ZhApRt7QJVaQ==
# SIG # End signature block
