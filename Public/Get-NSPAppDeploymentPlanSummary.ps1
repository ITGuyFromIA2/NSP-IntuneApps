function Get-NSPAppDeploymentPlanSummary {
    <#
    .SYNOPSIS
        Summarizes saved local app deployment trackers without connecting to Intune.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [string[]]$PlanPath
    )

    if (-not $PlanPath) {
        $planRoot = Join-Path $RepoRoot '.nsp-intuneapps\plans'
        if (-not (Test-Path -LiteralPath $planRoot)) { return }
        $PlanPath = @(Get-ChildItem -LiteralPath $planRoot -File -Filter '*.json' |
            Sort-Object LastWriteTimeUtc -Descending |
            Select-Object -ExpandProperty FullName)
    }

    foreach ($path in $PlanPath) {
        try {
            $file = Get-Item -LiteralPath $path -ErrorAction Stop
            $plan = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            if ($plan.PlanType -ne 'Win32AppDeployment' -or $null -eq $plan.Entries) { continue }
            $entries = @($plan.Entries)
            $attention = @($entries | Where-Object {
                $_.PlannedAction -in @('Conflict','AdoptOrReview') -or
                $_.ExecutionStatus -in @('Failed','AttentionRequired')
            }).Count
            [pscustomobject]@{
                PlanPath          = $file.FullName
                FileName          = $file.Name
                CreatedAt         = if ($plan.CreatedAt) { [datetimeoffset]$plan.CreatedAt } else { $file.CreationTimeUtc }
                LastModifiedAt    = $file.LastWriteTime
                TenantId          = [string]$plan.TenantId
                Total             = $entries.Count
                Approved          = @($entries | Where-Object Decision -eq 'Approved').Count
                Skipped           = @($entries | Where-Object Decision -eq 'Skipped').Count
                Pending           = @($entries | Where-Object Decision -eq 'Pending').Count
                Completed         = @($entries | Where-Object ExecutionStatus -eq 'Completed').Count
                Failed            = @($entries | Where-Object ExecutionStatus -eq 'Failed').Count
                AttentionRequired = $attention
                InventoryResolved = -not [string]::IsNullOrWhiteSpace([string]$plan.InventoryResolvedAt)
                SafetyMode        = [string]$plan.SafetyMode
                AppNames          = @($entries | ForEach-Object { [string]$_.Name })
            }
        } catch {
            Write-Warning "Could not read deployment plan '$path': $($_.Exception.Message)"
        }
    }
}
