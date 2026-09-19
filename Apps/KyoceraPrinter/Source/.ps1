param ($IPAddress, $PrinterName)

#Folder to Download to (and extract in)
    $DestFolder = 'C:\admin\Installers'

    #Create DestFolder if not already exist
    if (!(Test-Path -Path $DestFolder)) {New-Item -ItemType Directory -Path $DestFolder}

Start-Transcript -Path (-join($DestFolder,"\KyoceraLog_Uninstall.txt")) -Append -NoClobber -IncludeInvocationHeader

#URL to Download drivers from
    $URL = "https://www.kyoceradocumentsolutions.us/content/download-center-americas/us/drivers/drivers/Kxv4_601527_zip.download.zip"
    $DestFile = 'Kyocera_signed.zip'

#Folder to Download to (and extract in)
    #$DestFolder = 'C:\admin\Installers'

#Full path to DestFile
    $FullDest = (-join($DestFolder,"\",$DestFile))

#Full path to Unzipped Folder
    $UnzippedFolder = (-join($DestFolder,"\KyoceraDrivers"))

#Name of Printer, as seen by user
    $PrinterName = "Kyocera EcoSys M3540idn"

#INF File to use for setup, this will change with each driver/printer combo
    #C:\admin\Installers\KyoceraDrivers\KXv4Driver\en\PrnDrv\PCL Driver\64bit\win81 and newer
    $INFFile = (-join($UnzippedFolder,"\KXv4Driver\en\PrnDrv\PCL Driver\64bit\win81 and newer\prnkycl1.inf"))

#Driver to use, as seen in Printer Properties -> Pulled from inf named above
    $DriverName = "Kyocera ECOSYS M3540idn v4 KX (PCL6)"

#IP Address of Printer
    $IPAddress = "10.0.0.28"

#Printer Port name
    $PrinterPortName = (-join("IP_",$IPAddress,"_KX"))





#Download file to FullDest if NOT already present
    if (!(Test-Path -Path $FullDest)) {
        #Set TLS 1.2 as protocol
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #Download File
            Invoke-WebRequest -Uri $URL -OutFile $FullDest -UseBasicParsing
        #Unblock File
            Unblock-File -Path $FullDest
    }

#Expand to UnzippedFolder if NOT exists
    if (!(Test-Path $UnzippedFolder)) {
        #Unzip File
            Expand-Archive -Path $FullDest -DestinationPath $UnzippedFolder
    }

#Remove Printer
    Remove-Printer -Name $PrinterName -Confirm:$false

#Remove Printer Port
    Remove-printerport -name $PrinterPortName

#Uninstall INF (also removes driver)
    Invoke-Command {pnputil.exe -d $INFFile -force}

    remove-PrinterDriver -Name $DriverName -RemoveFromDriverStore

Remove-Item -Path $UnzippedFolder -Recurse -confirm:$false -Force
Remove-Item -Path $FullDest -Confirm:$false -Force

Stop-Transcript