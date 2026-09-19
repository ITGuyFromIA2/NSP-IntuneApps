function Set-NSPAppDeploymentRunStage {
    <#
    .SYNOPSIS
        Persists one valid stage transition in a local deployment run journal.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RunPath,
        [Parameter(Mandatory)][string]$AppName,
        [Parameter(Mandatory)][string]$Stage,
        [Parameter(Mandatory)][ValidateSet('Running','Succeeded','Failed')][string]$Status,
        [string]$Message
    )

    $resolvedRunPath = (Resolve-Path -LiteralPath $RunPath -ErrorAction Stop).Path
    $run = Get-Content -LiteralPath $resolvedRunPath -Raw | ConvertFrom-Json
    if ($run.RunType -ne 'Win32AppDeployment') { throw "Unsupported run type '$($run.RunType)'." }
    $currentEntry = @($run.Entries | Where-Object Status -notin @('Completed','Skipped') | Sort-Object Order | Select-Object -First 1)
    if ($currentEntry.Count -eq 0) { throw 'The run is already complete.' }
    $entry = $currentEntry[0]
    if ($entry.Name -ne $AppName) { throw "'$($entry.Name)' is the current app. One-app-at-a-time order cannot be bypassed." }

    $currentStage = @($entry.Stages | Where-Object Status -ne 'Succeeded' | Select-Object -First 1)
    if ($currentStage.Count -eq 0) { throw "All stages for '$AppName' are already complete." }
    $stageRecord = $currentStage[0]
    if ($stageRecord.Name -ne $Stage) { throw "'$($stageRecord.Name)' is the current stage for '$AppName'."
    }

    $validTransition =
        ($Status -eq 'Running' -and $stageRecord.Status -in @('Pending','Failed')) -or
        ($Status -in @('Succeeded','Failed') -and $stageRecord.Status -eq 'Running')
    if (-not $validTransition) { throw "Invalid stage transition: $($stageRecord.Status) -> $Status." }
    if (-not $PSCmdlet.ShouldProcess("$AppName / $Stage", "Record stage status $Status")) { return }

    $now = (Get-Date).ToUniversalTime().ToString('o')
    if ($Status -eq 'Running') {
        $stageRecord.Attempt = [int]$stageRecord.Attempt + 1
        $stageRecord.StartedAtUtc = $now
        $stageRecord.CompletedAtUtc = $null
        $entry.Status = 'InProgress'
        $run.Status = 'Running'
    } else {
        $stageRecord.CompletedAtUtc = $now
        if ($Status -eq 'Failed') {
            $entry.Status = 'Failed'
            $run.Status = 'AttentionRequired'
        } else {
            # Status is assigned below; inspect all other stages when deciding completion.
            if (@($entry.Stages | Where-Object { $_.Name -ne $stageRecord.Name -and $_.Status -ne 'Succeeded' }).Count -eq 0) {
                $entry.Status = 'Completed'
                $nextEntry = @($run.Entries | Where-Object { $_.Name -ne $entry.Name -and $_.Status -notin @('Completed','Skipped') } | Sort-Object Order | Select-Object -First 1)
                if ($nextEntry.Count -eq 0) {
                    $run.Status = 'Completed'
                    $run.CurrentApp = $null
                } else {
                    $run.Status = 'Ready'
                    $run.CurrentApp = $nextEntry[0].Name
                }
            } else {
                $entry.Status = 'InProgress'
                $run.Status = 'Running'
            }
        }
    }
    $stageRecord.Status = $Status
    $stageRecord.Message = $Message
    $run.LastUpdatedAtUtc = $now
    $run.Events = @($run.Events) + @([ordered]@{ AtUtc=$now; Type='StageTransition'; App=$AppName; Stage=$Stage; Status=$Status; Message=$Message })

    $temporaryPath = "$resolvedRunPath.tmp"
    $run | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $temporaryPath -Encoding UTF8
    Move-Item -LiteralPath $temporaryPath -Destination $resolvedRunPath -Force
    Get-NSPAppDeploymentRunSummary -RunPath $resolvedRunPath
}
