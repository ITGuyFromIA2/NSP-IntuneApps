function Read-NSPAssignmentModeAndIntent {
    <#
    .SYNOPSIS
        Prompts for Mode and Intent for one assignment entry.
    .DESCRIPTION
        Honors the TargetType restrictions IntuneWin32App's underlying cmdlets enforce: All
        Users/All Devices assignments are always Include (no "exclude everyone" concept) and
        never support the availableWithoutEnrollment intent.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$TargetType)

    if ($TargetType -eq 'Group') {
        Write-Host '[1] Include  [2] Exclude'
        $modeChoice = Read-NSPMenuChoice -Prompt 'Assignment mode' -Allowed @('1', '2') -Default '1'
        $mode = if ($modeChoice -eq '2') { 'Exclude' } else { 'Include' }
    } else {
        Write-Host "All Users/All Devices assignments are always Include (Intune has no 'exclude everyone' concept)." -ForegroundColor DarkGray
        $mode = 'Include'
    }
    if ($TargetType -eq 'Group') {
        Write-Host '[1] Required  [2] Available  [3] Uninstall  [4] Available without enrollment'
        $intentChoice = Read-NSPMenuChoice -Prompt 'Intent' -Allowed @('1', '2', '3', '4') -Default '1'
        $intent = @{ '1' = 'required'; '2' = 'available'; '3' = 'uninstall'; '4' = 'availableWithoutEnrollment' }[$intentChoice]
    } else {
        Write-Host '[1] Required  [2] Available  [3] Uninstall'
        $intentChoice = Read-NSPMenuChoice -Prompt 'Intent' -Allowed @('1', '2', '3') -Default '1'
        $intent = @{ '1' = 'required'; '2' = 'available'; '3' = 'uninstall' }[$intentChoice]
    }
    [pscustomobject]@{ Mode = $mode; Intent = $intent }
}
