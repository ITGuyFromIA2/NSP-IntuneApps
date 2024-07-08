$Shortcut = [pscustomobject]@{
    Path = "$($env:PUBLIC)\Desktop"
    Name = "TRAFx Communicator"
} 

$Config = @{}

$Config.BaseURI = "https://www.trafx.net"
$Config.Link = "$($Config.BaseURI)/support"
$Config.InstallerFolder = "C:\admin\Installers"

$DLPage = Invoke-WebRequest -UseBasicParsing -Uri $Config.Link

$InstallFile = @"
[InstallShield Silent]
Version=v7.00
File=Response File
[File Transfer]
OverwrittenReadOnly=NoToAll
[{ReplaceWith_ProductGuid}-DlgOrder]
Dlg0={ReplaceWith_ProductGuid}-SdWelcome-0
Count=2
Dlg1={ReplaceWith_ProductGuid}-SdFinish-0
[{ReplaceWith_ProductGuid}-SdWelcome-0]
Result=1
[Application]
Name=PL23XX USB-to-Serial
Version=2.0.5
Company=Prolific Technology INC
Lang=0409
[{ReplaceWith_ProductGuid}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"@

$UninFile = @"
[InstallShield Silent]
Version=v7.00
File=Response File
[File Transfer]
OverwrittenReadOnly=NoToAll
[{ReplaceWith_ProductGuid}-DlgOrder]
Dlg0={ReplaceWith_ProductGuid}-SdWelcomeMaint-0
Count=3
Dlg1={ReplaceWith_ProductGuid}-MessageBox-0
Dlg2={ReplaceWith_ProductGuid}-SdFinish-0
[{ReplaceWith_ProductGuid}-SdWelcomeMaint-0]
Result=303
[{ReplaceWith_ProductGuid}-MessageBox-0]
Result=6
[Application]
Name=PL23XX USB-to-Serial
Version=2.0.5
Company=Prolific Technology INC
Lang=0409
[{ReplaceWith_ProductGuid}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"@

$Config.ParseLinks = @(
    [pscustomobject]@{
        LinkPattern = 'TRAFx Communicator V[0-9]*\.[0-9]*'
        MatchedLinks = $null
        FinalLink = ""
        FileName = ""
        FullDest = ""
        VersionInfo = ""
        #InstallCommand = "New-Item -ItemType SymbolicLink -Path `"$($env:PUBLIC)\Desktop`" -Name `"TRAFx Communicator`" -Value $($pEntry.FullDest)"
        #0 $($env:PUBLIC)\Desktop
        #1 TRAFx Communicator
        #2 $($Config.ParseLinks[0].FullDest)
        InstallCommand = "New-Item -ItemType SymbolicLink -Path `"{0}`" -Name `"{1}`" -Value {2}"
        InstallRepl = '@("$($Shortcut.Path)","$($Shortcut.Name)", $($pEntry.FullDest))'
        FinalCommand = ""
        #Replace with save as obove, minus the last one

        #0 $($env:PUBLIC)\Desktop
        #1 TRAFx Communicator
        UninstallCommand = 'get-item -path "{0}\{1}" | Remove-Item -Confirm:$False'
        UninstallRepl = '@("$($Shortcut.Path)","$($Shortcut.Name)")'
        FinalUninstall = ""
        

    }, 
    [pscustomobject]@{
        LinkPattern = 'Driver Installer'
        MatchedLinks = $null 
        FinalLink = ""
        FileName = ""
        FullDest = ""
        VersionInfo = ""
       # InstallCommand = "cmd /c `"$($pEntry.FullDest)`" -s"
       InstallCommand = "{0} /s /f1`"{1}`""
       #InstallRepl = '@("$($pEntry.FullDest)", "C:\admin\Installers\USB_Adapter_Driver_InstallAnswers.iss")'
       InstallRepl = '@("$($pEntry.FullDest)", "$($pEntry.Answer_Install)")'
       Answer_Install = "C:\admin\Installers\USB_Adapter_Driver_InstallAnswers.iss"
       Answer_Uninstall = "C:\admin\Installers\USB_Adapter_Driver_UninstallAnswers.iss"

       FinalCommand = ""

       UninstallCommand = "cmd /c {0} /s /f1`"{1}`""
       #UninstallRepl = '@($($PathEXE), "C:\admin\Installers\USB_Adapter_Driver_UninstallAnswers.iss")'
       UninstallRepl = '@($($PathEXE), "$($pEntry.Answer_Uninstall)")'
       FinalUninstall = ""

        #0 is path to executable and 1 is path to folder for extraction
        ExtractCommand = "{0} /s /extract_all:`"{1}`""
        ExtractFolder = "$($Config.InstallerFolder)\TempExtract"
        EXParseFile = "Disk1\setup.ini"
        EXRegex = 'ProductGUID=(?<GUID>[0-9A-Z\-]*)'
    }

)

#Create our installer folder if not already there
if (!(test-path -path $($Config.InstallerFolder))) {
    new-item -ItemType Directory -Path $($Config.InstallerFolder)
}

#$pEntry = $Config.ParseLinks[0]

foreach ($pEntry in $Config.ParseLinks) {
    #Save our matched link
    $pEntry.MatchedLinks = @($DLPage.Links | Where-Object -FilterScript {$_.outerHTML -match $pEntry.LinkPattern})
    #If matched >1 make note of it... going to assume the first one is the right one
    if ($pEntry.MatchedLinks.Count -gt 1) {Write-Output "There was '$($pEntry.MatchedLinks.Count)' for link parsing -> $($pEntry.LinkPattern)"}
    
    #Save our Final Link to download using BaseURI and previously Matched LInk. Removing everything after '?' in links
    $pEntry.FinalLink = ("$($Config.BaseURI)/$($pEntry.MatchedLinks[0].href)".Split("?")[0])

    #Save our File Name
    $pEntry.FileName = "$($pEntry.FinalLink.Split('/')[-1])"
    
    #Build our FullDestination once downloaded
    $pEntry.FullDest = "$($Config.InstallerFolder)\$($pEntry.FileName)"


    #Perform download

    #$Replacements = Invoke-Expression $pEntry.InstallRepl

    $pEntry.FinalCommand = $pEntry.InstallCommand -f $(Invoke-Expression $pEntry.InstallRepl)
    $pEntry.FinalUninstall = $pEntry.UninstallCommand -f $(Invoke-Expression $pEntry.UninstallRepl)

}

$Shortcut = [pscustomobject]@{
    Path = "$($env:PUBLIC)\Desktop"
    Name = "TRAFx Communicator"
    }

#$Config.ParseLinks[0].FinalCommand = ""
#$Config.ParseLinks[0].FinalCommand = $Config.ParseLinks[0].InstallCommand -f $Replacments


#Build out our Install and Uninstall Commands
#$Config.ParseLinks[0].InstallCommand = "New-Item -ItemType SymbolicLink -Path `"$($env:PUBLIC)\Desktop`" -Name `"TRAFx Communicator`" -Value $($Config.ParseLinks[0].FullDest)"
#$Config.ParseLinks[0].FinalCommand = $Config.ParseLinks[0].InstallCommand -f $("$($env:PUBLIC)\Desktop"),"TRAFx Communicator",$($Config.ParseLinks[0].FullDest)
#$Config.ParseLinks[0].FinalCommand = $Config.ParseLinks[0].InstallCommand -f $("$($env:PUBLIC)\Desktop"),"TRAFx Communicator",$($Config.ParseLinks[0].FullDest)

#$Config.ParseLinks[0].FinalUninstall = $Config.ParseLinks[0].UninstallCommand -f $("$($env:PUBLIC)\Desktop"),"TRAFx Communicator"
