[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$RepoRoot
)

if (-not $RepoRoot) { $RepoRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent | Split-Path -Parent }
$filesChanged = 0
$assignmentsRemoved = 0
foreach ($file in Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'Apps') -Recurse -File -Filter '*_SplitScriptSettings.ps1') {
    $tokens = $null
    $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    if ($errors) { throw "Cannot safely rewrite a settings file with parser errors: $($file.FullName)" }
    $assignments = @($ast.FindAll({
        param($node)
        $node -is [Management.Automation.Language.AssignmentStatementAst] -and
        $node.Operator -eq 'PlusEquals' -and
        $node.Left.Extent.Text -match '^\$VariableConfig\.AssignmentColl$'
    }, $true))
    if ($assignments.Count -eq 0) { continue }

    $text = [IO.File]::ReadAllText($file.FullName)
    $lineEnding = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
    foreach ($assignment in @($assignments | Sort-Object { $_.Extent.StartOffset } -Descending)) {
        $start = $assignment.Extent.StartOffset
        $length = $assignment.Extent.EndOffset - $start
        $text = $text.Remove($start, $length)
        $assignmentsRemoved++
    }
    if ($text -notmatch '(?m)^\s*# Targeting is supplied by the deployment plan\.\s*$') {
        $pattern = '(?m)^([^\S\r\n]*\$VariableConfig\.AssignmentColl[^\S\r\n]*=[^\S\r\n]*@\(\)[^\S\r\n]*)$'
        $text = [regex]::Replace($text, $pattern, "`$1$lineEnding# Targeting is supplied by the deployment plan.", 1)
    }
    if ($PSCmdlet.ShouldProcess($file.FullName, "Remove $($assignments.Count) embedded assignment(s)")) {
        [IO.File]::WriteAllText($file.FullName, $text, [Text.UTF8Encoding]::new($true))
        $filesChanged++
    }
}

[pscustomobject]@{ FilesChanged=$filesChanged; AssignmentsRemoved=$assignmentsRemoved }
