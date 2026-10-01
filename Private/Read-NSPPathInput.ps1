function Read-NSPPathInput {
    <#
    .SYNOPSIS
        Read-Host for a file or folder path, tolerant of Explorer's "Copy as path" quoting.
    .DESCRIPTION
        Explorer's "Copy as path" (and shift+right-click) wraps the path in double quotes, which
        Read-Host returns literally - so Test-Path then looks for a file whose name contains the
        quote characters. Trims surrounding whitespace and one layer of matching quotes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Prompt
    )

    $value = ([string](Read-Host $Prompt)).Trim()
    if ($value.Length -ge 2 -and (($value[0] -eq '"' -and $value[-1] -eq '"') -or ($value[0] -eq "'" -and $value[-1] -eq "'"))) {
        $value = $value.Substring(1, $value.Length - 2).Trim()
    }
    $value
}
