function Get-NSPDashboardState {
    <#
    .SYNOPSIS
        Refreshes the local, Graph-free state Start-NSPIntuneApps shows before every menu screen.
    .DESCRIPTION
        Pure local reads: repo preflight/catalog, saved deployment trackers, saved run journals,
        and whatever Graph context already exists in this process (never establishes one - that is
        still only ever triggered explicitly via [0] or an action's own -Connect). Centralized here
        so both the top-level category menu and each category's own submenu can refresh
        independently right before they render, without duplicating this block in two places.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot
    )

    $preflight = Test-NSPIntuneAppsPreflight -RepoRoot $RepoRoot
    $catalog = @($preflight.Catalog)
    $savedPlans = @(Get-NSPAppDeploymentPlanSummary -RepoRoot $RepoRoot)
    $runRoot = Join-Path $RepoRoot '.nsp-intuneapps\runs'
    $savedRuns = if (Test-Path -LiteralPath $runRoot) {
        @(Get-ChildItem -LiteralPath $runRoot -Filter '*.json' -File | Sort-Object LastWriteTimeUtc -Descending | ForEach-Object { Get-NSPAppDeploymentRunSummary -RunPath $_.FullName })
    } else { @() }
    $planStatus = if ($savedPlans.Count -eq 0) {
        'Trackers: none saved'
    } else {
        $latestPlan = $savedPlans[0]
        "Trackers: $($savedPlans.Count) saved | latest: $($latestPlan.Approved) approved, $($latestPlan.Skipped) skipped, $($latestPlan.Pending) pending, $($latestPlan.AttentionRequired) attention"
    }
    $graphContext = if (Get-Command Get-MgContext -ErrorAction SilentlyContinue) { Get-MgContext } else { $null }
    $graphStatus = if ($graphContext) { "Graph: connected as $($graphContext.Account) | tenant $($graphContext.TenantId)" } else { 'Graph: not connected - [0] to sign in' }

    [pscustomobject]@{
        Preflight    = $preflight
        Catalog      = $catalog
        SavedPlans   = $savedPlans
        SavedRuns    = $savedRuns
        PlanStatus   = $planStatus
        GraphContext = $graphContext
        GraphStatus  = $graphStatus
    }
}
