
#Folder to Download to (and extract in)
    $DestFolder = 'C:\admin\Installers'

    #Create DestFolder if not already exist
    if (!(Test-Path -Path $DestFolder)) {New-Item -ItemType Directory -Path $DestFolder}

Start-Transcript -Path (-join($DestFolder,"\KyoceraLog_Remove.txt")) -Append -NoClobber

    $DestFile = 'Kyocera_signed.zip'



#Full path to DestFile
    $FullDest = (-join($DestFolder,"\",$DestFile))

#Full path to Unzipped Folder
    $UnzippedFolder = (-join($DestFolder,"\KyoceraDrivers"))


#Remove alreadyExisting FullDest if already present
    if (Test-Path -Path $FullDest) {Remove-Item -Path $FullDest -Confirm:$false -force}

#Remove UnzippedFolder if already exists
    if (Test-Path $UnzippedFolder) {Remove-Item -Path $UnzippedFolder -Recurse -Confirm:$false -Force}

    Stop-Transcript