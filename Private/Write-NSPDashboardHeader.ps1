function Write-NSPDashboardHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Title,
        [string[]]$StatusLines
    )

    Clear-Host
    Write-Host ('=' * 72) -ForegroundColor Cyan
    Write-Host ("  {0}" -f $Title) -ForegroundColor Cyan
    Write-Host ('=' * 72) -ForegroundColor Cyan
    foreach ($line in $StatusLines) {
        $color = if ($line -match '^Preflight:') { if ($line -match 'READY') { 'Green' } else { 'Red' } }
                 elseif ($line -match '^Safety:') { 'DarkGray' }
                 elseif ($line -match '\b[1-9]\d*\s+(need attention|attention)\b') { 'Yellow' }
                 else { 'Gray' }
        Write-Host "  $line" -ForegroundColor $color
    }
    if ($StatusLines) { Write-Host '' }
}
