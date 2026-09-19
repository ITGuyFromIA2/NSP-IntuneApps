function Set-NSPAppDeploymentDecisions {
    <#
    .SYNOPSIS
        Records an explicit yes/skip decision for each app in a local plan.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$PlanPath
    )

    $plan = Get-Content -LiteralPath $PlanPath -Raw | ConvertFrom-Json
    $review = Get-NSPAppDeploymentPlanReview -PlanPath $PlanPath
    if (-not $review.CanReviewDecisions) {
        throw "Deployment decisions cannot be reviewed yet: $($review.Blockers -join ' | ')"
    }
    foreach ($entry in @($plan.Entries | Sort-Object Order)) {
        if ($entry.Decision -ne 'Pending') { continue }
        $entryReview = $review.Entries | Where-Object Order -eq $entry.Order | Select-Object -First 1
        if (-not $entryReview.CanApprove) {
            throw "Plan entry '$($entry.Name)' cannot be approved: $($entryReview.Blocker)"
        }
        Write-NSPDashboardHeader -Title 'Deployment plan review' -StatusLines @(
            "Plan: $([IO.Path]::GetFileName($PlanPath))"
            "App $($entry.Order) of $(@($plan.Entries).Count): $($entry.Name)"
            "Tenant: $($review.TenantId) | Account: $($review.Account)"
            "Targeting: $($review.Targeting)"
            "Action: $($entryReview.PlannedAction) | Existing object: $(if ($entryReview.ExistingObject) { $entryReview.ExistingObject } else { 'none' })"
            "Effect: $($entryReview.Effect)"
            'Execution engine: not implemented; this decision only updates the local tracker'
        )
        Write-Host '[Y] Approve this resolved action for the later execution stage'
        Write-Host '[N] Skip this app'
        Write-Host '[Q] Save progress and stop reviewing'
        $choice = Read-NSPMenuChoice -Prompt 'Decision' -Allowed @('Y','N','Q')
        if ($choice -eq 'Q') { break }
        $entry.Decision = if ($choice -eq 'Y') { 'Approved' } else { 'Skipped' }
        $entry.ReviewedAt = (Get-Date).ToString('o')
        if ($PSCmdlet.ShouldProcess($PlanPath, "Record $($entry.Decision) for $($entry.Name)")) {
            $plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $PlanPath -Encoding UTF8
        }
    }
    [pscustomobject]@{
        PlanPath=$PlanPath
        Approved=@($plan.Entries | Where-Object Decision -eq 'Approved').Count
        Skipped=@($plan.Entries | Where-Object Decision -eq 'Skipped').Count
        Pending=@($plan.Entries | Where-Object Decision -eq 'Pending').Count
        Entries=$plan.Entries
    }
}
