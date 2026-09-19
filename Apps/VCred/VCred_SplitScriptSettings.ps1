$VariableConfig = @{}
$VariableConfig.DisplayName = 'Microsoft Visual C++ Redistributable (v14)'
$VariableConfig.Description = 'Installs and maintains the latest Microsoft Visual C++ v14 runtimes for x86 and x64. Legacy side-by-side runtimes are available as an explicit configuration choice.'
$VariableConfig.Publisher = 'Microsoft Corporation'
$VariableConfig.IsFeatured = $false
$VariableConfig.Category = @('Computer Management')
$VariableConfig.SetupType = 'PoSH'
$VariableConfig.InstallExperience = 'system'
$VariableConfig.RestartExperience = 'basedOnReturnCode'
$VariableConfig.REQ_Architecture = 'All'
$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
$VariableConfig.DetectionStyle = 'Script'
$VariableConfig.DetectScript_Filter = 'Detect_*.ps1'
$VariableConfig.SetupFile_Filter = 'DownloadInstall_*.ps1'
$VariableConfig.PoSH = @{ Sign_SourceFilter='*.ps1'; UninstallFile_Filter='Uninstall_*.ps1' }
$VariableConfig.EnforceSignature_Detection = $true
$VariableConfig.RunAs32Bit_Detection = $false
$VariableConfig.AssignmentColl = @()
