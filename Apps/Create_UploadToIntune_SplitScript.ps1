#Hashtable to store settings in
    $MasterSettings = @{}

#Get the current working DIR
    if ($psISE) {$MasterSettings.dir = Split-Path -Path $psISE.CurrentFile.FullPath    #IF running in ISE, with line by line execution this will work
    } else {$MasterSettings.dir = $PSScriptRoot} 

    Import-Module -Name IntuneWin32App

#DotSource the Code Signing Certificate & Graph Connection settings - SHOULD be in 'GlobalSettings.ps1' under main 'Applications' folder
    .(get-childitem -path "$($MasterSettings.dir)" -filter "*ConnectionSettings*.ps1" -Recurse:$False).FullName

#Group names used for all Assignements
    $MasterSettings.Assign_DeviceGroup = "Group-MDM_Dynamic_AutoPilot_LTs";             #Assign to Device Group for auto-install
    $MasterSettings.Available_PeopleGroup = "Group-MDM_Dynamic_AllLicensed_Users";    #Assign to People Group for manual installs / reinstalls

#FILTER used to Find all (or filtered) 'SplitScriptSettings' PoSH files in subdirectories for processing and upload
    $MasterSettings.AppEntry_Filter = "*_SplitScriptSettings.ps1"
    #$MasterSettings.AppEntry_Filter = "ManualIntuneSync_SplitScriptSettings.ps1"

#Find all (or filtered) 'SplitScriptSettings' PoSH files in subdirectories for processing and upload
    $MasterSettings.AppsToProcess = @(Get-ChildItem -Path "$($MasterSettings.dir)" -Recurse -Filter $($MasterSettings.AppEntry_Filter) -Exclude "ApplicationTemplate")
#$NeedsProcessed = $MasterSettings.AppsToProcess[0]

#Don't think this one's used
    $AppCollection = @()
#Used in first step of processing AppsToProcess. Will hold all read in information PRIOR to sorting
    $InterimCollection = @()
<#
    #Run this line manually if you want to step through AppsToProcess Manually
        $i=0; $NeedsProcessed = $MasterSettings.AppsToProcess[$i]

    #Run this line manually to iterate to the next entry
        $i++; $NeedsProcessed = $MasterSettings.AppsToProcess[$i]
#>


#Loop through $MasterSettings.AppsToProcess:
    #1. read in all
    #2. Prepare all packages for upload / rules associated / etc.
    #3. Put into 'Interim Collection'
