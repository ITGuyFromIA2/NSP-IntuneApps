#Begin App Variables
$VariableConfig = @{}

$VariableConfig.DisplayName = "VLC Media Player"
$VariableConfig.Description = "Downloads and installs the latest version of VLC - Straight from VideoLan's Permalink"
$VariableConfig.Publisher = "Network Systems Plus, Inc."
$VariableConfig.IsFeatured = $True

#You can choose one or more of the categories. Not sure yet what happens if you choose none
$VariableConfig.Category = @()
    #$VariableConfig.Category += "Books & Reference"
    $VariableConfig.Category += "Business"
    #$VariableConfig.Category += "Computer Management"
    #$VariableConfig.Category += "Collaboration & Social"
    #$VariableConfig.Category += "Data Management"
    #$VariableConfig.Category += "Development & Design"
    $VariableConfig.Category += "Photos & Media"
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
    $VariableConfig.RestartExperience = 'basedOnReturnCode'  
    #$VariableConfig.RestartExperience = 'force'  
    #$VariableConfig.RestartExperience = 'suppress'  

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
    GroupName_Include = @("IntuneAllDevices")
    GroupName_Exclude = @()     #Or Leave Empty
    GroupOIDs_Include = @()
    GroupOIDs_Exclude = @()
    Intent = "required"         #Can Be: 'available' / 'required' / 'uninstall'
    Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
    DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
    Filter = @{
        Name = "Corp Ownership or Hybrid"
        Mode = "Include"

    }
}

$VariableConfig.AssignmentColl += [pscustomobject]@{
    GroupName_Include = @("IntuneAllUsers")
    GroupName_Exclude = @()     #Or Leave Empty
        GroupOIDs_Include = @()
    GroupOIDs_Exclude = @()
    Intent = "available"         #Can Be: 'available' / 'required' / 'uninstall'
    Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
    DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
    Filter = @{
        Name = "Corp Ownership or Hybrid"
        Mode = "Include"

    }    
}

$VariableConfig.PoSH = @{}
$VariableConfig.DetectScript_Filter = "Detect_*.ps1"
$VariableConfig.PoSH.Sign_SourceFilter = "*.ps1"

$VariableConfig.SetupFile_Filter = "Download*.ps1"
$VariableConfig.PoSH.UninstallFile_Filter = "Uninstall*.ps1"

$VariableCOnfig.EnforceSignature_Detection = $True
$VariableConfig.RunAs32Bit_Detection = $False