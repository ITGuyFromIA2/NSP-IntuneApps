
#############################################################################
#If Powershell is running the 32-bit version on a 64-bit machine, we 
#need to force powershell to run in 64-bit mode .
#############################################################################
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    start-transcript c:\admin\DCU_DriverUpdate_elevate.log
    write-warning "Y'arg Matey, we're off to 64-bit land....."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
exit $lastexitcode
}


write-host "Main script body"

start-transcript c:\admin\DCU_DriverUpdate.log
#############################################################################
#End
#############################################################################
#Get the current working DIR
    if ($psISE) {$BaseDir = Split-Path -Path $psISE.CurrentFile.FullPath} else {$BaseDir = $PSScriptRoot} 
    $SharedDefs = "$($BaseDir)\SharedDefs.ps1"
    set-executionpolicy bypass -force
    . $SharedDefs

    #Changing this as I'm re-using code from the first step
    $Config.DCU.XMLLogDir = $Config.DCU.XMLLogDir_Apply
    write-output "Current BaseDir: $($BaseDir)"
    write-output "Path to Shared Defs: $($SharedDefs)"
    write-output "Path to XMLLogDir: $($Config.DCU.XMLLogDir)"
#######################Items above this line need to be broken out for dot sourcing (Using across multiple scripts)


#Tunable items for script
    $Config.DCU.Action = "applyUpdates"     #Could be 'scan' / 'applyUpdate'
    $Config.DCU.UpdateType = "driver" #Could be
    $Config.DCU.AllowReboot = "disable"


#Check for #Config.BaseDir and create if not already
    if (!(Test-Path -Path "$($Config.BaseDir)")) {new-item -path $($Config.BaseDir) -ItemType Directory}

#Test for $Config.DCU.XMLLogDir and create if needed
    if (!(Test-Path -Path $Config.DCU.XMLLogDir)) {new-item -itemtype Directory -Path $Config.DCU.XMLLogDir -Force}


#Dell Command Update arguments. USES Some of the 'tunable' items from above
$Config.DCU.args = @()
$Config.DCU.args += "/$($Config.DCU.Action)"
$Config.DCU.args += "-silent"
$Config.DCU.args += "-updateType=$($Config.DCU.UpdateType)"
#$Config.DCU.args += "-report=$($Config.DCU.XMLLogDir)"


#Clear out Report DIR before scanning for new drivers (DOESN'T REMOVE THE DIR though)
    Remove-Item -Path "$($Config.DCU.XMLLogDir)\*" -Force -ErrorAction SilentlyContinue

#Check for Driver updates, waiting for it to finish
    Start-Process -FilePath "$($Config.DCU.EXE)" -ArgumentList $Config.DCU.args -Wait

#Check to see how many updates
$Temp = @(([xml](get-content -Path ((Get-ChildItem -Path $($Config.DCU.XMLLogDir) -Filter "*.xml").FullName))).updates.update)

if ($Temp.Count -eq 0) {
    $NeedsUpdate = 1
} else {
    $NeedsUpdate = 0
}

$Config.Reg = @()

$Config.Reg += [pscustomobject]@{
    Path = "$($Config.REG_Base)"
    Name = $Config.REG_Name_NeedsUpdate
    Type = "REG_SZ"
    Value = $NeedsUpdate
}

$Config.Reg += [pscustomobject]@{
    Path = "$($Config.REG_Base)"
    Name = $Config.REG_Name_UpdatesApplied
    Type = "REG_SZ"
    Value = 1
}

#Process and replace the 'Type' with the PowerShell versions
foreach ($RegEntry in $Config.Reg) {
switch($RegEntry.Type) {
"REG_SZ" {$RegEntry.Type = "String"}
"REG_BINARY" {$RegEntry.Type = "Binary"}
"REG_EXPAND_SZ" {$RegEntry.Type = "ExpandString"}
"REG_DWORD" {$RegEntry.Type = "DWord"}
"REG_QWORD" {$RegEntry.Type = "QWord"}
"REG_MULTI_SZ" {$RegEntry.Type = "MultiString"}
default {$RegEntry.Type = "Unknown"}
}
}



foreach ($RegEntry in $Config.Reg) {
    #Test for and create the path to the reg key
       if (!(get-item $RegEntry.path -ErrorAction SilentlyContinue)) {Write-Output "not Exist; creating."; new-item -path $($RegEntry.Path) -Force}

    if ((Get-Item $($RegEntry.Path)).Property -contains $($RegEntry.Name)) {
        set-ItemProperty -Path $($RegEntry.Path) -Name $($RegEntry.Name) -Value $($RegEntry.Value)
    } else {
        New-ItemProperty -Path $($RegEntry.Path) -Name $($RegEntry.Name) -PropertyType $($RegEntry.Type) -Value $($RegEntry.Value)
    }

}


#Take care of setting up the scheduled task that will periodically run

#Copy from temp Intune DIR to perm dir
#copy-item -Path "$($BaseDir)\$($Config.SchedTask_ps1Name)" -Destination "$($Config.BaseDir)" -Force

