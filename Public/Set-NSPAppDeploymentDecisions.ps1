function Set-NSPAppDeploymentDecisions {
    <#
    .SYNOPSIS
        Records an explicit yes/skip decision for each app in a local plan.
    .DESCRIPTION
        Interactive by default (prompts once per pending entry; [Q] stops early and saves
        progress). Pass -Decisions to apply decisions non-interactively instead, one entry per
        pending plan entry, matched by Name: @{ Name; Decision = 'Approved'/'Skipped';
        SupersedenceType = 'Update'/'Replace' (required only when approving a
        CreateSupersedingApp entry) }. Every pending entry must have a matching decision, or this
        throws rather than leaving one pending or guessing a default - this is the hook a future
        NSP-IntuneManager needs to drive plan approval programmatically instead of through the
        interactive dashboard.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$PlanPath,
        [object[]]$Decisions
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

        if ($Decisions) {
            $providedDecision = @($Decisions | Where-Object { [string]$_.Name -eq $entry.Name }) | Select-Object -First 1
            if (-not $providedDecision) { throw "No decision was provided for pending plan entry '$($entry.Name)'." }
            $decisionValue = [string]$providedDecision.Decision
            if ($decisionValue -notin @('Approved', 'Skipped')) { throw "Decision for '$($entry.Name)' must be 'Approved' or 'Skipped', not '$decisionValue'." }
            $entry.Decision = $decisionValue
            $entry.ReviewedAt = (Get-Date).ToString('o')
            if ($entry.Decision -eq 'Approved' -and $entryReview.PlannedAction -eq 'CreateSupersedingApp') {
                $supersedenceType = [string]$providedDecision.SupersedenceType
                if ($supersedenceType -notin @('Update', 'Replace')) { throw "Decision for '$($entry.Name)' approves a CreateSupersedingApp entry and needs SupersedenceType 'Update' or 'Replace', not '$supersedenceType'." }
                $entry | Add-Member -NotePropertyName SupersedenceType -NotePropertyValue $supersedenceType -Force
            }
            if ($PSCmdlet.ShouldProcess($PlanPath, "Record $($entry.Decision) for $($entry.Name)")) {
                $plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $PlanPath -Encoding UTF8
            }
            continue
        }

        Write-NSPDashboardHeader -Title 'Deployment plan review' -StatusLines @(
            "Plan: $([IO.Path]::GetFileName($PlanPath))"
            "App $($entry.Order) of $(@($plan.Entries).Count): $($entry.Name)"
            "Tenant: $($review.TenantId) | Account: $($review.Account)"
            "Targeting: $($review.Targeting)"
            "Action: $($entryReview.PlannedAction) | Existing object: $(if ($entryReview.ExistingObject) { $entryReview.ExistingObject } else { 'none' })"
            "Effect: $($entryReview.Effect)"
            'This decision only updates the local tracker; a later run stage performs the tenant write'
        )
        Write-Host '[Y] Approve this resolved action for the later execution stage'
        Write-Host '[N] Skip this app'
        Write-Host '[Q] Save progress and stop reviewing'
        $choice = Read-NSPMenuChoice -Prompt 'Decision' -Allowed @('Y','N','Q')
        if ($choice -eq 'Q') { break }
        $entry.Decision = if ($choice -eq 'Y') { 'Approved' } else { 'Skipped' }
        $entry.ReviewedAt = (Get-Date).ToString('o')
        if ($entry.Decision -eq 'Approved' -and $entryReview.PlannedAction -eq 'CreateSupersedingApp') {
            Write-Host "This creates a new app object side-by-side with the existing one ($($entryReview.ExistingObject)) and relates them." -ForegroundColor Yellow
            Write-Host '[1] Update - the old app''s install/config state stays in place (a newer version of the same product)'
            Write-Host '[2] Replace - the old app is uninstalled first (an unrelated product being swapped in)'
            $supersedenceChoice = Read-NSPMenuChoice -Prompt 'Supersedence type' -Allowed @('1','2') -Default '1'
            $entry | Add-Member -NotePropertyName SupersedenceType -NotePropertyValue $(if ($supersedenceChoice -eq '2') { 'Replace' } else { 'Update' }) -Force
        }
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
