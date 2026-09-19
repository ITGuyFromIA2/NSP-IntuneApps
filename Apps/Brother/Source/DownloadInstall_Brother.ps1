param ($IPAddress="10.0.0.24", $PrinterMFG="Brother", $PrinterModel="MFC-L2710DW",$Package="Full")

$BaseDir="C:\admin\Installers"
if (!(test-path $BaseDir)) {new-item -path $BaseDir -ItemType Directory -Force -ErrorAction SilentlyContinue}

    $model = $PrinterModel.ToLower().replace("-","")
    if ($Package -eq "Full") {
        $PackageToDL = "Full Driver & Software Package"
    }

$PrinterName = "$($PrinterMFG) $($PrinterModel)"
$PrinterPortName = (-join("IP_",$IPAddress,"_",$($PrinterMFG.Substring(0,2))))
#MFC-L2710dw
    #Windows 11 - English
    #$Model="mfcl2710dw"
    #$ModelName = "MFC-L2710DW"
    #SoftwarePackage
    #$Package = "Full Driver & Software Package"



#OSCollection to handle the Number portion of the URI search that correlates to OS
    $OSColl = @(
        [PSCustomObject]@{
            OS = "Windows 11"
            Bit = "64"
            URIString = "10068"
        },
        [PSCustomObject]@{
            OS = "Windows 10"
            Bit = "64"
            URIString = "10013"
        },
        [PSCustomObject]@{
            OS = "Windows 10"
            Bit = "32"
            URIString = "10012"
        }
    )
   
   #Storing some info for calculating our URI with
    $OS = (get-computerinfo).osname
    if ([Environment]::Is64BitOperatingSystem) {$Bitness = "64"} else {$Bitness = "32"}


        #https://support.brother.com/g/b/downloadlist.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10068

#Pre-filtering our OSColl based on OS
    $MiddleVars = $OSColl | Where-Object -FilterScript {$os -like "*$($_.OS)*"}
