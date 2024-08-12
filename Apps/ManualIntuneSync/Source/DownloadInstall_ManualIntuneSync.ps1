$ModTask = @{
    Name = "PushLaunch"
    Path = ""
    BackupPath = "C:\Admin\Installers\ORIGINALTask - PushLaunch.xml"
}
$Shortcut_Full = "C:\users\Public\Desktop\Manual Sync Intune.lnk"


$ModTask.Path = (Get-ScheduledTask -TaskName $ModTask.Name).taskpath

if (!(test-path -Path $ModTask.backuppath)) {

    set-content -path $modTask.BackupPath -Value (Export-ScheduledTask -TaskName $ModTask.Name -TaskPath $ModTask.Path) -Force
}
$Existing = [xml](Export-ScheduledTask  -TaskName $ModTask.Name -TaskPath $ModTask.Path)


$modify = $Existing


$element1 = "EventTrigger"
$element2 = "Enabled"
$element3 = "Subscription"


$EventTrigger_node = $Modify.CreateElement($element1, $Modify.task.NamespaceURI)
#$EventTrigger_node.OuterXml
#$EventTrigger_node.RemoveAttribute("xmlns")

#$EventTrigger_node.InnerXml = @"
#<Enabled>true</Enabled>
#<Subscription><QueryList><Query Id="0" Path="Application"><Select Path="Application">*[System[Provider[@Name='Microsoft Intune Management Extension'] and EventID=1337]]</Select></Query></QueryList></Subscription>
#"@


$Enabled_element = $Modify.CreateElement($element2, $Modify.task.NamespaceURI)
    $EventTrigger_node.AppendChild($Enabled_element)

    $EventTrigger_node.Enabled = "true"

$Subscription_element = $Modify.CreateElement($element3, $Modify.task.NamespaceURI)
    $EventTrigger_node.AppendChild($Subscription_element)

    #$EventTrigger_node.Subscription

#    $EventTrigger_node.Subscription =  @"
#&lt;QueryList&gt;&lt;Query Id="0" Path="Application"&gt;&lt;Select Path="Application"&gt;*[System[Provider[@Name='Microsoft Intune Management Extension'] and EventID=1337]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;
#"@


$EventTrigger_node.Subscription = @"
<QueryList><Query Id="0" Path="Application"><Select Path="Application">*[System[Provider[@Name='Microsoft Intune Management Extension'] and EventID=1337]]</Select></Query></QueryList>
"@

$Modify.Task.Triggers.AppendChild($EventTrigger_node)

Register-ScheduledTask -Xml $modify.OuterXml -TaskName $($ModTask.Name) -TaskPath $($ModTask.Path) -Force




$ScriptFile = @{
FullDest = "C:\Admin\installers\ManualIntuneSync.ps1"
Content = @"
$Servname = "IntuneManagementExtension";
Stop-Service -Name $Servname;
Start-Service -Name $Servname;
Write-EventLog -LogName Application -Source "Microsoft Intune Management Extension" -EventId 1337 -Message "Perform Manual Sync"
"@
}

set-content -Path $ScriptFile.fullDest -Value $ScriptFile.content




$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($Shortcut_Full)
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Shortcut.Arguments = "-executionpolicy bypass -WindowStyle hidden -File ""$($ScriptFile.FullDest)"""
#$Shortcut.IconLocation = 

$Shortcut.Save()


$bytes = [System.IO.File]::ReadAllBytes($Shortcut_Full)
$bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
[System.IO.File]::WriteAllBytes($Shortcut_Full, $bytes)



$FinalCheck = @{}
$Finddd = @"
EventID=1337]]
"@

if ((Get-ScheduledTask -TaskName $ModTask.Name).triggers[-1].subscription.tostring() -match $Finddd) {
    $FinalCheck.Task = $true
} else {
    $FinalCheck.Task = $false
}
if (Test-Path $Shortcut_Full) {
    $FinalCheck.Shortcut = $true
} else {
    $FinalCheck.Shortcut = $false
}

if ($($FinalCheck.Task) -and $($FinalCheck.Shortcut)) {
$Exit = 0
Write-Output "Task and Shortcut Configured Properly"
} elseif ($($FinalCheck.Task) -and !$($FinalCheck.Shortcut)) {
$Exit = 1
Write-Output "Shortcut NOT configured Properly"
} elseif (!$($FinalCheck.Task) -and $($FinalCheck.Shortcut)) {
$Exit = 2
Write-Output "Task NOT Configured Properly"
} else {
$Exit = 3
Write-Output "BOTH Task and Shortcut NOT Configured Properly"
}