foreach ($NeedsProcessed in $MasterSettings.AppsToProcess) {
    #Output current file being processed
        write-output "************************* $($NeedsProcessed.Name) *************************"
    
    #VariableConfig doesn't exist yet... but I need to set the Directory for the subscript... will be stored permanenntly after DotSource
        $TempBase = $NeedsProcessed.Directory.FullName

    #DotSource the App PoSH Config File
        ."$($NeedsProcessed.FullName)"
    
    #Set BaseDir in VariableConfig... VariableConfig comes FROM the AppConfig
        $VariableConfig.BaseDir = $NeedsProcessed.Directory.FullName
    
    #Find the PNG image in the App BaseDir
        $VariableConfig.ImagePath = (get-childitem -path $VariableCOnfig.BaseDir -Filter "*.png").FullName

    #Loop through Assignments, resolving groups to OIDs
        foreach ($Assignment in $VariableConfig.AssignmentColl) {
            #All Include assignments
                foreach ($Group in $Assignment.GroupName_Include) {
                    $Assignment.GroupOIDs_Include += (Get-AzureADGroup -SearchString $($Group)).objectID
                }
            #All Exclude Assignments
                foreach ($Group in $Assignment.GroupName_Exclude) {
                    $Assignment.GroupOIDs_Exclude += (Get-AzureADGroup -SearchString $($Group)).objectID
                }
        }


    #Get list of files that need signing... depending on 'DetectionStyle' will have different needs
        $VariableConfig.ToSign = @()
        if ($VariableConfig.DetectionStyle -eq "Script") {
            #DETECT scripts
                $VariableConfig.ToSign += @(get-childitem -path "$($VariableConfig.BaseDir)\Detect" -Filter $VariableConfig.DetectScript_Filter)
            #SOURCE Scripts
                $VariableConfig.ToSign += @(get-childitem -path "$($VariableConfig.BaseDir)\Source" -Filter $VariableConfig.PoSH.Sign_SourceFilter)
        
            #Perform Signing
                foreach ($Sign in $VariableConfig.ToSign) {
                    Set-AuthenticodeSignature -FilePath $Sign.FullName -Certificate $codeCertificate -TimeStampServer http://timestamp.digicert.com
                 }
        }


    #Regenerate IntuneWin File... first some variable composition
        $VariableConfig.IntuneWinApp = @{}
        $VariableConfig.IntuneWinApp.SourceDIR = "$($VariableConfig.BaseDir)\Source"
        $VariableConfig.IntuneWinApp.SetupFile = 
        $VariableConfig.IntuneWinApp.OutDIR = "$($VariableConfig.BaseDir)\Package"
   

    #Get the 'SourcePS1' which is used as the setup file
        $VariableConfig.SetupFile = get-childitem -path "$($VariableConfig.IntuneWinApp.SourceDIR)" -Filter $VariableConfig.SetupFile_Filter


#Replace {0} placeholders with install and uninstall PS1 files
    #POSH
    if ($VariableConfig.SetupType -eq "PoSH") {
        #Base PoSH Shell. Will likely end up with a 32-bit shell in a 64-bit world.
            #Basically only matters when dealing with registry or things in System32
            $VariableConfig.installCommandLine = "PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{0}"""
            $VariableConfig.uninstallCommandLine = "PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{0}"""

        #Get the 'UninstallPS1' which is used to remove
            $UninstallPS1 = get-childitem -path "$($VariableConfig.IntuneWinApp.SourceDIR)" -Filter $VariableConfig.PoSH.UninstallFile_Filter

        #Replace the stock install strings with the replacement PS1 files
            $VariableConfig.installCommandLine = ($VariableConfig.installCommandLine -f $($VariableConfig.SetupFile))
            $VariableConfig.uninstallCommandLine = ($VariableConfig.uninstallCommandLine -f $UninstallPS1)

        #If there's arguments... append them
            if ($($VariableConfig.PoSH.Args)) {
                $VariableConfig.installCommandLine = (-join($VariableConfig.installCommandLine," ",$VariableConfig.PoSH.Args_String))
                $VariableConfig.uninstallCommandLine = (-join($VariableConfig.uninstallCommandLine," ",$VariableConfig.PoSH.Args_String)) 
            }
    #POSH_sysnative
    } elseif ($VariableConfig.SetupType -eq "PoSH_sysnative") {
        #Base PoSH Shell. Will likely end up with a 32-bit shell in a 64-bit world.
            #Basically only matters when dealing with registry or things in System32
            #$VariableConfig.installCommandLine = "$env:windir\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{0}"""
            $VariableConfig.uninstallCommandLine = "$env:windir\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{0}"""
            $VariableConfig.installCommandLine = "$($env:windir)\SysNative\WindowsPowershell\v1.0\PowerShell.exe -NoProfile -ExecutionPolicy ByPass -File .\{0}"

        #Get the 'UninstallPS1' which is used to remove
            $UninstallPS1 = get-childitem -path "$($VariableConfig.IntuneWinApp.SourceDIR)" -Filter $VariableConfig.PoSH.UninstallFile_Filter

        #Replace the stock install strings with the replacement PS1 files
            $VariableConfig.installCommandLine = ($VariableConfig.installCommandLine -f $($VariableConfig.SetupFile))
            $VariableConfig.uninstallCommandLine = ($VariableConfig.uninstallCommandLine -f $UninstallPS1)

        #This was iriginally just POSH... hopefully don't mess something up here
        #If there's arguments... append them
            if ($($VariableConfig.PoSH.Args)) {
                $VariableConfig.installCommandLine = (-join($VariableConfig.installCommandLine," ",$VariableConfig.PoSH.Args_String))
                $VariableConfig.uninstallCommandLine = (-join($VariableConfig.uninstallCommandLine," ",$VariableConfig.PoSH.Args_String)) 
            }
    }

    #Create the new IntuneWinApp file
        $VariableConfig.IntuneWinApp.WinFile = New-IntuneWin32AppPackage -SourceFolder $VariableConfig.IntuneWinApp.SourceDIR -SetupFile $($VariableConfig.SetupFile) -OutputFolder $VariableConfig.IntuneWinApp.OutDIR -Verbose -Force

    #Get some metadata about the IntuneWinApp file
        $VariableConfig.IntuneWinApp.WinMetaData = get-IntuneWin32AppMetaData -filepath $($VariableConfig.IntuneWinApp.WinFile.Path)

    #Create the detection Rule
        #Script
        if ($VariableConfig.DetectionStyle -eq "Script") {
            #Get path to DetectScript
                $DetectScript = get-childitem -path "$($VariableConfig.BaseDir)\Detect" -Filter $VariableConfig.Filter_DetectScript
            #Create the rule based on variables
                $VariableConfig.IntuneWinApp.DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $($DetectScript.FullName) -EnforceSignatureCheck:$($VariableCOnfig.EnforceSignature_Detection) -RunAs32Bit:$($VariableConfig.RunAs32Bit_Detection)
    
        #Registry
        } elseif($VariableConfig.DetectionStyle -like "Registry*") {
            #Exist -> Registry Entry
                if ($VariableConfig.DetectionStyle -like "*Exist") {
                    #Registry, Exist - Detection Rule
                    $VariableConfig.IntuneWinApp.DetectionRule = New-IntuneWin32AppDetectionRuleRegistry -DetectionType exists -Existence -KeyPath $($VariableConfig.Detection_KeyPath)  -ValueName $($VariableConfig.Detection_ValueName) 
                }
            #Other Types of Registry

        } else {
        

        }

    #Compose the platform requirement rule (usually wide open all PCs)
        $VariableConfig.IntuneWinApp.RequirementRule = New-IntuneWin32AppRequirementRule -Architecture $VariableConfig.REQ_Architecture -MinimumSupportedWindowsRelease $VariableConfig.REQ_MinWindowsRelase

    #Generate the App Icon
        $VariableConfig.IntuneWinApp.AppIcon = New-IntuneWin32AppIcon -FilePath "$($VariableConfig.ImagePath)"

    #Find if there's an existing App out there to replace
        $VariableConfig.ExistingApp = $null
        $VariableConfig.ExistingApp = get-intunewin32app -DisplayName $VariableConfig.DisplayName | Where-Object -Property DisplayName -eq $VariableConfig.DisplayName | Select-Object -Property *

    #Store the built app items into interim collection for sorting
        $InterimCollection += $VariableConfig
}

