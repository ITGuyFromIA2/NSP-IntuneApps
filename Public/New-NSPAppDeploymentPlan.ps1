function New-NSPAppDeploymentPlan {
    <#
    .SYNOPSIS
        Creates a local, reviewable app-by-app deployment tracker.
    .DESCRIPTION
        This does not build, upload, assign, or change a tenant. Each entry begins in
        Pending state and must receive an explicit Approve or Skip decision.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [string[]]$AppName,
        [string]$TenantId,
        [hashtable]$Targeting,
        [string]$OutputPath
    )

    $catalog = @(Get-NSPIntuneAppCatalog -RepoRoot $RepoRoot | Where-Object Classification -eq 'Deployable')
    if ($AppName) {
        $unknown = @($AppName | Where-Object { $_ -notin $catalog.Name })
        if ($unknown) { throw "These apps are not deployable catalog entries: $($unknown -join ', ')" }
        $catalog = @($catalog | Where-Object Name -in $AppName)
    }
    if (-not $catalog) { throw 'No deployable apps were selected.' }
    if (-not $OutputPath) {
        $planRoot = Join-Path $RepoRoot '.nsp-intuneapps\plans'
        $OutputPath = Join-Path $planRoot ("app-plan-{0}.json" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }
    if (-not $PSCmdlet.ShouldProcess($OutputPath, "Create a plan for $($catalog.Count) app(s)")) { return }

    $entries = foreach ($app in $catalog) {
        $sourceState = Get-NSPAppSourceState -RepoRoot $RepoRoot -AppName $app.Name
        [ordered]@{
            Order=[array]::IndexOf($catalog, $app) + 1
            Name=$app.Name
            DisplayName=$sourceState.DisplayName
            Publisher=$sourceState.Publisher
            SettingsPath=$app.SettingsPath
            SourceId=$sourceState.SourceId
            MetadataSha256=$sourceState.MetadataSha256
            ContentSha256=$sourceState.ContentSha256
            PlannedAction='DiscoveryRequired'
            Decision='Pending'
            ExecutionStatus='NotStarted'
            IntuneObjectId=$null
            Result=$null
            ReviewedAt=$null
            ExecutedAt=$null
        }
    }
    $plan = [ordered]@{
        SchemaVersion='1.1'
        PlanType='Win32AppDeployment'
        CreatedAt=(Get-Date).ToString('o')
        RepoRoot=(Resolve-Path -LiteralPath $RepoRoot).Path
        TenantId=$TenantId
        Targeting=$Targeting
        SafetyMode='PlanOnly'
        Entries=@($entries)
    }
    $parent = Split-Path -Path $OutputPath -Parent
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    Get-Item -LiteralPath $OutputPath
}