[environment]::ExitCode($Exit)
# SIG # Begin signature block
# MIIbxwYJKoZIhvcNAQcCoIIbuDCCG7QCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQcq3Nds/dV75XEHns2aH/AOP
# gxWgghYzMIIDKDCCAhCgAwIBAgIQJseON1ho4LBAqL8IVIFIPTANBgkqhkiG9w0B
# AQsFADAlMSMwIQYDVQQDDBpOZXR3b3JrIFN5c3RlbXMgUGx1cywgSW5jLjAeFw0y
# MzA2MDUxNTUwMDhaFw0yNDA2MDUxNjEwMDhaMCUxIzAhBgNVBAMMGk5ldHdvcmsg
# U3lzdGVtcyBQbHVzLCBJbmMuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEArmC6Gkf7+jKHa5OeswUDyI0QAJNd9isuaZsBK/BybDinb7fcTC6xCGlx9hRp
# 4xZXKbx861cjI+xl1/X6iiuJVvF2ZRVsN0eo16VK3FdpiW3cJnw9yHqr9fsn+6K+
# 6w+CrNIKB6WSz6H+ZoXp13oUSFZu3YvsfwUQeDglV0fn7naA3QpTliCr/Q12S4v1
# terdTQw4U/eMghxVwxX7oUEt2r7VyvUZH/I+8DlsaRx1u1Igg7HaYpKZ8wuIrvyd
# 99NzeNsj7bM5enOAi415TlFn3HUVScTWW36ruuqP3q8X5lgkhKYkZfUSIYB0W3H9
# RLP1Id5++/PXCkAwhHc/2BXYlQIDAQABo1QwUjAOBgNVHQ8BAf8EBAMCB4AwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQUMg3fMKEp
# mQY39R4pVxfnQK40r2UwDQYJKoZIhvcNAQELBQADggEBAJ+wcz5s/Mqab37TaAbJ
# lc2+ouBbn4cZcAiz7JyCi/Dxnn+bLgnsEF7p7v1owHrEUaQ5a3jLeZ4CiM9qeeTK
# K7GqEmJVC2K3Zyg6sZHvUrTDtpDsFZqVOZId5MFB1Z3FDI+TFE90Ys+8iHOFr/8d
# xFvQ8vqqKd9LHZei03IEKMDzKFAOUhH3afPpw/enkIPpoP0G1jatnCLrPZhbvaqs
# r8jDy5tOP5MUszZLjpxw7/wEuf7fSwBlOSiXuloORNqtpkKQe8v6+l56sZyP253e
# yFkn6ZhdUmvMQC3aKTah6KiXKm89WICa1habU5ee1UGH/jvzOY8nmTzs48AHUVWA
# d94wggWNMIIEdaADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUA
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
# +6kvRBVK5xMOHds3OBqhK/bt1nz8MIIGwDCCBKigAwIBAgIQDE1pckuU+jwqSj0p
# B4A9WjANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5
# NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIyMDkyMTAwMDAwMFoXDTMzMTEy
# MTIzNTk1OVowRjELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSQwIgYD
# VQQDExtEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMiAtIDIwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDP7KUmOsap8mu7jcENmtuh6BSFdDMaJqzQHFUeHjZt
# vJJVDGH0nQl3PRWWCC9rZKT9BoMW15GSOBwxApb7crGXOlWvM+xhiummKNuQY1y9
# iVPgOi2Mh0KuJqTku3h4uXoW4VbGwLpkU7sqFudQSLuIaQyIxvG+4C99O7HKU41A
# gx7ny3JJKB5MgB6FVueF7fJhvKo6B332q27lZt3iXPUv7Y3UTZWEaOOAy2p50dIQ
# kUYp6z4m8rSMzUy5Zsi7qlA4DeWMlF0ZWr/1e0BubxaompyVR4aFeT4MXmaMGgok
# vpyq0py2909ueMQoP6McD1AGN7oI2TWmtR7aeFgdOej4TJEQln5N4d3CraV++C0b
# H+wrRhijGfY59/XBT3EuiQMRoku7mL/6T+R7Nu8GRORV/zbq5Xwx5/PCUsTmFnta
# fqUlc9vAapkhLWPlWfVNL5AfJ7fSqxTlOGaHUQhr+1NDOdBk+lbP4PQK5hRtZHi7
# mP2Uw3Mh8y/CLiDXgazT8QfU4b3ZXUtuMZQpi+ZBpGWUwFjl5S4pkKa3YWT62SBs
# GFFguqaBDwklU/G/O+mrBw5qBzliGcnWhX8T2Y15z2LF7OF7ucxnEweawXjtxojI
# sG4yeccLWYONxu71LHx7jstkifGxxLjnU15fVdJ9GSlZA076XepFcxyEftfO4tQ6
# dwIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZI
# AYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQW
# BBRiit7QYfyPMRTtlwvNPSqUFN9SnDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8v
# Y3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2
# VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hB
# MjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQBVqioa80bz
# eFc3MPx140/WhSPx/PmVOZsl5vdyipjDd9Rk/BX7NsJJUSx4iGNVCUY5APxp1Mqb
# KfujP8DJAJsTHbCYidx48s18hc1Tna9i4mFmoxQqRYdKmEIrUPwbtZ4IMAn65C3X
# CYl5+QnmiM59G7hqopvBU2AJ6KO4ndetHxy47JhB8PYOgPvk/9+dEKfrALpfSo8a
# OlK06r8JSRU1NlmaD1TSsht/fl4JrXZUinRtytIFZyt26/+YsiaVOBmIRBTlClmi
# a+ciPkQh0j8cwJvtfEiy2JIMkU88ZpSvXQJT657inuTTH4YBZJwAwuladHUNPeF5
# iL8cAZfJGSOA1zZaX5YWsWMMxkZAO85dNdRZPkOaGK7DycvD+5sTX2q1x+DzBcNZ
# 3ydiK95ByVO5/zQQZ/YmMph7/lxClIGUgp2sCovGSxVK05iQRWAzgOAj3vgDpPZF
# R+XOuANCR+hBNnF3rf2i6Jd0Ti7aHh2MWsgemtXC8MYiqE+bvdgcmlHEL5r2X6cn
# l7qWLoVXwGDneFZ/au/ClZpLEQLIgpzJGgV8unG1TnqZbPTontRamMifv427GFxD
# 9dAq6OJi7ngE273R+1sKqHB+8JeEeOMIA11HLGOoJTiXAdI/Otrl5fbmm9x+LMz/
# F0xNAKLY1gEOuIvu5uByVYksJxlh9ncBjDGCBP4wggT6AgEBMDkwJTEjMCEGA1UE
# AwwaTmV0d29yayBTeXN0ZW1zIFBsdXMsIEluYy4CECbHjjdYaOCwQKi/CFSBSD0w
# CQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
# IwYJKoZIhvcNAQkEMRYEFNJP9LBFF7Q+PvBIRkaC+BziYBGoMA0GCSqGSIb3DQEB
# AQUABIIBAD/2+hjp4fEUwuWrDAbhI0joFKq3OVLnxHgLEzv7WE1iqHXzXJeeJ1mA
# gZhMvgj78rZvgGrOJL7bZRWJOWhbI/x/zP/ct2SayU3A5bz7WmepglRU1aR/e1bZ
# +LDTtjm7dBZ5QFppQO8MQRCzOP5SyArnr4bnNAwnOeYKAEoGByOBXm9TrntxPB+u
# PVEQMdYG1WYQLjUMaglQJIWmZHM/beZQ2Ldp4s8MGedRx/X6T/bSDdf72jXVmDhq
# F/hZ4fHAHp7Qh2OpyGGtwfsITSFGDf9ZiP6hDn/vtooiZGjnsic/OTM+g0Z8lXcP
# mvEfPD0g0Rm2tgUyyS0zc4XVl5MremGhggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCC
# AwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4x
# OzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGlt
# ZVN0YW1waW5nIENBAhAMTWlyS5T6PCpKPSkHgD1aMA0GCWCGSAFlAwQCAQUAoGkw
# GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjMwODAy
# MTYyMjI2WjAvBgkqhkiG9w0BCQQxIgQgsdcdUkcS3jgtkUr0EcermDDDYRPA6HFK
# Ty1h4BW4zxswDQYJKoZIhvcNAQEBBQAEggIAeRYweeo9YfFIq5F9FpLTPnvbHPbU
# 6J+Cb/B8EX+w+y9ec0nWP4BpEWYeXynzRpSrYIviU9gBz3MEIyvPhAYpqZBoEJBF
# V9+//w8GmB9oSvw+8QZdUE+ZS/Utb3c4X/5Xri3lhD0istswm/WNEP/jUVGXFd2n
# BjoX9OB8KAFZlAotaLitutaw01JxLDiAVNDrwvaYYBFhDrCtOTOWut+1f52tZZ+d
# F1pDWnEHRRvS2I31DeXI7pz/ataKZ0HegcWQuZ39iBScX7k0/ZRf4xkAJB57Y8LH
# 6wMCpiNjIpJY1EppSiklJVqxeUmtme3CGc4GTzpM1awsg7j8sqtsbItnGqj5Aisz
# 5XBL7/5QhK9f4dDgP6nbheTY/7MUuXG08e25pivPClZcbueapE8IUc2YA034aBTU
# zM/9nf4NWxrkTGP2vL3UKAMI6gEFpOflvUsBHqaPDfJMURYqNudiTxFFKwPg2rpt
# sstFkpsFTwCCYe38htxyetSkHXo+xdC/dapLN0SDBMeGiIGHjrUksPaeCY4MXxcM
# p2WpBFRMQlglHUKMiq6LeN/d0eARaRfuN2qjthEHB3FBlmZb1vf5zxNH3d7PxKZI
# EL1i1TSh9EvdqwmmSNttBN2AAeEPvgbuQGE9FkDS2DYDJpc51vpaoD3aLoZ82baQ
# plROjU1e24LZ4Q4=
# SIG # End signature block