#Store all Apps from InterimCollection that have NO AppDependencies
    $FinalCollection = @( $InterimCollection | Where-Object -FilterScript {$_.AppDependency -eq $null} )
#Store all Apps from Interim Collection that DO Have AppDependencies
    $HasDep = @( $InterimCollection | Where-Object -FilterScript {$_.AppDependency -ne $null} )
    <#
    #Count the apps without dependencies
        $InterimCollection.Count
    #Count the apps without dependencies
        $FinalCollection.Count
    #>
#This gets a little messy... and could likely be done better
    if ($InterimCollection.count -gt 1) {
        #(Pre)Reset $i / numRuns / keepGoing
            $i=0; $KeepGoing = $true; $numRuns=0
        #Loop through and sort out Apps from HasDep into Interim once the dependcy is present
            do {
                #If dependency is present
                if ($HasDep[$i].AppDependency.AppName -in $($FinalCollection.DisplayName)) {
                    #Add it to finalcollection
                        $FinalCollection += $HasDep[$i]
                    #Store it temporarily
                        $TempArr = $HasDep
                    #Reset HasDep
                        $HasDep = @()

                    #Loop through all in TempArr and DON'T add the current one 
                        #This is how we delete one entry
                        for ($j=0; $j -lt $TempArr.Count; $j++) {
                            if (!($j -eq $i)) {
                                $HasDep += $TempArr[$j]
                            }
                        }
                #Otherwise... increment $i
                } else {$i++}

        #If $i bigger than $HasDep count ... reset it
            if ($i -ge $HasDep.Count -and $i -gt 0) {$i=0; Write-Output "Reset I"}
        #increment NumRuns
            $numRuns++; Write-Output "on Run $($numRuns)" 

        #This is to handle when HasDep = 0
        if ($HasDep.count -lt 1) {
            $KeepGoing = $False

        #This is when it is EXACTLY 1 and large numRuns
        } elseif ($HasDep.count -eq 1 -and $numRuns -gt 1000) {
            $FinalCollection += $HasDep[$i]
            $TempArr = $HasDep
            $HasDep = @()
            for ($j=0; $j -lt $TempArr.Count; $j++) {
                if (!($j -eq $i)) {
                    $HasDep += $TempArr[$j]
                }
            }
        }
        } while ($keepGoing)
    } else {
        #Otherwise... no matches... somehow you ended up here
        $FinalCollection = $InterimCollection

    }
    <#
    $FinalCollection.Count
    #>