#Final Filter on Bitness
    $FinalVars = $MiddleVars | Where-Object -FilterScript {$Bitness -like "*$($_.Bit)*"}


        #Our base URI
        $BaseURI = "https://support.brother.com"
        $MiddleURI = "/g/b/downloadlist.aspx"
        $AppendURI = "?c=us&lang=en&prod=$($Model)_us_eu_as&os=$($FinalVars.URIString)"
        $FinalURI = "$($BaseURI)$($MiddleURI)$($AppendURI)"


        #Hit the first Brother download page e.g. https://support.brother.com/g/b/downloadlist.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013
            $result = invoke-webrequest -uri $FinalURI  -UseBasicParsing

        #Find our links specific to this model (our actual downloads)
            $ModelLinks = $Result.Links.outerhtml | Where-Object -FilterScript {($_) -like "*$($AppendURI)*" }
       
        #regexes for URI
            $RegPattern = [regex]'\<a href=\"(?<ParsedLink>.*)\"\>(?<SearchTerm>.*)\<\/a\>'
            $RegPattern2 = [regex]'\<a id="downloadfile" href=\"(?<ParsedLink>[^"]*)\"'
            $RegPattern3 = [regex]'\<a href=\"(?<ParsedLink>[^"]*)\"'
        
        #FinalDL Page
            $FoundLink= $ModelLinks | Select-String -Pattern $RegPattern -AllMatches | Where-Object -FilterScript {$_.Matches.Groups[2].Value -eq "$($PackageToDL)"}
               
        #Parse this final page for the ACTUAL Download URL
            $TempDL = invoke-webrequest -uri "$($BaseURI)$($FoundLink.Matches.groups[1].value)" -UseBasicParsing -SessionVariable $WebSess
            $BuiltAcceptEULA = "$($BaseURI)$(($TempDL.Links.outerhtml | Where-Object -FilterScript {($_) -like "*$($AppendURI)*" } | Select-String -Pattern $RegPattern3).Matches.groups[1].value)"

            $Headers = @{
                "Referer" = $("$($BaseURI)$($FoundLink.Matches.groups[1].value)")
            }
            $TempDL2 = invoke-webrequest -uri $BuiltAcceptEULA -UseBasicParsing -SessionVariable $WebSess -Headers $Headers

        #Get our link using the second reg pattern
            $FinalLink = ($TempDL2.Links.outerhtml | Select-String -Pattern $RegPattern2 -AllMatches).Matches.groups[1].value

        #Build our variables
             $URL = $FinalLink                                   #URL to DL From
             $FileName = $URL.Split("/")[-1]                     #Split filename from URL
             $ZipName = $FileName.replace("exe","zip")           #OnceRenamed....
             $UnzippedFolder = "BrotherUnzipped"

             $FullDL = "$($BaseDir)\$FileName"
             $FullZip = "$($BaseDir)\$ZipName"
             $FullUnzip = "$($BaseDir)\$UnzippedFolder"

        (New-Object Net.WebClient).DownloadFile("$($FinalLink)", $FullDL)
        start-sleep -seconds 30
        Rename-Item -Path $FullDL -NewName $ZipName -force
        Expand-Archive -Path  $FullZip -DestinationPath $FullUnzip -Force


        $DatFiles = get-childitem -path "$($FullUnzip)\setup\Install\model" -filter "*.dat"

        #$Dat = $DatFiles[15]
       $ParseDat = @(foreach ($Dat in $DatFiles) {
            $TempContent = get-content -path $Dat.FullName
            if ($TempContent -like "*$($ModelName)*") {
                $Dat.FullName
            }
        
        }
        )

        $TempDat = get-content -path $ParseDat 
        $DriverNames = @{
            Printer = ($TempDat | Select-String -Pattern 'PrinterDriverName=(.*)').Matches.groups[1].Value
            Scanner = ($TempDat | Select-String -Pattern 'ScannerDriverName=(.*)').Matches.groups[1].Value
        }
       # $TempDat.Matches.groups[1].Value

        $SeriesFile = $TempDat | Select-String -Pattern 'SeriesFile=(.*)'
        $DatContent = get-content -path "$($FullUnzip)\setup\Install\series\$($SeriesFile.Matches.groups[1].Value)"
        $PrintDriver = $DatContent | Select-String -Pattern 'PrinterDriver=(.*)'
        $ScanDriver = $DatContent | Select-String -Pattern 'ScannerDriver=(.*)'

       
       

       $Drivers = @("$($FullUnzip)\setup\Install\$($PrintDriver.Matches.groups[1].Value)",
                   "$($FullUnzip)\setup\Install\$($ScanDriver.Matches.groups[1].Value)")

       foreach ($Driver in $Drivers) {
       $MSIParams = @("/i $($Driver)","/passive","/qb","/norestart")
       start-process msiexec.exe -ArgumentList $MSIParams -Wait
       }
        <#
        https://support.brother.com/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106867_000&flang=4&type3=11
        https://support.brother.com/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106867_000&flang=4&type3=11
        https://support.brother.com/g/b/downloadhowto.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106867_000&flang=4&type3=11
        https://download.brother.com/welcome/dlf106867/Y17C_C1_ULWL_PP-usa-inst-K1.exe


        <a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106867_000&flang=4&type3=11">Full Driver & Software Package</a>                                    
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106875_000&flang=4&type3=536">Printer Driver & Scanner Driver for USB</a>                          
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106873_000&flang=4&type3=408">Printer Driver</a>                                                   
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106876_000&flang=4&type3=415">XML Paper Specification Printer Driver</a>                           
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf004715_000&flang=8&type3=375">Firmware Update Tool</a>                                             
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf102998_000&flang=8&type3=402">Wireless Setup Helper</a>                                            
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106571_000&flang=4&type3=393">Network Connection Repair Tool</a>                                   
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106409_000&flang=4&type3=557">PaperPort&trade; Install Tool</a>                                    
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf103785_000&flang=4&type3=424">ControlCenter4 Update Tool</a>                                       
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106383_000&flang=4&type3=39">Uninstall Tool</a>                                                    
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106359_000&flang=4&type3=10272">Brother iPrint&Scan</a>                                            
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf103740_000&flang=4&type3=10341">Software Update Notification Updater</a>                           
<a href="#pane2" class="toggle-buttonEx2" data-close="Show all" data-open="close">Show all</a>                                                                                           
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106273_000&flang=4&type3=10234">Status Monitor Update Tool</a>                                     
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf005060_000&flang=4&type3=399">Driver Language Switching Tool</a>                                   
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf102007_000&flang=4&type3=10104">PC-FAX Receiving Update Tool</a>                                   
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106405_000&flang=4&type3=10456">BRAdmin Professional 4</a>                                         
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106490_000&flang=4&type3=284">BRAdmin Light</a>                                                    
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf002778_000&flang=4&type3=46">BRAgent</a>                                                           
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf005058_000&flang=4&type3=30">Driver Deployment Wizard</a>                                          
<a href="/g/b/downloadend.aspx?c=us&lang=en&prod=mfcl2710dw_us_eu_as&os=10013&dlid=dlf106453_000&flang=4&type3=10245">Mass Deployment Tool</a>            
        #>


