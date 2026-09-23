function Read-NSPMenuChoice {
    <#
    .SYNOPSIS
        Prompts until the answer matches one of -Allowed (or -Default on a blank Enter).
    .PARAMETER AllowBack
        Reuses the same 'B'/'Back' convention CA-Manager's wizard prompts already established
        (CAInteractive.ps1's Read-CANonEmpty/Read-CAOptional) rather than inventing a second one.
        When set, 'B' is accepted as an additional valid answer and returned literally - the
        caller checks for it and decides what "back" means (typically: re-run the previous step).
        Only pass this where the step is a genuine, undo-able sequence with nothing mutating
        interleaved before it - same rule CA-Manager's own rollout follows.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Prompt,
        [Parameter(Mandatory)][string[]]$Allowed,
        [string]$Default,
        [switch]$AllowBack
    )

    $effectiveAllowed = if ($AllowBack -and 'B' -notin $Allowed) { @($Allowed) + 'B' } else { $Allowed }

    while ($true) {
        $suffix = if ($Default) { " [$Default]" } else { '' }
        $value = Read-Host "$Prompt$suffix"
        if ([string]::IsNullOrWhiteSpace($value) -and $Default) { return $Default }
        $value = $value.Trim()
        foreach ($candidate in $effectiveAllowed) {
            if ($candidate -ieq $value) { return $candidate }
        }
        Write-Host "Choose one of: $($effectiveAllowed -join ', ')" -ForegroundColor Yellow
    }
}