<#
#Now that all apps are sorted... add them
$i=0; $VariableConfig = $FinalCollection[$i]

$i++; $VariableConfig = $FinalCollection[$i]

$i=7; $VariableConfig = $FinalCollection[$i]
$VariableConfig.displayname
#>


    foreach ($VariableConfig in $FinalCollection) {
    #$Dependent_Regex = '"Message": "Cannot delete this app as it is the child of another app: (?<DependentApp>[a-zA-Z0-9-]{1,40})\.'
    $Dependent_Apps = @()
    #handle Existing Apps and dependencies
        if ($($VariableConfig.ExistingApp)) {
            #This likely needs to handle the other way of relationships... this gets CHILD? relationships
                $Dependent_Apps = @((get-IntuneWin32AppDependency -id $($VariableConfig.ExistingApp).id -ErrorAction SilentlyContinue))
                
                if ($Dependent_Apps) {
                    $VariableConfig.FinalDependencies = @()

                    $Parent = @($Dependent_Apps | Where-Object -FilterScript {$_.targetType -eq "parent"})
                    $Child = @($Dependent_Apps | Where-Object -FilterScript {$_.targetType -eq "child"})

                    foreach ($app in $Parent) {
                        $VariableConfig.FinalDependencies += [pscustomobject]@{
                            DependencyType = $App.dependencyType
                            DependencyAppID = "{0}"
                            TargetID = $app.targetId
                            Replace="DependencyAppID"
                            #OrigDepID=$($VariableConfig.ExistingApp).id
                            OrigDepID=$app.targetId
                        }
                    }

                    foreach ($app in $Child) {
                        $VariableConfig.FinalDependencies += [pscustomobject]@{
                            DependencyType = $App.dependencyType
                            DependencyAppID = $app.targetId
                            TargetID = "{0}"
                            Replace="TargetID"
                            OrigDepID=$($VariableConfig.ExistingApp).id
                        }
                    }

                    foreach ($Dep in $VariableConfig.FinalDependencies) {
                        remove-IntuneWin32AppDependency -id $($Dep.OrigDepID)

                    }
                    #start-sleep -Seconds 15
                    $($VariableConfig.ExistingApp).id | %{remove-intunewin32app -ID $_ -ErrorVariable +ErrorVar}
                    }
    } 



    $VariableConfig.IntuneWinApp.Win32App = add-IntuneWin32App -FilePath $(($VariableConfig.IntuneWinApp.WinFile).Path) -DisplayName $($VariableConfig.DisplayName) -Description $($VariableConfig.Description) -Publisher $($VariableConfig.Publisher) -InstallExperience $($VariableConfig.InstallExperience) -RestartBehavior $($VariableConfig.RestartExperience) -DetectionRule $($VariableConfig.IntuneWinApp.DetectionRule) -RequirementRule $($VariableConfig.IntuneWinApp.RequirementRule) -InstallCommandLine $($VariableConfig.installCommandLine) -UninstallCommandLine $($VariableConfig.uninstallCommandLine) -Icon $($VariableConfig.IntuneWinApp.AppIcon) -CompanyPortalFeaturedApp $($VariableConfig.IsFeatured) -CategoryName $($VariableConfig.Category) -Verbose


                    #$Dep = $VariableConfig.FinalDependencies[0]
                foreach ($Dep in $VariableConfig.FinalDependencies) {
                    #remove-IntuneWin32AppDependency -id $Dep.OrigDepID
                    $Dep."$($Dep.Replace)" = $($VariableConfig.IntuneWinApp.Win32App.id)
                    #$TempDep = New-IntuneWin32AppDependency -DependencyType $($Dep.DependencyType) -ID $($Dep.DependencyAppID)
                    #Add-IntuneWin32AppDependency -id $($Dep.TargetID) -Dependency $Depend
                    Add-IntuneWin32AppDependency -id $($Dep.TargetID) -Dependency (New-IntuneWin32AppDependency -DependencyType $($Dep.DependencyType) -ID $($Dep.DependencyAppID))
                }


    if ($VariableConfig.AppDependency) {
    
        $VariableConfig.AppDependency.AppID = (get-intunewin32app -DisplayName $VariableConfig.AppDependency.AppName | Where-Object -Property DisplayName -eq $VariableConfig.AppDependency.AppName).id
        $Depend = New-IntuneWin32AppDependency -DependencyType AutoInstall -ID $($VariableConfig.AppDependency.AppID)
        Add-IntuneWin32AppDependency -id $($VariableConfig.IntuneWinApp.Win32App.id) -Dependency $Depend

        }
    <#
    if ($Dependent_Apps) {
        foreach ($App in $Dependent_Apps) {
            $Depend = New-IntuneWin32AppDependency -DependencyType AutoInstall -ID $($VariableConfig.IntuneWinApp.Win32App.id)
            Add-IntuneWin32AppDependency -id $($App) -Dependency $Depend
        }
    }
    #>

    foreach ($Assignment in $VariableConfig.AssignmentColl) {
        foreach ($Group in $Assignment.GroupOIDs_Include) {
            Add-IntuneWin32AppAssignmentGroup -Include -ID $(($VariableConfig.IntuneWinApp.Win32App).id) -GroupID $Group -Intent $($Assignment.Intent) -Notification $($Assignment.Nofication) -DeliveryOptimizationPriority $($Assignment.DeliveryOpt)
        }

        foreach ($Group in $Assignment.GroupOIDs_Exclude) {
            Add-IntuneWin32AppAssignmentGroup -Exclude -ID $(($VariableConfig.IntuneWinApp.Win32App).id) -GroupID $Group
        }
    }

    start-sleep -Seconds 15
    #>
    }

#Run this next portion a couple of times to delete all Win32Apps
<#

$Apps = Get-IntuneWin32App
$apps.count
foreach ($app in $Apps) {
    $Dependent_Apps = @((get-IntuneWin32AppDependency -id $($app.id)).targetid)
        
        #$($VariableConfig.ExistingApp).id | %{remove-intunewin32app -ID $_ -ErrorVariable +ErrorVar}
        #$Result
        if ($Dependent_Apps) {
            #$ErrorVar -match $Dependent_Regex
            #$Dependent_Apps += $Matches.DependentApp

            #$Dependent_Apps

            foreach ($AppD in $Dependent_Apps) {
                remove-IntuneWin32AppDependency -id $AppD
            }
          }  
    Remove-IntuneWin32App -id $($App.id)

}

}#>