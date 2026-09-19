$VariableConfig = @{}
$VariableConfig.DisplayName = 'Remove LG Easy Guide'
$VariableConfig.Description = 'Removes the preinstalled LG Easy Guide application when present.'
$VariableConfig.Publisher = 'Network Systems Plus, Inc.'
$VariableConfig.IsFeatured = $false
$VariableConfig.Category = @('Computer Management')
$VariableConfig.SetupType = 'PoSH'
$VariableConfig.InstallExperience = 'system'
$VariableConfig.RestartExperience = 'suppress'
$VariableConfig.REQ_Architecture = 'All'
$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
$VariableConfig.DetectionStyle = 'Script'
$VariableConfig.DetectScript_Filter = 'Detect-*.ps1'
$VariableConfig.SetupFile_Filter = 'Install-*.ps1'
$VariableConfig.PoSH = @{ Sign_SourceFilter='*.ps1'; UninstallFile_Filter='Uninstall-*.ps1' }
$VariableConfig.EnforceSignature_Detection = $true
$VariableConfig.RunAs32Bit_Detection = $false
$VariableConfig.AssignmentColl = @()
