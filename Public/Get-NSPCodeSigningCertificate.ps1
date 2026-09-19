function Get-NSPCodeSigningCertificate {
    <#
    .SYNOPSIS
        Resolves the active local signing certificate by its configured exact thumbprint.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$ImportIfMissing
    )

    $configuration = Get-NSPCodeSigningConfiguration -RepoRoot $RepoRoot
    Resolve-NSPCodeSigningCertificate -Configuration $configuration -ImportIfMissing:$ImportIfMissing
}
