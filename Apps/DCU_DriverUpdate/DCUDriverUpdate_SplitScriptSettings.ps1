<#
#Get the current working DIR
    if ($psISE) {$BaseDir = Split-Path -Path $psISE.CurrentFile.FullPath    #IF running in ISE, with line by line execution this will work
    } else {$BaseDir = $PSScriptRoot} 


#DotSource the Code Signing Certificate & Graph Connection settings - SHOULD be in 'GlobalSettings.ps1' under main 'Applications' folder
    .(get-childitem -path (get-item -path $BaseDir).parent.fullname -filter "*GlobalSettings*.ps1" -Recurse:$False).FullName
#>
#Copy sharedDefs from DCU_Shared AppFolder
    $SharedDefs_Source = (get-childitem -path ((get-childitem -path (get-item -path $($VariableConfig.BaseDir)).parent.fullname -filter "DCU_Shared" -Recurse:$True).FullName) -filter "SharedDefs*").FullName
    $SharedDefs_Dest = "$($VariableConfig.BaseDir)\Source\"
    Copy-Item -Path $SharedDefs_Source -Destination $SharedDefs_Dest -Force


#Begin App Variables
$VariableConfig = @{}

$VariableConfig.DisplayName = "Dell Command | Update - Apply Driver Updates"
$VariableConfig.Description = "Will apply the latest Dell Driver updates"
$VariableConfig.Publisher = "Network Systems Plus, Inc."
$VariableConfig.IsFeatured = $False

$VariableConfig.Category = @()
<#
#//Options: 
    "Books & Reference"
    "Business"
    "Computer Management"
    "Collaboration & Social"
    "Data Management"
    "Development & Design"
    "Photos & Media"
    "Productivity"
    "Other Apps"
#>
#$VariableConfig.Category += "Books & Reference"
#$VariableConfig.Category += "Business"
$VariableConfig.Category += "Computer Management"
#$VariableConfig.Category += "Collaboration & Social"
#$VariableConfig.Category += "Data Management"
#$VariableConfig.Category += "Development & Design"
#$VariableConfig.Category += "Photos & Media"
#$VariableConfig.Category += "Productivity"
#$VariableConfig.Category += "Other Apps"

$VariableConfig.SetupType = "PoSH"

#$VariableConfig.installCommandLine = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{0}"""
#$VariableConfig.uninstallCommandLine = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{0}"""
#$VariableConfig.ImagePath = (@(get-childitem -path $BaseDir -filter "*.png")[0].fullname)




$VariableConfig.InstallExperience = 'system'    #Can Be: 'system' / 'user'
$VariableConfig.RestartExperience = 'basedOnReturnCode'  #Can Be: 'allow' / 'basedOnReturnCode' / 'force' / 'suppress'

$VariableConfig.REQ_Architecture = "All"           #Can Be: 'All' / 'x64' / 'x86'
$VariableConfig.REQ_MinWindowsRelase = "W10_1607"  #Can Be: 'w10_1607' / 'w10_1703' / 'w10_1709' / 'w10_2004' / 'w10_20H2' / 'w10_21H1' / 'w10_21H2' / 'w11_21H2' / 'w11_22H2' 

$VariableConfig.DetectionStyle = "Script"

#Assignment collection. This holds ALL assignments
$VariableConfig.AssignmentColl = @()
    #Template for assignments
        <#
        $AssignmentColl += [pscustomobject]@{
            GroupName_Include = @("GroupNameHere")
            GroupName_Exclude = @()     #Or Leave Empty
            GroupOIDs_Include = @()     #Leave Empty
            GroupOIDs_Exclude = @()     #Leave Empty
            Intent = "required"         #Can Be: 'available' / 'required' / 'uninstall'
            Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
            DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
        }
        #>
$VariableConfig.AssignmentColl += [pscustomobject]@{
    GroupName_Include = @($($MasterSettings.Assign_DeviceGroup))
    GroupName_Exclude = @()     #Or Leave Empty
    GroupOIDs_Include = @()     #Leave Empty
    GroupOIDs_Exclude = @()     #Leave Empty
    Intent = "required"         #Can Be: 'available' / 'required' / 'uninstall'
    Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
    DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
}
$VariableConfig.AssignmentColl += [pscustomobject]@{
    GroupName_Include = @($($MasterSettings.Available_PeopleGroup))
    GroupName_Exclude = @()     #Or Leave Empty
    GroupOIDs_Include = @()     #Leave Empty
    GroupOIDs_Exclude = @()     #Leave Empty
    Intent = "available"         #Can Be: 'available' / 'required' / 'uninstall'
    Nofication = "showall"      #Can Be: 'hideall' / 'showall' / 'showreboot'
    DeliveryOpt = "foreground"  #Can Be: 'foreground' / 'notConfigured'
}

$VariableConfig.PoSH = @{}
$VariableConfig.DetectScript_Filter = "Detect_*.ps1"
$VariableConfig.PoSH.Sign_SourceFilter = "*.ps1"

$VariableConfig.SetupFile_Filter = "Download*.ps1"
$VariableConfig.PoSH.UninstallFile_Filter = "Uninstall*.ps1"

$VariableCOnfig.EnforceSignature_Detection = $True
$VariableConfig.RunAs32Bit_Detection = $False



$VariableConfig.AppDependency = @{
    AppName = "Dell Command | Update - Scan for Driver Updates"
    DependencyType="AutoInstall"
    #DependencyType="Detect"
}
