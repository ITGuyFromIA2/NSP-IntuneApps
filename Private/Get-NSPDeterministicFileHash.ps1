function Get-NSPDeterministicFileHash {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$LiteralPath)

    $extension = [IO.Path]::GetExtension($LiteralPath).ToLowerInvariant()
    if ($extension -in @('.ps1','.psm1','.psd1','.json','.md','.txt','.xml','.rdp','.cmd','.bat')) {
        $text = Get-Content -LiteralPath $LiteralPath -Raw
        $text = [regex]::Replace($text, '(?ms)^# SIG # Begin signature block.*\z', '')
        $text = $text.Replace("`r`n", "`n").Replace("`r", "`n").TrimEnd("`n") + "`n"
        $bytes = [Text.Encoding]::UTF8.GetBytes($text)
        $sha = [Security.Cryptography.SHA256]::Create()
        try { return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-','') }
        finally { $sha.Dispose() }
    }
    (Get-FileHash -LiteralPath $LiteralPath -Algorithm SHA256).Hash
}
