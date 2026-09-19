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



       



#Expand to UnzippedFolder if NOT exists
    if (!(Test-Path $UnzippedFolder)) {
            if (!(Test-Path -Path $FullDL)) {
                #Set TLS 1.2 as protocol
                    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                (New-Object Net.WebClient).DownloadFile("$($FinalLink)", $FullDL)
                start-sleep -seconds 30
                Rename-Item -Path $FullDL -NewName $ZipName -force
            }

        Expand-Archive -Path  $FullZip -DestinationPath $FullUnzip -Force

    }

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



#Remove Printer
    Remove-Printer -Name $PrinterName -Confirm:$false

#Remove Printer Port
    Remove-printerport -name $PrinterPortName

#Uninstall INF
    #Invoke-Command {pnputil.exe -d $INFFile -force}

Remove-Item -Path $UnzippedFolder -Recurse -confirm:$false -Force
Remove-Item -Path $FullZip -Confirm:$false -Force
Remove-Item -Path $FullDL -Confirm:$false -Force