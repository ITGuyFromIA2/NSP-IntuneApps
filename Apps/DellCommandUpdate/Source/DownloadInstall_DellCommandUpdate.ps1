#############################################################################
#If Powershell is running the 32-bit version on a 64-bit machine, we 
#need to force powershell to run in 64-bit mode .
#############################################################################
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    write-warning "Y'arg Matey, we're off to 64-bit land....."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
exit $lastexitcode
}


write-host "Main script body"

#############################################################################
#End
#############################################################################
start-transcript c:\admin\installers\DellCommand_Download.log
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

$wgetArgs = '--header="Accept: text/html" --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" --no-check-certificate'


$Config = @{};
#Length of ID in DownloadString
    $Config.DriverIDLength = 5;

$Config.DestFolder = "C:\admin\Installers";

new-item -path $Config.DestFolder -ItemType Directory -Force -ErrorAction SilentlyContinue;

<#
$Config.DCU_Webpage_Package = (-join($Config.DestFolder,"\DCU_Webpage_Package.html"));

#most of this first stuff is to handle WGet requirements
    $Config.BaseURL = "https://eternallybored.org/misc/wget/";
    $Config.WGet_NSP_64 = "https://at.netsysplus.com/LabTech/Transfer/Utilities/wget_1_21_4_64.exe";
    $Config.WGet_NSP_32 = "https://at.netsysplus.com/LabTech/Transfer/Utilities/wget_1_21_4_32.exe";
    $Config.WGet_FullDest = "C:\windows\system32\wget.exe";

    $Config.pattern32 = '<a href="[0-9]\.[0-9]{1,3}\.[0-9]{1,2}\/32\/wget.exe';
    $Config.pattern64 = '<a href="[0-9]\.[0-9]{1,3}\.[0-9]{1,2}\/64\/wget.exe';

    if ([Environment]::Is64BitOperatingSystem) {
        $Config.UsePattern = $Config.pattern64;
    } else {
        $Config.UsePattern = $Config.pattern32;
    }


    try {
        $Test = $null;
        $Test = Invoke-WebRequest -Uri $Config.BaseURL -UseBasicParsing;

    } catch {}

    if (!($Test)) {

        if ([Environment]::Is64BitOperatingSystem) {
            $Config.FinalURL_WGet = $Config.WGet_NSP_64;
        } else {
            $Config.FinalURL_WGet = $Config.WGet_NSP_32;
        }

    } else {

        $Config.FinalAppend = (((((Invoke-WebRequest -Uri $Config.BaseURL -UseBasicParsing).links | Select-String -Pattern $($Config.UsePattern))[0].ToString()).split("="))[2]).Split('"')[1];
        $Config.FinalURL_WGet = (-join($Config.BaseURL,$Config.FinalAppend));
    }

#Download & Unblock WGet from wherever it was determined was available (Source or NSP)
    Invoke-WebRequest -Uri $($Config.FinalURL_WGet) -UseBasicParsing -OutFile $($Config.WGet_FullDest);
    Unblock-File -Path $($Config.WGet_FullDest);

#Get Main KB Article with list of versions / links (NOTE: These are not viewable in a browser, but are in the HTML)
    $TempContent = (Invoke-webrequest -URI "https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update.html" -UseBasicParsing).Content;

#Parse the latest version, should be the first listed.
    $LatestVersion = (($TempContent) | select-string 'Dell Command \| Update (?<Versions>[0-9].[0-9])' -AllMatches).matches | ForEach-Object { $_.Groups['Versions'].Value } | Sort-Object -Descending | Select-Object -First 1;



#Find DCU Download page in content
    $DCU_Webpage = ((($TempContent) | Select-String "https:\/\/www\.dell\.com\/support\/home\/en-us\/drivers\/DriversDetails\?driverId\=[0-9a-zA-Z]{$($Config.DriverIDLength)}").Matches).value;

#Download DCU Webpage with WGet. Need to implement DL for this to prepare new machines.
   wget.exe --header="Accept: text/html" --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" --no-check-certificate "$DCU_Webpage" --output-document="$($Config.DCU_Webpage_Package)";


