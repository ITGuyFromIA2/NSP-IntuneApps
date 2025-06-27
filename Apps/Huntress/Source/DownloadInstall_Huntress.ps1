param($AcctKey,$ClientName="Contoso", $LogDir="C:\Admin\Installers\Huntress\Logs")

#Check/Create our logDir
if (!(test-path -Path $LogDir -ErrorAction SilentlyContinue)) {new-item -path $LogDir -ItemType Directory -Force -ErrorAction SilentlyContinue}

#Start our transcript
Start-Transcript -path "$($LogDir)\$($env:COMPUTERNAME)-HuntressLog.txt" -Append

#Force TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Control Variables

#DownloadSource
    $DLSource = (-join("https://huntress.io/download/",$AcctKey))

#Destination Folder / File
    $DLDest = "C:\Admin\Installers"
    $DL_FullDest = (-join($DLDest,"\HuntressInstaller.exe"))

#Pre-setting two control variables to determine if reinstall / fresh install needed
    $Bool_Reinstall = $false
    $Bool_FreshInstall = $false

#Reg path to root of Huntress settings
    $Huntress_RegPath = "HKLM:\SOFTWARE\Huntress Labs\Huntress"

#Reg Value 1 (AccountKey)
    $Huntress_RegVal1 = [PSCustomObject]{}
        $Huntress_RegVal1 | Add-Member -MemberType NoteProperty -Name 'Key' -Value "AccountKey"
        $Huntress_RegVal1 | Add-Member -MemberType NoteProperty -Name 'Value' -Value $AcctKey

#Reg Value 1 (OrganizationKey)
    $Huntress_RegVal2 = [PSCustomObject]{}
        $Huntress_RegVal2 | Add-Member -MemberType NoteProperty -Name 'Key' -Value "OrganizationKey"
        $Huntress_RegVal2 | Add-Member -MemberType NoteProperty -Name 'Value' -Value $ClientName

#Reg Value 1 (Tags)
    $Huntress_RegVal3 = [PSCustomObject]{}
        $Huntress_RegVal3 | Add-Member -MemberType NoteProperty -Name 'Key' -Value "Tags"
        $Huntress_RegVal3 | Add-Member -MemberType NoteProperty -Name 'Value' -Value $LocationName


#Check for pre-existing installation
    $SoftwareCheck = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Where-Object {$_.GetValue('DisplayName') -like "Huntress*"}

#IF >0 then already installed -> Check REG Values then...
    if ($softwareCheck.count -gt 0) {
        write-output "Huntress Already Installed, checking REG Keys"
        
        #Pre-set RegMismatch to FALSE
            $Bool_RegMismatch = $false

        #Test Reg path -> IF NOT THERE -> RegMismatch
            if (!(Test-Path -Path $Huntress_RegPath)) {$Bool_RegMismatch = $true}
        
        #Store current values from Registry
            $TempAcctKey = (Get-ItemProperty -Path $Huntress_RegPath -Name $Huntress_RegVal1.Key).($Huntress_RegVal1.Key)
            $TempOrgKey = (Get-ItemProperty -Path $Huntress_RegPath -Name $Huntress_RegVal2.Key).($Huntress_RegVal2.Key)
            $TempTags = (Get-ItemProperty -Path $Huntress_RegPath -Name $Huntress_RegVal3.Key).($Huntress_RegVal3.Key)
        
        #If any AcctKey / OrgKey / Tags are NOT correct, will set mismatch
            if ($TempAcctKey -ne $AcctKey) {$Bool_RegMismatch = $True}
            if ($TempOrgKey -ne $ClientName) {$Bool_RegMismatch = $True}
            #if ($TempTags -ne $LocationName) {$Bool_RegMismatch = $True}

        #IF ANY of the above were TRUE, then set Bool_Reinstall
            if ($Bool_RegMismatch) {$Bool_Reinstall = $true}

#IF = 0 -> NEw install
    } else {
        $Bool_FreshInstall = $true
    }

#Check for Orphaned
    $file = "C:\Program Files (x86)\Huntress\HuntressAgent.log"
    if (-not(Test-Path -Path $file -PathType Leaf)) {
        $file = "C:\Program Files\Huntress\HuntressAgent.log"
        Get-Content $file -Tail 20 | ForEach-Object { if ($_ -like "*bad status code: 401*") {Echo "ORPHANED"; $Bool_Reinstall = $true}}
     } else {
     Get-Content $file -Tail 20 | ForEach-Object { if ($_ -like "*bad status code: 401*") {Echo "ORPHANED"; $Bool_Reinstall = $true}}
     }

#Perform uninstall
    if ($Bool_Reinstall) {
        $UninstallCommand = $SoftwareCheck.GetValue('QuietUninstallString')
        cmd /c "$UninstallCommand"
        Start-Sleep -Seconds 30
    }

#Perform new Install
    if ($Bool_FreshInstall) {
        #Create Folder if not exist
            if (!(Test-Path -Path $DLDest)) {New-Item -ItemType Directory -Path $DLDest}

        #Download Installer File
            Invoke-WebRequest -UseBasicParsing -Uri $DLSource -OutFile $DL_FullDest
        
        #Set Installation arguments
            $CMDC_Args = "/ACCT_KEY=$AcctKey /ORG_KEY=""$ClientName"" /TAGS=""$LocationName"" /S"
        
        #Perform Installation
            $InstallResult = cmd /c "$DL_FullDest $CMDC_Args"
}
Stop-Transcript