<#



#192.168.6.115

#URL to Download drivers from
    $URL = "https://ftp.hp.com/pub/softlib/software13/printers/UPD/upd-pcl6-x64-7.3.0.25919.zip"
    $DestFile = 'HPUniversal.zip'

#Folder to Download to (and extract in)
    $DestFolder = 'C:\admin\Installers'

#Full path to DestFile
    $FullDest = (-join($DestFolder,"\",$DestFile))

#Full path to Unzipped Folder
    $UnzippedFolder = (-join($DestFolder,"\HPDrivers"))

#Name of Printer, as seen by user
    #$PrinterName = "HP LaserJet Pro M148fdw"

#INF File to use for setup, this will change with each driver/printer combo
    #$INFFile = (-join($UnzippedFolder,"\hpcu250u.inf"))
    $INFFile = (-join($UnzippedFolder,"\hpcu310u.inf"))
#Driver to use, as seen in Printer Properties -> Pulled from inf named above
    $DriverName = "HP Universal Printing PCL 6"

#IP Address of Printer
    #$IPAddress = "10.0.0.24"

#Printer Port name
    $PrinterPortName = (-join("IP_",$IPAddress,"_HP"))


#Create DestFolder if not already exist
    if (!(Test-Path -Path $DestFolder)) {New-Item -ItemType Directory -Path $DestFolder}


#Remove alreadyExisting FullDest if already present
    if (Test-Path -Path $FullDest) {Remove-Item -Path $FullDest -Confirm:$false -force}

#Set TLS 1.2 as protocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Download File
    Invoke-WebRequest -Uri $URL -OutFile $FullDest -UseBasicParsing
#Unblock File
    Unblock-File -Path $FullDest

#Remove UnzippedFolder if already exists
    if (Test-Path $UnzippedFolder) {Remove-Item -Path $UnzippedFolder -Recurse -Confirm:$false -Force}

#Unzip File
    Expand-Archive -Path $FullDest -DestinationPath $UnzippedFolder


#Preinstall INF
    Invoke-Command {pnputil.exe -a $INFFile}

#Install Printer Driver
#>
#Add Printer Port

 Add-PrinterDriver -Name $DriverNames.Printer

    Add-PrinterPort -Name $PrinterPortName -PrinterHostAddress $IPAddress
    Start-Sleep -seconds 30

#Add Printer
    Add-Printer -Name $PrinterName -PortName $PrinterPortName -DriverName $DriverNames.Printer -Datatype 