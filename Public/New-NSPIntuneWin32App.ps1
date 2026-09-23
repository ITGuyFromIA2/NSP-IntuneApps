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

        If the settings file sets $VariableConfig.AppDependency (@{ AppName; DependencyType }),
        the dependency's target app is resolved by DisplayName (Resolve-NSPIntuneWin32AppIdByDisplayName
        - throws rather than guessing on zero or duplicate matches) and attached via
        New-IntuneWin32AppDependency/Add-IntuneWin32AppDependency once this app is created. The
        target app must already exist in the tenant; there is no dependency-ordering solver here.

        Requirement rules beyond Architecture/MinimumSupportedWindowsRelease: REQ_MinFreeDiskSpaceMB/
        REQ_MinMemoryMB/REQ_MinProcessors/REQ_MinCPUSpeedMHz map straight onto
        New-IntuneWin32AppRequirementRule's own built-in params (all optional - omitted unless set).
        AdditionalRequirementScript (see Resolve-NSPAppBuildPlan) covers anything those built-ins
        can't express, e.g. OS edition, via one script-based additional requirement rule.

        Optional Company Portal metadata (Developer/Owner/InformationURL/PrivacyURL/AppVersion) and
        ScopeTagName pass straight through to Add-IntuneWin32App when the settings file sets them -
        every existing app is unaffected since all of these are omitted from the splat unless set.
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

    $detectionRule = if ($buildPlan.DetectionStyle -eq 'Registry_Exist') {
        $registryArgs = @{ Existence = $true; DetectionType = 'exists'; KeyPath = $buildPlan.RegistryKeyPath }
        if ($buildPlan.RegistryValueName) { $registryArgs.ValueName = $buildPlan.RegistryValueName }
        New-IntuneWin32AppDetectionRuleRegistry @registryArgs
    } elseif ($buildPlan.DetectionStyle -eq 'MSI') {
        # ProductCode is read from the actual .msi here, not in Resolve-NSPAppBuildPlan (which stays
        # a pure, module-free offline resolver) - this function already has IntuneWin32App loaded.
        $productCode = Get-MSIMetaData -Path $buildPlan.SetupFilePath -Property ProductCode
        New-IntuneWin32AppDetectionRuleMSI -ProductCode $productCode
    } else {
        New-IntuneWin32AppDetectionRuleScript -ScriptFile $buildPlan.DetectionScriptPath -EnforceSignatureCheck $buildPlan.EnforceSignatureDetection -RunAs32Bit $buildPlan.RunAs32BitDetection
    }
    $requirementArgs = @{
        Architecture                   = $buildPlan.RequirementArchitecture
        MinimumSupportedWindowsRelease = $buildPlan.RequirementMinimumWindowsRelease
    }
    if ($buildPlan.RequirementMinFreeDiskSpaceMB) { $requirementArgs.MinimumFreeDiskSpaceInMB = $buildPlan.RequirementMinFreeDiskSpaceMB }
    if ($buildPlan.RequirementMinMemoryMB) { $requirementArgs.MinimumMemoryInMB = $buildPlan.RequirementMinMemoryMB }
    if ($buildPlan.RequirementMinProcessors) { $requirementArgs.MinimumNumberOfProcessors = $buildPlan.RequirementMinProcessors }
    if ($buildPlan.RequirementMinCPUSpeedMHz) { $requirementArgs.MinimumCPUSpeedInMHz = $buildPlan.RequirementMinCPUSpeedMHz }
    $requirementRule = New-IntuneWin32AppRequirementRule @requirementArgs

    # One general script-based additional requirement (beyond the base rule above) - covers cases
    # New-IntuneWin32AppRequirementRule's own built-in params can't express (e.g. OS edition).
    # Dispatches dynamically on OutputDataType instead of hardcoding a branch per type (String/
    # Integer/Boolean/DateTime/Float/Version all share the same *OutputDataType/*ComparisonOperator/
    # *Value parameter-name pattern on New-IntuneWin32AppRequirementRuleScript).
    $additionalRequirementRule = $null
    if ($buildPlan.AdditionalRequirementScriptPath) {
        $ars = $buildPlan.AdditionalRequirementScript
        $outputType = [string]$ars.OutputDataType
        $scriptArgs = @{
            "${outputType}OutputDataType"     = $true
            ScriptFile                        = $buildPlan.AdditionalRequirementScriptPath
            ScriptContext                     = [string]$ars.ScriptContext
            "${outputType}ComparisonOperator" = [string]$ars.ComparisonOperator
            "${outputType}Value"              = $ars.Value
            RunAs32BitOn64System              = [bool]$ars.RunAs32BitOn64System
            EnforceSignatureCheck             = [bool]$ars.EnforceSignatureCheck
        }
        $additionalRequirementRule = New-IntuneWin32AppRequirementRuleScript @scriptArgs
    }
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
    if ($additionalRequirementRule) { $addArguments.AdditionalRequirementRule = @($additionalRequirementRule) }
    # Company Portal metadata beyond DisplayName/Description/Publisher - all optional, all pass
    # through only when the settings file actually sets them (today's behavior is unaffected
    # otherwise). Set-IntuneWin32App (Update-NSPIntuneWin32AppMetadata) supports the same fields
    # for in-place edits after creation. Deliberately no Notes field here - the notes property is
    # already owned by the management-notes marker (Get-NSPAppSourceState.ManagementNotes), PATCHed
    # unconditionally right after creation below; a Company-Portal-facing Notes value set here would
    # just be silently overwritten by that PATCH one step later.
    if ($VariableConfig.Developer) { $addArguments.Developer = [string]$VariableConfig.Developer }
    if ($VariableConfig.Owner) { $addArguments.Owner = [string]$VariableConfig.Owner }
    if ($VariableConfig.InformationURL) { $addArguments.InformationURL = [string]$VariableConfig.InformationURL }
    if ($VariableConfig.PrivacyURL) { $addArguments.PrivacyURL = [string]$VariableConfig.PrivacyURL }
    if ($VariableConfig.AppVersion) { $addArguments.AppVersion = [string]$VariableConfig.AppVersion }
    if ($VariableConfig.ScopeTagName) { $addArguments.ScopeTagName = @($VariableConfig.ScopeTagName) }

    $app = Add-IntuneWin32App @addArguments
    if (-not $app) { throw "Add-IntuneWin32App did not return the created app for '$AppName'." }

    $graphContext = Connect-NSPGraph -Scopes (Get-NSPGraphRoutineScopes) -Connect -ClientId $ClientId -TenantId $TenantId
    if ($graphContext.TenantId -ne $TenantId) {
        throw "Created app $($app.id) in tenant $TenantId, but the metadata PATCH session connected to $($graphContext.TenantId) instead. Reconnect against the correct tenant to record management notes for '$AppName'."
    }
    $patchBody = @{ '@odata.type' = '#microsoft.graph.win32LobApp'; notes = $sourceState.ManagementNotes } | ConvertTo-Json
    $patchResult = Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$($app.id)" -Body $patchBody -ContentType 'application/json' -ErrorAction Stop
    # See Set-NSPAppManagementNotes for why this check exists: Invoke-MgGraphRequest does not
    # reliably throw a terminating error for every non-2xx response.
    if ($patchResult -and $patchResult.PSObject.Properties['error']) {
        throw "Graph rejected the management-notes PATCH for the newly created app '$AppName' ($($app.id)): $($patchResult.error.message)"
    }

    $dependencyAppName = $null
    if ($VariableConfig.AppDependency -and $VariableConfig.AppDependency.AppName) {
        $dependencyAppName = [string]$VariableConfig.AppDependency.AppName
        $dependencyType = if ($VariableConfig.AppDependency.DependencyType) { [string]$VariableConfig.AppDependency.DependencyType } else { 'AutoInstall' }
        $dependencyAppId = Resolve-NSPIntuneWin32AppIdByDisplayName -DisplayName $dependencyAppName -TenantId $TenantId -ClientId $ClientId
        $dependencyObject = New-IntuneWin32AppDependency -ID $dependencyAppId -DependencyType $dependencyType
        Add-IntuneWin32AppDependency -ID $app.id -Dependency @($dependencyObject) -ErrorAction Stop | Out-Null
    }

    [pscustomobject]@{
        Status          = 'Created'
        AppName         = $AppName
        IntuneAppId     = $app.id
        DisplayName     = [string]$VariableConfig.DisplayName
        TenantId        = $graphContext.TenantId
        ManagementNotes = $sourceState.ManagementNotes
        DependsOn       = $dependencyAppName
    }
}
