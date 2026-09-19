[CmdletBinding()]
param()

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$parseErrors = [System.Collections.Generic.List[object]]::new()
foreach ($file in Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Filter '*.ps1') {
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
    throw "$($parseErrors.Count) PowerShell parser error(s) found."
}

$windowsPowerShell = Get-Command 'powershell.exe' -ErrorAction SilentlyContinue
if ($windowsPowerShell) {
    & $windowsPowerShell.Source -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Test-WindowsPowerShell51.ps1') -RepoRoot $repoRoot
    if ($LASTEXITCODE -ne 0) { throw 'Windows PowerShell 5.1 compatibility check failed.' }
} else {
    Write-Warning 'Windows PowerShell 5.1 is unavailable on this host; its parser/import compatibility check was skipped.'
}

Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force -ErrorAction Stop
$preflight = Test-NSPIntuneAppsPreflight -RepoRoot $repoRoot
$preflight.Results | Format-Table Area, Name, Status, Detail -AutoSize
if (-not $preflight.Passed) { throw 'Repository preflight has blockers.' }

if (Get-Module -ListAvailable Pester | Where-Object Version -ge ([version]'5.0.0')) {
    $result = Invoke-Pester -Path (Join-Path $repoRoot 'Tests') -PassThru
    if ($result.FailedCount -gt 0) { throw "$($result.FailedCount) Pester test(s) failed." }
} else {
    Write-Warning 'Pester 5+ is not installed; parser, module import, and preflight checks completed.'
}
