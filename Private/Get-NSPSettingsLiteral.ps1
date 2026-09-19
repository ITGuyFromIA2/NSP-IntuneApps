function Get-NSPSettingsLiteral {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SettingsPath,
        [Parameter(Mandatory)][ValidateSet('DisplayName','Publisher')][string]$Name
    )

    $text = Get-Content -LiteralPath $SettingsPath -Raw
    $pattern = '(?m)^\s*\$VariableConfig\.' + [regex]::Escape($Name) + '\s*=\s*(?<quote>["''])(?<value>.*?)\k<quote>\s*(?:#.*)?$'
    $match = [regex]::Match($text, $pattern)
    if (-not $match.Success) { return $null }
    $match.Groups['value'].Value.Replace("''", "'").Replace('`"', '"')
}
