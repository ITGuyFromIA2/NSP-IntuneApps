param ($IPAddress="10.0.0.24", $PrinterName="HP LaserJet Pro M148fdw")

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
    Add-PrinterDriver -Name $DriverName

#Add Printer Port
    Add-PrinterPort -Name $PrinterPortName -PrinterHostAddress $IPAddress
    Start-Sleep -seconds 30

#Add Printer
    Add-Printer -Name $PrinterName -PortName $PrinterPortName -DriverName $DriverName