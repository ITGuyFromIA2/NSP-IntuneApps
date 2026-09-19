function Read-NSPMenuChoice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Prompt,
        [Parameter(Mandatory)][string[]]$Allowed,
        [string]$Default
    )

    while ($true) {
        $suffix = if ($Default) { " [$Default]" } else { '' }
        $value = Read-Host "$Prompt$suffix"
        if ([string]::IsNullOrWhiteSpace($value) -and $Default) { return $Default }
        $value = $value.Trim()
        foreach ($candidate in $Allowed) {
            if ($candidate -ieq $value) { return $candidate }
        }
        Write-Host "Choose one of: $($Allowed -join ', ')" -ForegroundColor Yellow
    }
}
