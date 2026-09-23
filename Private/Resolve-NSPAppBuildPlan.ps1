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
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$SettingsPath,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)]$VariableConfig
    )

    $setupType = [string]$VariableConfig.SetupType
    if ($setupType -notin @('PoSH', 'PoSH_sysnative')) {
        throw "App '$Name' uses SetupType '$setupType', which this build resolver does not yet support. Supported: PoSH, PoSH_sysnative."
    }
    $detectionStyle = [string]$VariableConfig.DetectionStyle
    if ($detectionStyle -notin @('Script', 'Registry_Exist')) {
        throw "App '$Name' uses DetectionStyle '$detectionStyle', which this build resolver does not yet support. Supported: Script, Registry_Exist."
    }

    $sourceFolder = Join-Path $Path 'Source'
    $detectFolder = Join-Path $Path 'Detect'

    $setupFilter = [string]$VariableConfig.SetupFile_Filter
    if ([string]::IsNullOrWhiteSpace($setupFilter)) { throw "App '$Name' does not declare SetupFile_Filter." }
    $setupFile = @(Get-ChildItem -LiteralPath $sourceFolder -Filter $setupFilter -File -ErrorAction SilentlyContinue)
    if ($setupFile.Count -ne 1) { throw "App '$Name' expected exactly one setup file matching '$setupFilter' in $sourceFolder, found $($setupFile.Count)." }
    $setupFile = $setupFile[0]

    $uninstallFilter = [string]$VariableConfig.PoSH.UninstallFile_Filter
    if ([string]::IsNullOrWhiteSpace($uninstallFilter)) { throw "App '$Name' does not declare PoSH.UninstallFile_Filter." }
    $uninstallFile = @(Get-ChildItem -LiteralPath $sourceFolder -Filter $uninstallFilter -File -ErrorAction SilentlyContinue)
    if ($uninstallFile.Count -ne 1) { throw "App '$Name' expected exactly one uninstall file matching '$uninstallFilter' in $sourceFolder, found $($uninstallFile.Count)." }
    $uninstallFile = $uninstallFile[0]

    $detectFile = $null
    $registryKeyPath = $null
    $registryValueName = $null
    if ($detectionStyle -eq 'Script') {
        $detectFilter = Resolve-NSPAppDetectScriptFilter -AppName $Name -VariableConfig $VariableConfig
        $detectFile = @(Get-ChildItem -LiteralPath $detectFolder -Filter $detectFilter -File -ErrorAction SilentlyContinue)
        if ($detectFile.Count -ne 1) { throw "App '$Name' expected exactly one detection script matching '$detectFilter' in $detectFolder, found $($detectFile.Count)." }
        $detectFile = $detectFile[0]
    } else {
        $registryKeyPath = [string]$VariableConfig.Detection_KeyPath
        $registryValueName = [string]$VariableConfig.Detection_ValueName
        if ([string]::IsNullOrWhiteSpace($registryKeyPath)) { throw "App '$Name' uses DetectionStyle 'Registry_Exist' but does not declare Detection_KeyPath." }
    }

    # Intune runs install/uninstall commands from the package's extracted working directory on
    # the client, not the build machine, so only the bare file name belongs in the command line.
    $shellPath = if ($setupType -eq 'PoSH_sysnative') { '%windir%\Sysnative\WindowsPowerShell\v1.0\powershell.exe' } else { 'PowerShell.exe' }
    $installCommandLine = '{0} -ExecutionPolicy Bypass -WindowStyle Hidden -File "{1}"' -f $shellPath, $setupFile.Name
    $uninstallCommandLine = '{0} -ExecutionPolicy Bypass -WindowStyle Hidden -File "{1}"' -f $shellPath, $uninstallFile.Name
    if ($VariableConfig.PoSH.Args) {
        $installCommandLine = '{0} {1}' -f $installCommandLine, $VariableConfig.PoSH.Args_String
        $uninstallCommandLine = '{0} {1}' -f $uninstallCommandLine, $VariableConfig.PoSH.Args_String
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
        IconPath                         = $iconPath
    }
}
