function Resolve-NSPAppBuildPlan {
    <#
    .SYNOPSIS
        Derives IntuneWin32App build inputs from a catalog entry's settings, offline.
    .DESCRIPTION
        Pure function: no Graph calls, no file mutation. Takes the already-loaded
        $VariableConfig (the caller is responsible for dot-sourcing the settings file)
        alongside the catalog entry's Name/SettingsPath/Path and resolves the concrete
        install/uninstall command lines, detection inputs, requirement rule inputs, and
        icon path needed to build and register the Win32 app package.

        SetupType 'PoSH_sysnative' forces the 64-bit PowerShell host via the Sysnative
        file-system-redirector alias, for scripts that must not run under the 32-bit WOW64
        PowerShell IntuneWin32App would otherwise launch on a 64-bit OS (registry/System32
        access is the usual reason) - DCU_DriverScan and FortiClient_ImportConfig both need
        this. Gen1's own sysnative branch used two different, inconsistent command-line shapes
        for install vs. uninstall (dead code, never fixed); this uses one consistent shape for
        both, matching plain PoSH's proven format with only the shell executable swapped in, and
        expands %windir% at client runtime (Intune runs install/uninstall lines via cmd.exe)
        rather than baking in the build machine's own path the way Gen1 did.

        DetectionStyle 'Registry_Exist' builds a KeyPath/ValueName pair for
        New-IntuneWin32AppDetectionRuleRegistry instead of a detection script - FortiClient_
        ImportConfig is Registry_Exist today (with a placeholder KeyPath pending real values).

        SetupType 'MSI' expects SetupFile_Filter to match the .msi itself in Source/ (no separate
        uninstall script - msiexec uninstalls by pointing back at the same file, which reads its
        own ProductCode, so no MSI metadata extraction happens in this pure/offline function).
        DetectionStyle 'MSI' only sets RequiresMsiProductCode - the caller (which already has the
        IntuneWin32App module loaded) is responsible for extracting the real ProductCode via
        Get-MSIMetaData right before building the native MSI detection rule; this function stays a
        module-free, purely offline resolver, matching every other DetectionStyle here.

        $VariableConfig.AdditionalRequirementScript (optional) names one extra script-based
        requirement rule beyond the mandatory Architecture/MinimumSupportedWindowsRelease pair -
        e.g. an OS edition or other check New-IntuneWin32AppRequirementRule's own built-in disk
        space/memory/processor params can't express. Its ScriptFile_Filter is resolved from
        Source/ the same way every other file field here is (glob, require exactly one) into
        AdditionalRequirementScriptPath; every other field on it passes through unresolved for the
        caller to build the actual rule object with (it needs the IntuneWin32App module loaded).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$SettingsPath,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)]$VariableConfig
    )

    $setupType = [string]$VariableConfig.SetupType
    if ($setupType -notin @('PoSH', 'PoSH_sysnative', 'MSI')) {
        throw "App '$Name' uses SetupType '$setupType', which this build resolver does not yet support. Supported: PoSH, PoSH_sysnative, MSI."
    }
    $detectionStyle = [string]$VariableConfig.DetectionStyle
    if ($detectionStyle -notin @('Script', 'Registry_Exist', 'MSI')) {
        throw "App '$Name' uses DetectionStyle '$detectionStyle', which this build resolver does not yet support. Supported: Script, Registry_Exist, MSI."
    }

    $sourceFolder = Join-Path $Path 'Source'
    $detectFolder = Join-Path $Path 'Detect'

    $setupFilter = [string]$VariableConfig.SetupFile_Filter
    if ([string]::IsNullOrWhiteSpace($setupFilter)) { throw "App '$Name' does not declare SetupFile_Filter." }
    $setupFile = @(Get-ChildItem -LiteralPath $sourceFolder -Filter $setupFilter -File -ErrorAction SilentlyContinue)
    if ($setupFile.Count -ne 1) { throw "App '$Name' expected exactly one setup file matching '$setupFilter' in $sourceFolder, found $($setupFile.Count)." }
    $setupFile = $setupFile[0]

    $uninstallFile = $null
    if ($setupType -ne 'MSI') {
        $uninstallFilter = [string]$VariableConfig.PoSH.UninstallFile_Filter
        if ([string]::IsNullOrWhiteSpace($uninstallFilter)) { throw "App '$Name' does not declare PoSH.UninstallFile_Filter." }
        $uninstallFile = @(Get-ChildItem -LiteralPath $sourceFolder -Filter $uninstallFilter -File -ErrorAction SilentlyContinue)
        if ($uninstallFile.Count -ne 1) { throw "App '$Name' expected exactly one uninstall file matching '$uninstallFilter' in $sourceFolder, found $($uninstallFile.Count)." }
        $uninstallFile = $uninstallFile[0]
    }

    $detectFile = $null
    $registryKeyPath = $null
    $registryValueName = $null
    if ($detectionStyle -eq 'Script') {
        $detectFilter = Resolve-NSPAppDetectScriptFilter -AppName $Name -VariableConfig $VariableConfig
        $detectFile = @(Get-ChildItem -LiteralPath $detectFolder -Filter $detectFilter -File -ErrorAction SilentlyContinue)
        if ($detectFile.Count -ne 1) { throw "App '$Name' expected exactly one detection script matching '$detectFilter' in $detectFolder, found $($detectFile.Count)." }
        $detectFile = $detectFile[0]
    } elseif ($detectionStyle -eq 'Registry_Exist') {
        $registryKeyPath = [string]$VariableConfig.Detection_KeyPath
        $registryValueName = [string]$VariableConfig.Detection_ValueName
        if ([string]::IsNullOrWhiteSpace($registryKeyPath)) { throw "App '$Name' uses DetectionStyle 'Registry_Exist' but does not declare Detection_KeyPath." }
    }

    if ($setupType -eq 'MSI') {
        # msiexec uninstalls by pointing back at the same .msi file (it reads the ProductCode from
        # the file itself), so no separate uninstall file and no MSI metadata read belong here -
        # see this function's own .DESCRIPTION for why that extraction stays with the caller.
        $installCommandLine = 'msiexec.exe /i "{0}" /quiet /norestart' -f $setupFile.Name
        $uninstallCommandLine = 'msiexec.exe /x "{0}" /quiet /norestart' -f $setupFile.Name
    } else {
        # Intune runs install/uninstall commands from the package's extracted working directory on
        # the client, not the build machine, so only the bare file name belongs in the command line.
        $shellPath = if ($setupType -eq 'PoSH_sysnative') { '%windir%\Sysnative\WindowsPowerShell\v1.0\powershell.exe' } else { 'PowerShell.exe' }
        $installCommandLine = '{0} -ExecutionPolicy Bypass -WindowStyle Hidden -File "{1}"' -f $shellPath, $setupFile.Name
        $uninstallCommandLine = '{0} -ExecutionPolicy Bypass -WindowStyle Hidden -File "{1}"' -f $shellPath, $uninstallFile.Name
    }
    if ($VariableConfig.PoSH.Args) {
        $installCommandLine = '{0} {1}' -f $installCommandLine, $VariableConfig.PoSH.Args_String
        $uninstallCommandLine = '{0} {1}' -f $uninstallCommandLine, $VariableConfig.PoSH.Args_String
    }

    $additionalRequirementScriptPath = $null
    if ($VariableConfig.AdditionalRequirementScript -and $VariableConfig.AdditionalRequirementScript.ScriptFile_Filter) {
        $additionalScriptFilter = [string]$VariableConfig.AdditionalRequirementScript.ScriptFile_Filter
        $additionalScriptFile = @(Get-ChildItem -LiteralPath $sourceFolder -Filter $additionalScriptFilter -File -ErrorAction SilentlyContinue)
        if ($additionalScriptFile.Count -ne 1) { throw "App '$Name' expected exactly one additional requirement script matching '$additionalScriptFilter' in $sourceFolder, found $($additionalScriptFile.Count)." }
        $additionalRequirementScriptPath = $additionalScriptFile[0].FullName
    }

    $iconPath = $null
    if (-not [string]::IsNullOrWhiteSpace([string]$VariableConfig.ImagePath) -and (Test-Path -LiteralPath $VariableConfig.ImagePath)) {
        $iconPath = [string]$VariableConfig.ImagePath
    } else {
        $fallbackIcon = @(Get-ChildItem -LiteralPath $Path -Filter '*.png' -File -ErrorAction SilentlyContinue) | Select-Object -First 1
        if ($fallbackIcon) { $iconPath = $fallbackIcon.FullName }
    }

    [pscustomobject]@{
        AppName                          = $Name
        SourceFolder                     = $sourceFolder
        SetupFileName                    = $setupFile.Name
        SetupFilePath                    = $setupFile.FullName
        UninstallFileName                = $uninstallFile.Name
        InstallCommandLine               = $installCommandLine
        UninstallCommandLine             = $uninstallCommandLine
        DetectionStyle                   = $detectionStyle
        DetectionScriptPath              = if ($detectFile) { $detectFile.FullName } else { $null }
        RegistryKeyPath                  = $registryKeyPath
        RegistryValueName                = if ($registryValueName) { $registryValueName } else { $null }
        EnforceSignatureDetection        = [bool]$VariableConfig.EnforceSignature_Detection
        RunAs32BitDetection              = [bool]$VariableConfig.RunAs32Bit_Detection
        RequirementArchitecture          = [string]$VariableConfig.REQ_Architecture
        RequirementMinimumWindowsRelease = [string]$VariableConfig.REQ_MinWindowsRelase
        RequirementMinFreeDiskSpaceMB    = if ($VariableConfig.REQ_MinFreeDiskSpaceMB) { [int]$VariableConfig.REQ_MinFreeDiskSpaceMB } else { $null }
        RequirementMinMemoryMB           = if ($VariableConfig.REQ_MinMemoryMB) { [int]$VariableConfig.REQ_MinMemoryMB } else { $null }
        RequirementMinProcessors         = if ($VariableConfig.REQ_MinProcessors) { [int]$VariableConfig.REQ_MinProcessors } else { $null }
        RequirementMinCPUSpeedMHz        = if ($VariableConfig.REQ_MinCPUSpeedMHz) { [int]$VariableConfig.REQ_MinCPUSpeedMHz } else { $null }
        AdditionalRequirementScriptPath  = $additionalRequirementScriptPath
        AdditionalRequirementScript      = $VariableConfig.AdditionalRequirementScript
        IconPath                         = $iconPath
    }
}
