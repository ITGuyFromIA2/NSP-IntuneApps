﻿#Handling various AppX and AppXProvisioned items here
    $List_AppXToRemove = @("*DellOptimizer*")

    #Get list of all provisioned apps
        $AllAppX_Provisioned = Get-AppxProvisionedPackage -Online 
        $Matched_Provisioned = @()
#Loop through all provisioned, matching the 'List_AppXToRemove'
    foreach ($Provisioned in $AllAppX_Provisioned) {
        if (($List_AppXToRemove | %{$Provisioned.PackageName -like $_}) -contains $true) {
            $Matched_Provisioned += $Provisioned
            Remove-AppxProvisionedPackage -Online -PackageName $Provisioned.PackageName -AllUsers -ErrorAction SilentlyContinue
        }
    }

$appX_Remove = @()
$Matched_Installed = @()

$AllAppX_Installed = Get-AppxPackage -AllUsers

foreach ($Installed in $AllAppX_Installed) {
    if (($List_AppXToRemove | %{$installed.PackageFullName -like $_}) -contains $true) {
        $Matched_Installed += $Installed
        Remove-AppxPackage -Package $Installed -AllUsers -ErrorAction SilentlyContinue
    }
}


$Timestamp = Get-Date -Format "yyyy-MM-dd_THHmmss"
$LogFile = "$env:TEMP\DellUninst_$Timestamp.log"
$ProgramList = @( "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" )
$Programs = Get-ItemProperty $ProgramList -EA 0

#List of applications to remove, as seen in Add/Remove Programs (use wildcards)
    #$UninstallAppList = @("Dell Optimizer*","*Dell Digital Delivery*")
    $UninstallAppList = @("Dell*Optimizer*","*Express*Connect*")

#List of possible running procecsses associated with the above
    $RunningProcessList = @("DellOptimizer.exe")

$App = @()        #Will have 'MSI' apps in it
 $App_Whole = @()
$ManualApp = @()  #Will have 'other' types in it (Installshield)

$Program = ($Programs | where-Object -Property Displayname -Like "*Dell*")[0]
foreach ($Program in $Programs) {
    if ((($UninstallAppList | %{($Program.DisplayName -like $_)}) -contains $true)) {
        if (($Program.UninstallString -like "*msiexec*")) {
        $App_Whole += $Program
            $App += $Program.PSChildName
            $App_Whole += $Program
        } else {
            $ManualApp += $Program
        }
    }
}

Get-Process | Where-Object { $_.ProcessName -in $RunningProcessList } | Stop-Process -Force

foreach ($ManApp in $ManualApp) {
    cmd /c  "$(($ManApp).uninstallString) /silent"
}

foreach ($a in $App) {

    $Params = @(
        "/qn"
        "/norestart"
        "/X"
        "$a"
        "/L*V ""$LogFile"""
    )

    Start-Process "msiexec.exe" -ArgumentList $Params -Wait -NoNewWindow

}

# SIG # Begin signature block
# MIIbyQYJKoZIhvcNAQcCoIIbujCCG7YCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjkgDJfEvvlQNE7BwsP/3VaaI
# akygghY1MIIDKDCCAhCgAwIBAgIQXp50wvfoo4ZEs021q1HySzANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUs4DtXzg/i6IYvnCe383a9NWNepYwDQYJKoZIhvcN
# AQEBBQAEggEAtAagZ+oJNilhUBaeKpB6EQKVgbKrGIfunNgqizdl5dEWw/yUyJv1
# 9u2D7jO3x780WAMfR7A8927QdRN5DJQpJ0wTxgGsWzDMqygm3xAvGOc+GeEPlYQF
# MtGgnaRvigMDJifjJXcUYvwKkdzP/EHz09WhCN5DaKZrKodMn15nD/crQeZ0dcKZ
# Z4cUx+afAdm+SCSwd60CCDdCAeCNnW1Fj8Ki5o2kxbAX4OqvDd8iQuGEmzzttBwk
# /IIwqujmj9jrbjc8KvQ1X1vtkYQqwCc1I3kVDz3pQsu6Kqso0KFxVl/VU5Lhx1E3
# HTvEWkokMhRgiM/zeBpKAFSzqy5Os6gtMqGCAyAwggMcBgkqhkiG9w0BCQYxggMN
# MIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0ECEAVEr/OUnQg5pr/bP1/lYRYwDQYJYIZIAWUDBAIBBQCg
# aTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yNDA3
# MzExNDQwMDBaMC8GCSqGSIb3DQEJBDEiBCDk9p5d0MCCgOoY/vyfdMNh2I8IXZUI
# 7hzwXWGEfX9pRjANBgkqhkiG9w0BAQEFAASCAgAvUj2+5wzEO7NFD5Ip4XfSdq4O
# oa43iMg0iWhV+vcojNt3e0DHgpPAY/vaT6Fn6FVzFLwLvp7jEGPe2DTk0KQNMhai
# 8mIW3bYURELY8tLdcXTwJLW/QqMBq4WWtAGNvcLydg+wlzTYJ+ORC18Qo0XquA1f
# Aos29CVKwxUmf6and8n+NbRV8cpxngB6ERFhK2nZNvKXSCanGJW/1gRZL5GFAZEW
# Ck3IJzyK9iaDcpn9N9Ng3qb7RsQ6JS7u29/2r6u7NWhj+xMx5FbdBlL4aoVUaVY0
# WF6dI5lx7TaWhH3AUC9Mi1ZsxDdrobXWqzoCaOggrsZ93B3JZ1dFaf6AkOJgL8cc
# Ma+VBmawLYzSjSyOFp4+stbNOLnPrM6g/XEJG/S5S2KN203BF4u3YsU8Eamz5X+6
# huQ5Nf/K+LcBiUxVN5nrbjhqjIwwUu+7/Vfc0PNsfIVeMVmgD3qmua37FP0d5k7a
# oljk5SabseYVYtba2yGBTQtgK/5PKWlEUam1QU7syHEgyCm7Ve8vx0sLK0dLSgOM
# CjlWFc500iW0wpJ0jDB+1igmcG+2q/6LaHdDEotyvfqAO83jKgHoSN1YVOh/nYzg
# MYy1QXkVp1vU3b1dDRmiOtLwgwg2qTlGTYBzhL4vLLGV+xj2YK1V6r2oFJ69Fhn3
# haGRgfXe3/mZEl5weg==
# SIG # End signature block