function Test-NSPInteractiveInstallerCapture {
    <#
    .SYNOPSIS
        Validates an interactive-installer capture without executing it.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]$Path
    )

    process {
        $errors = [Collections.Generic.List[string]]::new()
        $warnings = [Collections.Generic.List[string]]::new()
        $resolvedPath = $null
        $capture = $null

        try {
            $resolvedPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
            $capture = Get-Content -LiteralPath $resolvedPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            $errors.Add("Capture could not be read as JSON: $($_.Exception.Message)")
        }

        if ($capture) {
            if ($capture.SchemaVersion -ne '2.0') { $errors.Add("SchemaVersion must be '2.0'.") }
            if (-not $capture.Installer -or [string]::IsNullOrWhiteSpace($capture.Installer.File)) { $errors.Add('Installer.File is required.') }
            if ($capture.Installer.Sha256 -notmatch '^[A-Fa-f0-9]{64}$') { $errors.Add('Installer.Sha256 must contain 64 hexadecimal characters.') }
            elseif ($capture.Installer.Sha256 -eq ('0' * 64)) { $warnings.Add('Installer.Sha256 is a documentation placeholder.') }
            if ($capture.ExecutionEngine -notin @('AutoIt','AutoHotkey','AutoItOrAutoHotkey')) { $errors.Add('ExecutionEngine is not supported.') }

            $parameters = @($capture.RuntimeParameters)
            $parameterNames = @($parameters | ForEach-Object { $_.Name })
            foreach ($group in $parameterNames | Group-Object | Where-Object Count -gt 1) {
                $errors.Add("Runtime parameter '$($group.Name)' is declared more than once.")
            }
            foreach ($parameter in $parameters) {
                if ($parameter.Name -notmatch '^[A-Za-z][A-Za-z0-9_]*$') { $errors.Add("Invalid runtime parameter name '$($parameter.Name)'.") }
                if ($null -eq $parameter.Sensitive -or $parameter.Sensitive -isnot [bool]) { $errors.Add("Runtime parameter '$($parameter.Name)' needs a Boolean Sensitive value.") }
            }

            $steps = @($capture.Steps)
            if ($steps.Count -eq 0) { $errors.Add('At least one step is required.') }
            $allowedActions = @('Click','SetValue','Select','SendKeys','WaitForWindow','WaitForWindowClose')
            for ($index = 0; $index -lt $steps.Count; $index++) {
                $step = $steps[$index]
                $expectedOrder = $index + 1
                if ($step.Order -ne $expectedOrder) { $errors.Add("Step $expectedOrder has non-sequential Order '$($step.Order)'.") }
                if ($step.Action -notin $allowedActions) { $errors.Add("Step $expectedOrder has unsupported action '$($step.Action)'.") }
                if ([string]::IsNullOrWhiteSpace($step.Window.Title) -and [string]::IsNullOrWhiteSpace($step.Window.Text)) {
                    $errors.Add("Step $expectedOrder must identify a window by title or visible text.")
                }
                if ($step.Window.MatchMode -notin @('Contains','Exact')) { $errors.Add("Step $expectedOrder has invalid MatchMode '$($step.Window.MatchMode)'.") }
                if ($step.TimeoutSeconds -lt 1 -or $step.TimeoutSeconds -gt 3600) { $errors.Add("Step $expectedOrder TimeoutSeconds must be between 1 and 3600.") }

                $requiresValue = $step.Action -in @('SetValue','Select','SendKeys')
                if ($requiresValue -and -not $step.Value) { $errors.Add("Step $expectedOrder action '$($step.Action)' requires a value definition.") }
                if (-not $requiresValue -and $step.Value) { $errors.Add("Step $expectedOrder action '$($step.Action)' must not include a value definition.") }
                if ($step.Value) {
                    if ($step.Value.Source -eq 'RuntimeParameter') {
                        if ($step.Value.Name -notin $parameterNames) { $errors.Add("Step $expectedOrder references undeclared runtime parameter '$($step.Value.Name)'.") }
                    }
                    elseif ($step.Value.Source -eq 'Literal') {
                        if ($null -eq $step.Value.Value) { $errors.Add("Step $expectedOrder literal value is missing.") }
                    }
                    else { $errors.Add("Step $expectedOrder has unsupported value source '$($step.Value.Source)'.") }
                }
            }
        }

        [pscustomobject]@{
            Path     = $resolvedPath
            IsValid  = $errors.Count -eq 0
            Errors   = @($errors)
            Warnings = @($warnings)
            Capture  = $capture
        }
    }
}
