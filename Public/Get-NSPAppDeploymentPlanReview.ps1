function Get-NSPAppDeploymentPlanReview {
    <#
    .SYNOPSIS
        Produces a read-only, operator-facing safety review for one deployment tracker.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]$PlanPath
    )

    process {
        $resolvedPath = (Resolve-Path -LiteralPath $PlanPath -ErrorAction Stop).Path
        $plan = Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
        if ($plan.PlanType -ne 'Win32AppDeployment') { throw "Unsupported plan type '$($plan.PlanType)'." }

        $entries = @($plan.Entries | Sort-Object Order)
        $blockers = [Collections.Generic.List[string]]::new()
        $warnings = [Collections.Generic.List[string]]::new()

        if ([string]::IsNullOrWhiteSpace([string]$plan.InventoryResolvedAt)) {
            $blockers.Add('Read-only Intune inventory has not been bound to this tracker.')
        }
        if ([string]::IsNullOrWhiteSpace([string]$plan.TenantId)) {
            $blockers.Add('The tracker is not bound to a tenant ID.')
        }
        if ($null -eq $plan.Targeting) {
            $warnings.Add('No assignment target is recorded. App creation/update and assignment must remain separate operations.')
        }
        if ($plan.SafetyMode -ne 'PlanOnly') {
            $blockers.Add("Unexpected SafetyMode '$($plan.SafetyMode)'.")
        }

        $entryReviews = foreach ($entry in $entries) {
            $effect = switch ([string]$entry.PlannedAction) {
                'Create' { 'Create a new Win32 app object; no assignment is implied.' }
                'NoChange' { 'No tenant mutation.' }
                'UpdateMetadataInPlace' { 'Patch managed metadata while preserving the Intune object ID and relationships.' }
                'UpdateContentInPlace' { 'Commit a new content version while preserving the Intune object ID and relationships.' }
                'CreateSupersedingApp' { 'Create a side-by-side app and later add a reviewed supersedence relationship; retain the old app.' }
                'AdoptOrReview' { 'No write permitted until ownership/adoption is reviewed.' }
                'Conflict' { 'No write permitted until duplicate candidates are resolved.' }
                default { 'Read-only discovery is still required.' }
            }
            $entryBlocker = switch ([string]$entry.PlannedAction) {
                'AdoptOrReview' { [string]$entry.PlanReason }
                'Conflict' { [string]$entry.PlanReason }
                'DiscoveryRequired' { 'Inventory resolution has not determined an action.' }
                default { if ($null -ne $entry.CanExecute -and -not [bool]$entry.CanExecute) { [string]$entry.PlanReason } }
            }
            if ($entryBlocker) { $blockers.Add("$($entry.Name): $entryBlocker") }

            [pscustomobject]@{
                Order          = $entry.Order
                Name           = $entry.Name
                DisplayName    = $entry.DisplayName
                PlannedAction  = $entry.PlannedAction
                Decision       = $entry.Decision
                ExistingObject = [string]$entry.IntuneObjectId
                CanApprove     = [string]$entry.PlannedAction -in @('Create','NoChange','UpdateMetadataInPlace','UpdateContentInPlace','CreateSupersedingApp') -and [bool]$entry.CanExecute
                Effect         = $effect
                Blocker        = $entryBlocker
            }
        }

        $targetingSummary = if ($null -eq $plan.Targeting) { 'Not specified' } else { $plan.Targeting | ConvertTo-Json -Depth 8 -Compress }
        [pscustomobject]@{
            PlanPath            = $resolvedPath
            TenantId            = [string]$plan.TenantId
            Account             = [string]$plan.InventoryAccount
            SafetyMode          = [string]$plan.SafetyMode
            InventoryResolved   = -not [string]::IsNullOrWhiteSpace([string]$plan.InventoryResolvedAt)
            Targeting           = $targetingSummary
            CanReviewDecisions  = $blockers.Count -eq 0
            CanExecute          = $false
            ExecutorStatus      = 'NotImplemented'
            Blockers            = @($blockers)
            Warnings            = @($warnings)
            Entries             = @($entryReviews)
        }
    }
}
