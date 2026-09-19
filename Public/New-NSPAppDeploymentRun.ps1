function New-NSPAppDeploymentRun {
    <#
    .SYNOPSIS
        Creates a durable, local one-app-at-a-time run journal from an approved tracker.
    .DESCRIPTION
        This command performs no builds and no tenant writes. It materializes the ordered
        stages a future executor must complete and persist after every transition.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$PlanPath,
        [string]$OutputPath
    )

    $resolvedPlanPath = (Resolve-Path -LiteralPath $PlanPath -ErrorAction Stop).Path
    $review = Get-NSPAppDeploymentPlanReview -PlanPath $resolvedPlanPath
    if (-not $review.CanReviewDecisions) { throw "Plan is not execution-ready: $($review.Blockers -join ' | ')" }
    $plan = Get-Content -LiteralPath $resolvedPlanPath -Raw | ConvertFrom-Json
    $pending = @($plan.Entries | Where-Object Decision -eq 'Pending')
    if ($pending.Count -gt 0) { throw "$($pending.Count) plan entry or entries still need an Approve/Skip decision." }
    $approved = @($plan.Entries | Where-Object Decision -eq 'Approved' | Sort-Object Order)
    if ($approved.Count -eq 0) { throw 'The plan has no approved entries.' }

    if (-not $OutputPath) {
        $repoRoot = [string]$plan.RepoRoot
        if ([string]::IsNullOrWhiteSpace($repoRoot)) { $repoRoot = Split-Path -Path (Split-Path -Path $resolvedPlanPath -Parent) -Parent }
        $runRoot = Join-Path $repoRoot '.nsp-intuneapps\runs'
        $OutputPath = Join-Path $runRoot ("deployment-run-{0}.json" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }
    if (-not $PSCmdlet.ShouldProcess($OutputPath, "Create a local run journal for $($approved.Count) approved app(s)")) { return }

    $stageMap = @{
        NoChange = @('ValidatePlan')
        Create = @('ValidatePlan','Build','Sign','Package','CreateApp','RecordManagementNotes')
        UpdateMetadataInPlace = @('ValidatePlan','PatchMetadata','RecordManagementNotes')
        UpdateContentInPlace = @('ValidatePlan','Build','Sign','Package','UploadContent','CommitContent','RecordManagementNotes')
        CreateSupersedingApp = @('ValidatePlan','Build','Sign','Package','CreateApp','AddSupersedence','RecordManagementNotes')
    }
    $now = (Get-Date).ToUniversalTime().ToString('o')
    $entries = foreach ($entry in $approved) {
        $stageNames = @($stageMap[[string]$entry.PlannedAction])
        if ($stageNames.Count -eq 0) { throw "Approved entry '$($entry.Name)' has unsupported action '$($entry.PlannedAction)'." }
        [ordered]@{
            Order          = $entry.Order
            Name           = $entry.Name
            SourceId       = $entry.SourceId
            PlannedAction  = $entry.PlannedAction
            IntuneObjectId = $entry.IntuneObjectId
            Status         = 'Pending'
            Stages         = @($stageNames | ForEach-Object {
                [ordered]@{ Name=$_; Status='Pending'; Attempt=0; StartedAtUtc=$null; CompletedAtUtc=$null; Message=$null }
            })
        }
    }
    $run = [ordered]@{
        SchemaVersion='1.0'
        RunType='Win32AppDeployment'
        PlanPath=$resolvedPlanPath
        TenantId=$review.TenantId
        Account=$review.Account
        Targeting=$plan.Targeting
        CreatedAtUtc=$now
        LastUpdatedAtUtc=$now
        Status='Ready'
        CurrentApp=$entries[0].Name
        Entries=@($entries)
        Events=@([ordered]@{ AtUtc=$now; Type='RunCreated'; App=$null; Stage=$null; Status='Ready'; Message="$($entries.Count) approved app(s) queued." })
    }
    $parent = Split-Path -Path $OutputPath -Parent
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $run | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    Get-Item -LiteralPath $OutputPath
}