#These next few steps were folded together into the one-liner that follows
        <#
        $LastStep = get-content -path DCU_Webpage_Package.html | Select-String 'DellDndDD.FileDetails = JSON.parse'
        $LastStep | Select-String 'DellDndDD.FileDetails = JSON.parse'

        $LastStep.split('h') | select-string 'ttps'

        $TempSplit = ((($LastStep.Line).Split('h'))[7]).Split('\')[0]
        #>

#Parse out the final Download URL
    #$Config.FinalURL = (-join('h',(((get-content -path "$($Config.DCU_Webpage_Package)" | Select-String 'DellDndDD.FileDetails = JSON.parse').Line).Split('h') | select-string 'ttps').Line.Split('\')[0]));
    $Config.FinalURL = ("https://at.netsysplus.com/LabTech/Transfer/Software/Dell/Dell-Command-Update-Windows-Universal-Latest.exe");
    write-output "Final URL for package: $($Config.FinalURL)"

$Config.FinalInstaller_Name = $($config.FinalURL.Split("/")[-1]);
$Config.FinalInstaller_FullDest = (-join($Config.DestFolder,"\",$Config.FinalInstaller_Name));


#$Config.FinalInstaller_FullDest = (-join($Config.DestFolder,"\Dell-Command-Update-Windows-Universal-Latest.exe"));
#Use WGet to download the final URL
Invoke-WebRequest -Uri $($Config.FinalURL) -OutFile $($Config.FinalInstaller_FullDest)



#    wget.exe --header="Accept: text/html" --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" --no-check-certificate $($Config.FinalURL) --output-document="$($Config.FinalInstaller_FullDest)";
        wget.exe --header="Accept: text/html" --no-check-certificate $($Config.FinalURL) --output-document="$($Config.FinalInstaller_FullDest)";
#Remove-Item -Path $Config.DCU_Webpage_Package;

cmd /c """$($Config.FinalInstaller_FullDest)"" /s";

$AppName = "Dell Command | Update"

$ProgramList = @( "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" )
$Programs = Get-ItemProperty $ProgramList -EA 0
$App = @(($Programs | Where-Object { $_.DisplayName -like "*$AppName*"}))

if ($App.Count -gt 0) {
    $Installed="$App Installed"
    write-output $installed
     #[Environment]::Exit(0)
     $ExitCode = 0
} else {
    $Installed="$App NOT Installed"
    write-output $Installed
     #[Environment]::Exit(1)
     $ExitCode = 1
}
stop-transcript
[Environment]::Exit($ExitCode)
#cmd /c "$($Config.FinalInstaller_FullDest) /passthrough /x /s /v""/qn"""
# SIG # Begin signature block
# MIIbyQYJKoZIhvcNAQcCoIIbujCCG7YCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQQBKB2tX7k1tYVd70ftMWdD7
# 6higghY1MIIDKDCCAhCgAwIBAgIQXp50wvfoo4ZEs021q1HySzANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUE0+gLqNzt54+5+C7qe4QEoWL0ckwDQYJKoZIhvcN
# AQEBBQAEggEAacJch5iTxMSpuxpKAecmVZnpFqcV0kOdjbwEpcImiMe9oTCVsHfJ
# BmYShr2rCi1T2fuTf7G8AgRzm7Sf3Qt8IRONAHFUMFoKTEUgoSdebL2e+jfPbll8
# 295nearRvVdF+icq2Qsc/uO3uJz+j26zeV9UsrqaJgJBpcd5kbPG+X4bLXbgkLZL
# +rLWBbDzzBEgE4C8s4MfCKaHjbpxRBcH4F5INWv7ziWI16ZO/2Z9a1/omhKQ6ztX
# vqcDTyBnmD1irmsiM5+8YYXNeJsUGouoRzy18uA8CHYm8fuKAdP7asfV8Zrn8+m3
# Ete+AljIuhuge0eba3eO+twaQwiK3PUH1KGCAyAwggMcBgkqhkiG9w0BCQYxggMN
# MIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0ECEAVEr/OUnQg5pr/bP1/lYRYwDQYJYIZIAWUDBAIBBQCg
# aTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yNDA3
# MDkyMTE1MTNaMC8GCSqGSIb3DQEJBDEiBCAR+ICVDBtaM0owiUDMVmUwkaHHsBXu
# zhpyuMKm0aghazANBgkqhkiG9w0BAQEFAASCAgA0Ya9Unw0dbz5rFwtEVRiS3w5F
# XSpB/8HYq4tIWP/zRl3Dr/8FlvQFLEHKugvhqhvsuVRk0oXO0Q5+kv+4BNc5ku2R
# TB6NjOtQ80JlMn0oycZkmFCfXK4vFV05NL+gIcquh5/Ae6ix7qb+vKz90j9JoxgU
# ssyNdU4U+qGdmU/mNqo+jw2jqRx6ndKYtVQgWuGuaHITR0w3uTanqw0WSnDGmWFb
# YOMc4uaZYvHrbvaLM8hDacdzvu1FieRG6NyEz+LKn6sCkZ0rTHE4MDal9oxBSmry
# ompWXWrEcMHDS6hbHtCRluLAvSvZlCd92/CXf2S7pT1DXvUDZZ1fTDffncAWBBg0
# 44BONYlqm8M+9L0v0mzK6hmxZw48ljAoC2kBYfMS3MrXBi0auW7PtglcBlTsj4nh
# Q7Z/GYkkRd0LuGRtwOX8y8c1ZATLkfu+snSTNAigSB01G5tBb3ttGVavkr3FyUuH
# EJMhqsjYVtnfGxF6aDhF0eq0r6xfZSbH18KzUvX/aIuYnnmXsGwt9zICSSwpXHl9
# 1kOV63kWza5e7ATdki8zXahNe4J3NdorJuCN+fPd+uu/QggXC9XVR05QOUA35yXr
# l3UnLisFbgPbqPnibutUHZS5xT/Llm6SJRcj0Vj0auuF6M+8BHf420IOb6/BJ8eN
# kre730W/B3UDLUUOlA==
# SIG # End signature block
