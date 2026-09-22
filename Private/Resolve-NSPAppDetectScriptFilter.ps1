function Resolve-NSPAppDetectScriptFilter {
    <#
    .SYNOPSIS
        Resolves the detection-script filename filter, tolerating both the current
        DetectScript_Filter settings key and the older Filter_DetectScript key.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$AppName,
        [Parameter(Mandatory)]$VariableConfig
    )

    if (-not [string]::IsNullOrWhiteSpace([string]$VariableConfig.DetectScript_Filter)) {
        return [string]$VariableConfig.DetectScript_Filter
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$VariableConfig.Filter_DetectScript)) {
        return [string]$VariableConfig.Filter_DetectScript
    }
    throw "App '$AppName' does not declare a detection script filter (DetectScript_Filter or Filter_DetectScript)."
}