#copy-item -Path "$SharedDefs" -Destination "$($Config.BaseDir)" -Force

  #  $Config.SchedTask.Action_Args = @()
        #$Config.SchedTask.Action_Args += "-executionpolicy bypass"
        #$Config.SchedTask.Action_Args += "-WindowStyle hidden"
        #$Config.SchedTask.Action_Args += "-file ""$($Config.BaseDir)$($Config.SchedTask_ps1Name)"""



        #$FinalArgs = [string]::Join(" ",($Config.SchedTask.Action_Args.GetEnumerator() | %{$_}))
    #$Config.schedTask.Action = New-ScheduledTaskAction -Execute powershell.exe -Argument $FinalArgs
    #$Config.SchedTask.AllowRunTime = New-TimeSpan -Hours 1

    #$Config.SchedTask.Settings = New-ScheduledTaskSettingsSet -DisallowDemandStart:$false -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit $Config.SchedTask.AllowRunTime -MultipleInstances IgnoreNew -StartWhenAvailable -WakeToRun:$false
    #$Config.SchedTask.Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $Config.SchedTask.trigger = New-ScheduledTaskTrigger -once -At ((get-date).AddMinutes(30))

    #$TempTask = New-ScheduledTask -Action $Config.schedTask.Action -Description $Config.SchedTask_Descr -Principal $Config.SchedTask.Principal -Settings $Config.SchedTask.Settings -Trigger $Config.SchedTask.trigger
    $Triggers = @()


$TempTask = Get-ScheduledTask -TaskName "$($Config.SchedTask_Name)"

$Triggers += $TempTask.Triggers
$Triggers += $Config.SchedTask.trigger

    set-ScheduledTask "$($Config.SchedTask_Name)" -Trigger $Triggers


    $pendingRebootTests = @(
    @{
        Name = 'RebootPending'
        Test = { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing'  Name 'RebootPending' -ErrorAction Ignore }
        TestType = 'ValueExists'
    }
    @{
        Name = 'RebootRequired'
        Test = { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'  Name 'RebootRequired' -ErrorAction Ignore }
        TestType = 'ValueExists'
    }
    @{
        Name = 'PendingFileRenameOperations'
        Test = { Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction Ignore }
        TestType = 'NonNullValue'
    }
)
$RebootNeeded = 0
foreach ($test in $pendingRebootTests) {
    $result = Invoke-Command -ScriptBlock $test.Test
    if ($test.TestType -eq 'ValueExists' -and $result) {
        $true
        $RebootNeeded += 1
    } elseif ($test.TestType -eq 'NonNullValue' -and $result -and $result.($test.Name)) {
        $true
        $RebootNeeded += 1
    } else {
        $false
    }
}

if ($RebootNeeded -gt 0) {
    $ExitCode = 1641
} else {
    $ExitCode = 0
}
    Stop-Transcript
exit $ExitCode
# SIG # Begin signature block
# MIIbyQYJKoZIhvcNAQcCoIIbujCCG7YCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiF9rrcOgwbJS2NP/0uLAVfT2
# l8KgghY1MIIDKDCCAhCgAwIBAgIQXp50wvfoo4ZEs021q1HySzANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUe9uaM+d1fiu6oZqavuWYMD2Y2SowDQYJKoZIhvcN
# AQEBBQAEggEAP4iQgJnSutEoE3/cx+HN9FZ9NvMms5z5EQsPewbeAh+CDLZh2oRi
# GW5xtX5insTzJ/tDmW8zWF7uRqcVZmWnIjLwzfj3zEu66B7OVjiaaOPv9RdpA8rL
# DUdsNfjp6gAsJZqTHpN4abQkzeMNDuM2GGb+lvZFCOefI3lb7p3O2r5ETqEWq3e/
# JuGoyL45McRxuC+3ruBLLkxSxRhVs1Ykwg0LyZlnLJiT9oPoAQTQM+CvpDmaUcIj
# cOV5leHwXSswyZ40Z+lb2o1w12fD+8gWxieU+/p2O1utOXqcA26oyHqNMCCX4OmB
# 2jZsotms09bAQSQWSlxxMVyt6fPOmE+gOKGCAyAwggMcBgkqhkiG9w0BCQYxggMN
# MIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0ECEAVEr/OUnQg5pr/bP1/lYRYwDQYJYIZIAWUDBAIBBQCg
# aTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yNDA3
# MDkyMTE1MTBaMC8GCSqGSIb3DQEJBDEiBCAjmB+nqrX5MjJIYHo4EJZsiq1dgzW3
# b6+4lxTBP09+DzANBgkqhkiG9w0BAQEFAASCAgCgpb5TqyfDcazrITtafwbudBu5
# UT9kq+TNy/FQm3JDccy4fPECaDLasy7cbK6Wi2sM0eMZLljUL5guwFZNM6GRlufb
# FHPe6d7KqmXZuLH3j7T4Syy/mbdWAI3idfAp5fuHsVshAXYAvpj0cEmPKRGQ0Rfc
# 7QORq6VvuO/3NLoiej5hZwTNmWt3byV+4f25PK6AvGpfBjEy1t8J4RWZdrchS0kj
# btXnsoZ/WC3/PiOQ/Byj1OMnoy+AaNbSh2BA2VYYOxeBmIAOgMQ7oSDQf3OFMug8
# alyzFsCzVmmhtZnl07Spmt7xxvyNcY1axJBWMbMNPpNpS3q4fEdmU9cP5LEnY/HN
# x8wlwjvOhhCKMEi9hWH3gwxw6YseZGIXH4OZMRfClFq2ROX0OJropXUXEEqMz5jG
# EzohMRPC7kq2dzLvZu0aAFRGo9WEG1pJjg1+cZfEi4wCuP1TryDTJWbOETmrZRvR
# AaJ/wF2YNgzhxk4VPxOsY9L4xVjkHUNZOi+lff+bxyYBgFnmxiDWhgR++qBIMCNR
# WvVnz3oE0CVbUvKLftQCrh0PcSm0sGxw9cfnjwb1W+DkuJDHSSSYW2M3PsishPW3
# ASHQwDIl7SK02NrK0fG9bKorxGOAxRNFjduX+0QJty0uI+G58okB5dDXRb2oGngX
# lPLqD+Eq4e4dlVdYTg==
# SIG # End signature block
