[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RepoRoot
)

if ($PSVersionTable.PSVersion.Major -ne 5) {
    throw "This compatibility check must run under Windows PowerShell 5.1, not $($PSVersionTable.PSVersion)."
}
$parseErrors = New-Object System.Collections.Generic.List[object]
foreach ($file in Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter '*.ps1') {
    if ($file.FullName -like '*\.git\*') { continue }
    $tokens = $null
    $errors = $null
    [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    foreach ($error in $errors) {
        $parseErrors.Add([pscustomobject]@{ File=$file.FullName; Line=$error.Extent.StartLineNumber; Message=$error.Message })
    }
}
if ($parseErrors.Count -gt 0) {
    $parseErrors | Format-Table -Wrap
    throw "$($parseErrors.Count) Windows PowerShell 5.1 parser error(s) found."
}
Import-Module (Join-Path $RepoRoot 'NSP.IntuneApps.psd1') -Force -ErrorAction Stop
Write-Host 'Windows PowerShell 5.1 parser and module import: Pass' -ForegroundColor Green
