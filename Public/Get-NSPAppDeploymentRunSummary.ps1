function Get-NSPAppDeploymentRunSummary {
    <#
    .SYNOPSIS
        Reads resumable progress from a local deployment run journal.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')][string]$RunPath
    )
    process {
        $resolvedPath = (Resolve-Path -LiteralPath $RunPath -ErrorAction Stop).Path
        $run = Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
        $entries = @($run.Entries)
        $currentEntry = $entries | Where-Object Name -eq $run.CurrentApp | Select-Object -First 1
        $currentStage = if ($currentEntry) { $currentEntry.Stages | Where-Object Status -ne 'Succeeded' | Select-Object -First 1 } else { $null }
        [pscustomobject]@{
            RunPath           = $resolvedPath
            Status            = [string]$run.Status
            TenantId          = [string]$run.TenantId
            Account           = [string]$run.Account
            Total             = $entries.Count
            Completed         = @($entries | Where-Object Status -eq 'Completed').Count
            Failed            = @($entries | Where-Object Status -eq 'Failed').Count
            Pending           = @($entries | Where-Object Status -in @('Pending','InProgress')).Count
            CurrentApp        = [string]$run.CurrentApp
            CurrentStage      = [string]$currentStage.Name
            CurrentStageState = [string]$currentStage.Status
            LastUpdatedAtUtc  = [string]$run.LastUpdatedAtUtc
            AppNames          = @($entries | ForEach-Object { [string]$_.Name })
        }
    }
}
