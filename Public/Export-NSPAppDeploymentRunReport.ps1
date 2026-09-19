function Export-NSPAppDeploymentRunReport {
    <#
    .SYNOPSIS
        Writes a concise Markdown report from a local deployment run journal.
    .DESCRIPTION
        Transition messages are deliberately omitted because operator-entered messages
        may contain troubleshooting details unsuitable for a durable report.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RunPath,
        [string]$OutputPath
    )

    $resolvedRunPath = (Resolve-Path -LiteralPath $RunPath -ErrorAction Stop).Path
    $run = Get-Content -LiteralPath $resolvedRunPath -Raw | ConvertFrom-Json
    if ($run.RunType -ne 'Win32AppDeployment') { throw "Unsupported run type '$($run.RunType)'." }
    if (-not $OutputPath) { $OutputPath = [IO.Path]::ChangeExtension($resolvedRunPath, '.report.md') }

    $escape = {
        param([object]$Value)
        ([string]$Value).Replace('|','\|').Replace("`r",' ').Replace("`n",' ')
    }
    $entries = @($run.Entries | Sort-Object Order)
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('# NSP IntuneApps deployment run report')
    $lines.Add('')
    $lines.Add("- Run status: **$(& $escape $run.Status)**")
    $lines.Add(('- Tenant: `{0}`' -f (& $escape $run.TenantId)))
    $lines.Add(('- Account: `{0}`' -f (& $escape $run.Account)))
    $lines.Add(('- Created (UTC): `{0}`' -f (& $escape $run.CreatedAtUtc)))
    $lines.Add(('- Last update (UTC): `{0}`' -f (& $escape $run.LastUpdatedAtUtc)))
    $lines.Add(('- Source tracker: `{0}`' -f (& $escape $run.PlanPath)))
    $lines.Add('')
    $lines.Add('This report reflects the local journal. A succeeded stage means the supervising executor reported success; it is not an independent tenant audit.')
    $lines.Add('')
    $lines.Add('| # | App | Planned action | Existing object | Result | Completed stages |')
    $lines.Add('|---:|---|---|---|---|---:|')
    foreach ($entry in $entries) {
        $completedStages = @($entry.Stages | Where-Object Status -eq 'Succeeded').Count
        $lines.Add("| $($entry.Order) | $(& $escape $entry.Name) | $(& $escape $entry.PlannedAction) | $(& $escape $entry.IntuneObjectId) | $(& $escape $entry.Status) | $completedStages/$(@($entry.Stages).Count) |")
    }
    $failedStages = @($entries | ForEach-Object { $_.Stages | Where-Object Status -eq 'Failed' })
    if ($failedStages.Count -gt 0) {
        $lines.Add('')
        $lines.Add('## Attention required')
        $lines.Add('')
        foreach ($entry in $entries) {
            foreach ($stage in @($entry.Stages | Where-Object Status -eq 'Failed')) {
                $lines.Add(('- {0}: stage `{1}` failed on attempt {2}. Review the local journal for supervised troubleshooting details.' -f (& $escape $entry.Name), (& $escape $stage.Name), $stage.Attempt))
            }
        }
    }
    $lines.Add('')
    $lines.Add('No cleanup or deletion is implied by this report.')

    if ($PSCmdlet.ShouldProcess($OutputPath, 'Write sanitized deployment run report')) {
        $parent = Split-Path -Path $OutputPath -Parent
        if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        $lines | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    }
    Get-Item -LiteralPath $OutputPath
}
