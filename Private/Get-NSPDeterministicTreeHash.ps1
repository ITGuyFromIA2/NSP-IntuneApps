function Get-NSPDeterministicTreeHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][System.IO.FileInfo[]]$File
    )

    $rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $records = foreach ($item in @($File)) {
        $fullPath = [IO.Path]::GetFullPath($item.FullName)
        if (-not $fullPath.StartsWith($rootPath, [StringComparison]::OrdinalIgnoreCase)) { throw "File is outside the hash root: $fullPath" }
        $relative = $fullPath.Substring($rootPath.Length).Replace('\','/').ToLowerInvariant()
        "$relative|$(Get-NSPDeterministicFileHash -LiteralPath $fullPath)"
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes((@($records | Sort-Object) -join "`n"))
    $sha = [Security.Cryptography.SHA256]::Create()
    try { ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-','') }
    finally { $sha.Dispose() }
}
