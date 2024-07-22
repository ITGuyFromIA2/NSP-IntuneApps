#$TempBase = "C:\Users\chartiert\Network Systems Plus Inc\Customer Projects - Documents\CONTOSO\IntuneWindows\Applications\RemoteDesktop-Shortcut"

#Begin App Variables
$VariableConfig = @{}

$RDSName = "GMRDS02"

$VariableConfig.DisplayName = "$($RDSName) - Remote Desktop Shortcut"
$VariableConfig.Description = ("Creates RDS Shortcut on Public Desktop to $($RDSName).gm.nsp")
$VariableConfig.Publisher = "Network Systems Plus, Inc."
$VariableConfig.IsFeatured = $True

$VariableConfig.ImagePath

#You can choose one or more of the categories. Not sure yet what happens if you choose none
$VariableConfig.Category = @()
    #$VariableConfig.Category += "Books & Reference"
    $VariableConfig.Category += "Business"
    $VariableConfig.Category += "Computer Management"
    #$VariableConfig.Category += "Collaboration & Social"
    #$VariableConfig.Category += "Data Management"
    #$VariableConfig.Category += "Development & Design"
    #$VariableConfig.Category += "Photos & Media"
    #$VariableConfig.Category += "Productivity"
    #$VariableConfig.Category += "Other Apps"


$VariableConfig.SetupType = "PoSH"
#MAYBE make a change, and if empty then assume same as SetupType
    #$VariableConfig.Setup_installSyle = ""
    #$VariableConfig.Setup_uninstallSyle = ""
    
#Can Be: 'system' / 'user'
    $VariableConfig.InstallExperience = 'system' 
    #$VariableConfig.InstallExperience = 'user' 

#Can Be: 'allow' / 'basedOnReturnCode' / 'force' / 'suppress'
    #$VariableConfig.RestartExperience = 'allow'  
    #$VariableConfig.RestartExperience = 'basedOnReturnCode'  
    #$VariableConfig.RestartExperience = 'force'  
    $VariableConfig.RestartExperience = 'suppress'  

#Can Be: 'All' / 'x64' / 'x86'
    $VariableConfig.REQ_Architecture = "All"
    #$VariableConfig.REQ_Architecture = "x64"
    #$VariableConfig.REQ_Architecture = "x86"

#Can Be: 'w10_1607' / 'w10_1703' / 'w10_1709' / 'w10_2004' / 'w10_20H2' / 'w10_21H1' / 'w10_21H2' / 'w11_21H2' / 'w11_22H2' 
    $VariableConfig.REQ_MinWindowsRelase = "W10_1607"  

#Need to flesh out the other styles. I believe two others 'Registry' and 'MSI code'
    $VariableConfig.DetectionStyle = "Script"
    $VariableConfig.Filter_DetectScript = "Detect_*.ps1"

#Assignment collection. This holds ALL assignments
$VariableConfig.AssignmentColl = @()
    #Template for assignments
        <#
        $VariableConfig.AssignmentColl += [pscustomobject]@{
            GroupName_Include = @("GroupNameHere")
            GroupName_Exclude = @()     #Or Leave Empty
            Intent = "required"         #Can Be: 'available' / 'required' / 'uninstall'
            Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
            DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
        }
        #>

$VariableConfig.AssignmentColl += [pscustomobject]@{
    GroupName_Include = @($($MasterSettings.Assign_DeviceGroup))
    GroupName_Exclude = @()     #Or Leave Empty
    GroupOIDs_Include = @()
    GroupOIDs_Exclude = @()
    Intent = "required"         #Can Be: 'available' / 'required' / 'uninstall'
    Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
    DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
}

$VariableConfig.AssignmentColl += [pscustomobject]@{
    GroupName_Include = @($($MasterSettings.Available_PeopleGroup))
    GroupName_Exclude = @()     #Or Leave Empty
        GroupOIDs_Include = @()
    GroupOIDs_Exclude = @()
    Intent = "available"         #Can Be: 'available' / 'required' / 'uninstall'
    Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
    DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
}



$VariableConfig.PoSH = @{}
$VariableConfig.DetectScript_Filter = "Detect_*.ps1"
$VariableConfig.PoSH.Sign_SourceFilter = "*.ps1"

$VariableConfig.SetupFile_Filter = "Download*.ps1"
$VariableConfig.PoSH.UninstallFile_Filter = "Uninstall*.ps1"
$VariableConfig.PoSH.Args = @{
ServerName="$($RDSName).gm.nsp"
FullPath="C:\Users\Public\Desktop\$($RDSName).rdp"
}

$TempDetect= get-content -Path $("$TempBase\Detect_RDSShortcut_Source.ps1")
$TempDetect=($TempDetect.replace("{ReplaceMe_Server}","$($VariableConfig.PoSH.Args['ServerName'])")).Replace("{ReplaceMe_FullPath}","$($VariableConfig.PoSH.Args['FullPath'])")
Set-Content -path $("$TempBase\Detect\Detect_RDSShortcut.ps1") -value $TempDetect -Force

$VariableConfig.PoSH.Args_String = [string]::Join(" -",($($VariableConfig.PoSH.Args).GetEnumerator() | %{$_.Name + " """ + $_.Value + """"})) | %{"-$_"}

$VariableCOnfig.EnforceSignature_Detection = $True
$VariableConfig.RunAs32Bit_Detection = $False