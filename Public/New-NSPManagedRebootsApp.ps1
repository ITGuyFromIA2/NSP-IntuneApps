function New-NSPManagedRebootsApp {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [ValidateRange(1,365)][int]$MaxUptimeDays = 14,
        [ValidateRange(1,168)][int]$GraceHours = 24,
        [ValidateRange(1,72)][int]$DeferralHours = 4,
        [ValidateRange(0,20)][int]$MaxDeferrals = 3,
        [ValidateRange(15,1440)][int]$EvaluationIntervalMinutes = 60,
        [ValidateRange(60,7200)][int]$PromptTimeoutSeconds = 900,
        [ValidateRange(30,3600)][int]$RebootCountdownSeconds = 300,
        [string]$PromptTitle = 'Restart required',
        [string]$PromptMessage = 'Windows requires a restart to remain healthy and secure. Save your work, then restart now or use an available deferral.',
        [string]$OutputRoot,
        [switch]$Interactive,
        [switch]$Force
    )
    if ($Interactive) {
        Write-Host 'Managed Reboots policy wizard' -ForegroundColor Cyan
        Write-Host 'Press Enter at each prompt to accept the displayed default.'
        $value = Read-Host "1. Maximum uptime in days [$MaxUptimeDays]"; if ($value) { $MaxUptimeDays = [int]$value }
        $value = Read-Host "2. Hard-deadline grace period in hours [$GraceHours]"; if ($value) { $GraceHours = [int]$value }
        $value = Read-Host "3. Hours between prompts after a deferral [$DeferralHours]"; if ($value) { $DeferralHours = [int]$value }
        $value = Read-Host "4. Maximum deferrals [$MaxDeferrals]"; if ($value) { $MaxDeferrals = [int]$value }
        $value = Read-Host "5. Evaluation interval in minutes [$EvaluationIntervalMinutes]"; if ($value) { $EvaluationIntervalMinutes = [int]$value }
        $value = Read-Host "6. Final reboot countdown in seconds [$RebootCountdownSeconds]"; if ($value) { $RebootCountdownSeconds = [int]$value }
    }
    if (-not $OutputRoot) { $OutputRoot = if (Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot) { Join-Path $RepoRoot 'Config\Local\GeneratedApps' } else { Join-Path $RepoRoot 'Apps' } }
    $id = 'ManagedReboots'
    $appRoot = Join-Path $OutputRoot $id
    if ((Test-Path -LiteralPath $appRoot) -and -not $Force) { throw "Destination already exists: $appRoot. Use -Force to replace generated files." }
    if (-not $PSCmdlet.ShouldProcess($appRoot, 'Generate the Managed Reboots policy app')) { return }
    $source = Join-Path $appRoot 'Source'; $detect = Join-Path $appRoot 'Detect'
    New-Item -ItemType Directory -Path $source,$detect -Force | Out-Null
    $template = Join-Path $RepoRoot 'Templates\ManagedReboots'
    Get-ChildItem -LiteralPath (Join-Path $template 'Source') -File | Copy-Item -Destination $source -Force
    Get-ChildItem -LiteralPath (Join-Path $template 'Detect') -File | Copy-Item -Destination $detect -Force
    Copy-Item -LiteralPath (Join-Path $RepoRoot 'Templates\UserPrompt\Invoke-NSPUserPrompt.ps1') -Destination $source -Force
    Copy-Item -LiteralPath (Join-Path $RepoRoot 'Templates\UserPrompt\Show-NSPUserPrompt.ps1') -Destination $source -Force
    $config = [ordered]@{
        Version='1.0.0'; TaskName='NSP - Managed Reboots'; MaxUptimeDays=$MaxUptimeDays; GraceHours=$GraceHours
        DeferralHours=$DeferralHours; MaxDeferrals=$MaxDeferrals; EvaluationIntervalMinutes=$EvaluationIntervalMinutes
        PromptTimeoutSeconds=$PromptTimeoutSeconds; RebootCountdownSeconds=$RebootCountdownSeconds
        PromptTitle=$PromptTitle; PromptMessage=$PromptMessage
    }
    $json = $config | ConvertTo-Json -Depth 5
    $json | Set-Content -LiteralPath (Join-Path $source 'ManagedReboots.config.json') -Encoding UTF8
    $json | Set-Content -LiteralPath (Join-Path $detect 'ManagedReboots.config.json') -Encoding UTF8
    $settings = @"
`$VariableConfig = @{}
`$VariableConfig.DisplayName = 'NSP Managed Reboots'
`$VariableConfig.Description = 'Evaluates pending reboot signals and maximum uptime, offers bounded user deferrals, and enforces a reviewed hard deadline.'
`$VariableConfig.Publisher = 'Network Systems Plus, Inc.'
`$VariableConfig.IsFeatured = `$false
`$VariableConfig.Category = @('Computer Management')
`$VariableConfig.SetupType = 'PoSH'
`$VariableConfig.InstallExperience = 'system'
`$VariableConfig.RestartExperience = 'suppress'
`$VariableConfig.REQ_Architecture = 'All'
`$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
`$VariableConfig.DetectionStyle = 'Script'
`$VariableConfig.DetectScript_Filter = 'Detect-*.ps1'
`$VariableConfig.SetupFile_Filter = 'Install-*.ps1'
`$VariableConfig.PoSH = @{ Sign_SourceFilter='*.ps1'; UninstallFile_Filter='Uninstall-*.ps1' }
`$VariableConfig.EnforceSignature_Detection = `$true
`$VariableConfig.RunAs32Bit_Detection = `$false
`$VariableConfig.AssignmentColl = @()
"@
    $settingsPath = Join-Path $appRoot 'ManagedReboots_SplitScriptSettings.ps1'
    Set-Content -LiteralPath $settingsPath -Value $settings -Encoding UTF8
    [pscustomobject]@{ Name='NSP Managed Reboots'; Path=$appRoot; SettingsPath=$settingsPath; Policy=[pscustomobject]$config }
}
