function Update-NSPAppDeploymentPlan {
    <#
    .SYNOPSIS
        Resolves every local plan entry against a saved, read-only Intune app inventory.
    .DESCRIPTION
        Inventory JSON may be an array or an object with an Apps array. Each app needs
        Id, DisplayName, Publisher, and Notes. This command performs no Graph calls.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$PlanPath,
        [Parameter(Mandatory)][string]$InventoryPath,
        [string[]]$BreakingSourceId = @()
    )

    $plan = Get-Content -LiteralPath $PlanPath -Raw | ConvertFrom-Json
    $inventoryDocument = Get-Content -LiteralPath $InventoryPath -Raw | ConvertFrom-Json
    $inventory = if ($null -ne $inventoryDocument.Apps) { @($inventoryDocument.Apps) } else { @($inventoryDocument) }
    $inventoryTenantId = [string]$inventoryDocument.TenantId
    if ($plan.TenantId -and $inventoryTenantId -and [string]$plan.TenantId -ne $inventoryTenantId) {
        throw "Plan tenant '$($plan.TenantId)' does not match inventory tenant '$inventoryTenantId'."
    }
    foreach ($entry in @($plan.Entries)) {
        if ([string]::IsNullOrWhiteSpace([string]$entry.DisplayName) -or [string]::IsNullOrWhiteSpace([string]$entry.Publisher)) {
            throw "Plan entry '$($entry.Name)' lacks literal DisplayName/Publisher metadata and cannot be matched safely."
        }
        $parameters = @{
            SourceId=[string]$entry.SourceId
            DisplayName=[string]$entry.DisplayName
            Publisher=[string]$entry.Publisher
            MetadataSha256=[string]$entry.MetadataSha256
            ContentSha256=[string]$entry.ContentSha256
            ExistingApp=$inventory
            BreakingChange=[string]$entry.SourceId -in $BreakingSourceId
        }
        $resolution = Resolve-NSPAppDeploymentAction @parameters
        $entry.PlannedAction = $resolution.Action
        $entry.IntuneObjectId = $resolution.ExistingObjectId
        $entry | Add-Member -NotePropertyName MatchMethod -NotePropertyValue $resolution.MatchMethod -Force
        $entry | Add-Member -NotePropertyName MatchCount -NotePropertyValue $resolution.MatchCount -Force
        $entry | Add-Member -NotePropertyName CanExecute -NotePropertyValue $resolution.CanExecute -Force
        $entry | Add-Member -NotePropertyName PlanReason -NotePropertyValue $resolution.Reason -Force
        $entry | Add-Member -NotePropertyName ManagementNotes -NotePropertyValue $resolution.ManagementNotes -Force
    }
    $plan | Add-Member -NotePropertyName InventoryPath -NotePropertyValue (Resolve-Path -LiteralPath $InventoryPath).Path -Force
    $plan | Add-Member -NotePropertyName InventoryResolvedAt -NotePropertyValue (Get-Date).ToString('o') -Force
    if ($inventoryTenantId) { $plan.TenantId = $inventoryTenantId }
    $plan | Add-Member -NotePropertyName InventoryAccount -NotePropertyValue ([string]$inventoryDocument.Account) -Force
    if ($PSCmdlet.ShouldProcess($PlanPath, "Resolve $(@($plan.Entries).Count) plan entries against saved tenant inventory")) {
        $plan | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $PlanPath -Encoding UTF8
    }
    [pscustomobject]@{
        PlanPath=$PlanPath
        Entries=$plan.Entries
        Executable=@($plan.Entries | Where-Object CanExecute).Count
        ReviewRequired=@($plan.Entries | Where-Object { -not $_.CanExecute }).Count
    }
}
