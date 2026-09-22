function New-NSPIntuneWin32App {
    <#
    .SYNOPSIS
        Creates a brand-new Win32 app in Intune from a built package: the CreateApp and
        RecordManagementNotes stages.
    .DESCRIPTION
        Plan-only is the default. Use -Execute and approve ShouldProcess to actually create
        the app against the tenant. Connects with IntuneWin32App's own delegated session for
        the creation call, then a separate Microsoft.Graph.Authentication session (via
        Connect-NSPGraph) to PATCH the deterministic management-notes marker onto the created
        app immediately afterward, matching docs/DeploymentEngine.md's execution gate of
        treating the metadata PATCH as its own recorded operation. No assignment is created
        here; assignment remains a separate reviewed operation.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$AppName,
        [Parameter(Mandatory)][string]$PackagePath,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [switch]$Execute
    )

    $entry = Get-NSPIntuneAppCatalog -RepoRoot $RepoRoot | Where-Object Name -eq $AppName
    if (-not $entry) { throw "App was not found in the catalog: $AppName" }
    if (-not $entry.SettingsPath) { throw "App does not have one settings file: $AppName" }
    if (-not (Test-Path -LiteralPath $PackagePath)) { throw "Package not found: $PackagePath" }

    $VariableConfig = $null
    . $entry.SettingsPath
    $buildPlan = Resolve-NSPAppBuildPlan -Name $AppName -SettingsPath $entry.SettingsPath -Path $entry.Path -VariableConfig $VariableConfig
    $sourceState = Get-NSPAppSourceState -RepoRoot $RepoRoot -AppName $AppName

    if (-not $Execute) {
        return [pscustomobject]@{
            Status      = 'PlanOnly'
            AppName     = $AppName
            DisplayName = $sourceState.DisplayName
            Publisher   = $sourceState.Publisher
            PackagePath = $PackagePath
            Message     = "Run again with -Execute to create '$($sourceState.DisplayName)' in tenant $TenantId and record its management notes."
        }
    }

    if (-not $PSCmdlet.ShouldProcess("tenant $TenantId", "Create Win32 app '$($sourceState.DisplayName)' for $AppName")) { return }

    if (-not (Get-Module -ListAvailable IntuneWin32App)) {
        Import-NSPBootstrap | Out-Null
        Install-NSPModule -Name IntuneWin32App -Scope CurrentUser
    }
    Import-Module IntuneWin32App -ErrorAction Stop
    Connect-MSIntuneGraph -TenantID $TenantId -ClientID $ClientId | Out-Null

    $detectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $buildPlan.DetectionScriptPath -EnforceSignatureCheck $buildPlan.EnforceSignatureDetection -RunAs32Bit $buildPlan.RunAs32BitDetection
    $requirementRule = New-IntuneWin32AppRequirementRule -Architecture $buildPlan.RequirementArchitecture -MinimumSupportedWindowsRelease $buildPlan.RequirementMinimumWindowsRelease
    $icon = if ($buildPlan.IconPath) { New-IntuneWin32AppIcon -FilePath $buildPlan.IconPath } else { $null }

    $addArguments = @{
        FilePath                 = $PackagePath
        DisplayName              = [string]$VariableConfig.DisplayName
        Description              = [string]$VariableConfig.Description
        Publisher                = [string]$VariableConfig.Publisher
        InstallCommandLine       = $buildPlan.InstallCommandLine
        UninstallCommandLine     = $buildPlan.UninstallCommandLine
        InstallExperience        = [string]$VariableConfig.InstallExperience
        RestartBehavior          = [string]$VariableConfig.RestartExperience
        DetectionRule            = @($detectionRule)
        RequirementRule          = $requirementRule
        CompanyPortalFeaturedApp = [bool]$VariableConfig.IsFeatured
        CategoryName             = @($VariableConfig.Category)
    }
    if ($icon) { $addArguments.Icon = $icon }

    $app = Add-IntuneWin32App @addArguments
    if (-not $app) { throw "Add-IntuneWin32App did not return the created app for '$AppName'." }

    $graphContext = Connect-NSPGraph -Scopes 'DeviceManagementApps.ReadWrite.All' -Connect
    if ($graphContext.TenantId -ne $TenantId) {
        throw "Created app $($app.id) in tenant $TenantId, but the metadata PATCH session connected to $($graphContext.TenantId) instead. Reconnect against the correct tenant to record management notes for '$AppName'."
    }
    $patchBody = @{ '@odata.type' = '#microsoft.graph.win32LobApp'; notes = $sourceState.ManagementNotes } | ConvertTo-Json
    Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$($app.id)" -Body $patchBody -ContentType 'application/json' -ErrorAction Stop | Out-Null

    [pscustomobject]@{
        Status          = 'Created'
        AppName         = $AppName
        IntuneAppId     = $app.id
        DisplayName     = [string]$VariableConfig.DisplayName
        TenantId        = $graphContext.TenantId
        ManagementNotes = $sourceState.ManagementNotes
    }
}
