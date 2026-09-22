function Resolve-NSPAppBuildPlan {
    <#
    .SYNOPSIS
        Derives IntuneWin32App build inputs from a catalog entry's settings, offline.
    .DESCRIPTION
        Pure function: no Graph calls, no file mutation. Takes the already-loaded
        $VariableConfig (the caller is responsible for dot-sourcing the settings file)
        alongside the catalog entry's Name/SettingsPath/Path and resolves the concrete
        install/uninstall command lines, detection script, requirement rule inputs, and
        icon path needed to build and register the Win32 app package.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$SettingsPath,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)]$VariableConfig
    )

    if ([string]$VariableConfig.SetupType -ne 'PoSH') {
        throw "App '$Name' uses SetupType '$($VariableConfig.SetupType)', which this build resolver does not yet support. Only 'PoSH' is implemented."
    }
    if ([string]$VariableConfig.DetectionStyle -ne 'Script') {
        throw "App '$Name' uses DetectionStyle '$($VariableConfig.DetectionStyle)', which this build resolver does not yet support. Only 'Script' is implemented."
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

    $detectFilter = Resolve-NSPAppDetectScriptFilter -AppName $Name -VariableConfig $VariableConfig
    $detectFile = @(Get-ChildItem -LiteralPath $detectFolder -Filter $detectFilter -File -ErrorAction SilentlyContinue)
    if ($detectFile.Count -ne 1) { throw "App '$Name' expected exactly one detection script matching '$detectFilter' in $detectFolder, found $($detectFile.Count)." }
    $detectFile = $detectFile[0]

    # Intune runs install/uninstall commands from the package's extracted working directory on
    # the client, not the build machine, so only the bare file name belongs in the command line.
    $installCommandLine = 'PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $setupFile.Name
    $uninstallCommandLine = 'PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $uninstallFile.Name
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
        DetectionScriptPath              = $detectFile.FullName
        EnforceSignatureDetection        = [bool]$VariableConfig.EnforceSignature_Detection
        RunAs32BitDetection              = [bool]$VariableConfig.RunAs32Bit_Detection
        RequirementArchitecture          = [string]$VariableConfig.REQ_Architecture
        RequirementMinimumWindowsRelease = [string]$VariableConfig.REQ_MinWindowsRelase
        IconPath                         = $iconPath
    }
}
