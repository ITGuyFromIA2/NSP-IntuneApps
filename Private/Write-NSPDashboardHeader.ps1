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
    foreach ($line in $StatusLines) { Write-Host "  $line" }
    if ($StatusLines) { Write-Host '' }
}
