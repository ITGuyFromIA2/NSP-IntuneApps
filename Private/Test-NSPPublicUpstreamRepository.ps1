function Test-NSPPublicUpstreamRepository {
    <#
    .SYNOPSIS
        Returns true only when RepoRoot's origin remote is the public NSP-IntuneApps repository.
    .DESCRIPTION
        Used to pick a safe default output location for guided-template generators: the
        public upstream repo defaults to an ignored local folder (UNC paths/client names must
        never reach it), while every downstream fork - the overwhelmingly common case - gets
        the ordinary Apps\ location without an extra prompt or manual move. Never guesses
        "public" when it can't tell (no git, no origin, detached remote); the default in that
        case is the permissive one, since the restrictive default exists to protect one
        specific repository, not as a general precaution.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return $false }
    try {
        $originUrl = git -C $RepoRoot remote get-url origin 2>$null
        if (-not $originUrl) { return $false }
        return [bool]([string]$originUrl -match 'ITGuyFromIA2/NSP-IntuneApps(\.git)?$')
    } catch {
        return $false
    }
}
