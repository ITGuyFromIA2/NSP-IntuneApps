param ($IPAddress="10.0.0.28", $PrinterName="Kyocera EcoSys M3540idn")
#Folder to Download to (and extract in)
    $DestFolder = 'C:\admin\Installers'

    #Create DestFolder if not already exist
    if (!(Test-Path -Path $DestFolder)) {New-Item -ItemType Directory -Path $DestFolder}

Start-Transcript -Path (-join($DestFolder,"\KyoceraLog.txt")) -Append -NoClobber -IncludeInvocationHeader
#URL to Download drivers from
    $URL = "https://www.kyoceradocumentsolutions.us/content/download-center-americas/us/drivers/drivers/KX_DRIVER_zip.download.zip"
    $DestFile = 'Kyocera_signed.zip'



#Full path to DestFile
    $FullDest = (-join($DestFolder,"\",$DestFile))

#Full path to Unzipped Folder
    $UnzippedFolder = (-join($DestFolder,"\KyoceraDrivers"))

#Name of Printer, as seen by user
    #$PrinterName = "Kyocera EcoSys M3540idn"

#INF File to use for setup, this will change with each driver/printer combo
    #C:\admin\Installers\KyoceraDrivers\KXv4Driver\en\PrnDrv\PCL Driver\64bit\win81 and newer
    #$INFFile = (-join($UnzippedFolder,"\KXv4Driver\en\PrnDrv\PCL Driver\64bit\win81 and newer\prnkycl1.inf"))
    #$INFFile = "C:\Admin\Installers\KyoceraDrivers\KX852405\64bit\OEMSETUP.INF"
#Driver to use, as seen in Printer Properties -> Pulled from inf named above
    $DriverName = "Kyocera ECOSYS M3540idn KX"

#IP Address of Printer
    #$IPAddress = "10.0.0.28"

#Printer Port name
    $PrinterPortName = (-join("IP_",$IPAddress,"_KX"))


#Create DestFolder if not already exist
    #if (!(Test-Path -Path $DestFolder)) {New-Item -ItemType Directory -Path $DestFolder}


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

if ([environment]::Is64BitOperatingSystem) {
    $INFFile = (get-childitem (get-childitem (get-childitem -path $UnzippedFolder)[0].FullName -Filter "64bit").FullName -filter "*.inf").FullName
} else {
    $INFFile = (get-childitem (get-childitem (get-childitem -path $UnzippedFolder)[0].FullName -Filter "32bit").FullName -filter "*.inf").FullName
}




#Preinstall INF
if ([environment]::Is64BitOperatingSystem) {
    Invoke-Command {C:\Windows\SysNative\pnputil.exe -a $INFFile}
} else {
    Invoke-Command {pnputil.exe -a $INFFile}
}

#Install Printer Driver
    Add-PrinterDriver -Name $DriverName

#Add Printer Port
    Add-PrinterPort -Name $PrinterPortName -PrinterHostAddress $IPAddress
    Start-Sleep -seconds 30

#Add Printer
    Add-Printer -Name $PrinterName -PortName $PrinterPortName -DriverName $DriverName


    Stop-Transcript