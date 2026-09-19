
#Folder to Download to (and extract in)
    $DestFolder = 'C:\admin\Installers'

    #Create DestFolder if not already exist
    if (!(Test-Path -Path $DestFolder)) {New-Item -ItemType Directory -Path $DestFolder}

Start-Transcript -Path (-join($DestFolder,"\KyoceraLog_Download.txt")) -Append -NoClobber
#URL to Download drivers from
    $URL = "https://www.kyoceradocumentsolutions.us/content/download-center-americas/us/drivers/drivers/Kxv4_601527_zip.download.zip"
    $DestFile = 'Kyocera_signed.zip'



#Full path to DestFile
    $FullDest = (-join($DestFolder,"\",$DestFile))

#Full path to Unzipped Folder
    $UnzippedFolder = (-join($DestFolder,"\KyoceraDrivers"))


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

    Stop-Transcript