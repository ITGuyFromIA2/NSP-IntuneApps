Describe 'Invoke-NSPAppDeploymentRunStage' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force

        function New-FixtureRepo {
            param([string]$Root)
            $appRoot = Join-Path $Root 'Apps\Fixture'
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Source') -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Detect') -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\DownloadInstall_Fixture.ps1') -Value '# setup'
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\Uninstall_Fixture.ps1') -Value '# uninstall'
            Set-Content -LiteralPath (Join-Path $appRoot 'Detect\Detect_Fixture.ps1') -Value '# detect'
            $settings = @'
$VariableConfig = @{}
$VariableConfig.DisplayName = 'Fixture App'
$VariableConfig.Description = 'Fixture description.'
$VariableConfig.Publisher = 'Fixture Publisher'
$VariableConfig.IsFeatured = $false
$VariableConfig.Category = @('Computer Management')
$VariableConfig.SetupType = 'PoSH'
$VariableConfig.InstallExperience = 'system'
$VariableConfig.RestartExperience = 'basedOnReturnCode'
$VariableConfig.REQ_Architecture = 'All'
$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
$VariableConfig.DetectionStyle = 'Script'
$VariableConfig.DetectScript_Filter = 'Detect_*.ps1'
$VariableConfig.SetupFile_Filter = 'DownloadInstall_*.ps1'
$VariableConfig.PoSH = @{ Sign_SourceFilter = '*.ps1'; UninstallFile_Filter = 'Uninstall_*.ps1' }
$VariableConfig.EnforceSignature_Detection = $true
$VariableConfig.RunAs32Bit_Detection = $false
'@
            Set-Content -LiteralPath (Join-Path $appRoot 'Fixture_SplitScriptSettings.ps1') -Value $settings
        }

        function New-FixtureRun {
            param([string]$Root, [string]$PlannedAction = 'Create', [string]$TenantId = 'tenant-1')
            New-FixtureRepo -Root $Root
            $sourceState = Get-NSPAppSourceState -RepoRoot $Root -AppName 'Fixture'
            $planPath = Join-Path $Root 'plan.json'
            [ordered]@{
                SchemaVersion = '1.1'; PlanType = 'Win32AppDeployment'; SafetyMode = 'PlanOnly'; RepoRoot = $Root
                TenantId = $TenantId; InventoryAccount = 'operator@example.test'; InventoryResolvedAt = '2026-09-19T02:00:00Z'; Targeting = $null
                Entries = @(
                    @{
                        Order = 1; Name = 'Fixture'; SourceId = 'Fixture'; DisplayName = 'Fixture App'
                        MetadataSha256 = $sourceState.MetadataSha256; ContentSha256 = $sourceState.ContentSha256
                        PlannedAction = $PlannedAction; Decision = 'Approved'; CanExecute = $true; IntuneObjectId = $null
                    }
                )
            } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $planPath
            $runPath = Join-Path $Root 'run.json'
            New-NSPAppDeploymentRun -PlanPath $planPath -OutputPath $runPath -Confirm:$false | Out-Null
            $runPath
        }
    }

    It 'reports a plan preview without touching the journal when -Execute is not passed' {
        $root = Join-Path $TestDrive 'PlanOnly'
        $runPath = New-FixtureRun -Root $root
        $before = Get-Content -LiteralPath $runPath -Raw

        $result = Invoke-NSPAppDeploymentRunStage -RunPath $runPath

        $result.Status | Should -Be 'PlanOnly'
        $result.App | Should -Be 'Fixture'
        $result.Stage | Should -Be 'ValidatePlan'
        (Get-Content -LiteralPath $runPath -Raw) | Should -Be $before
    }

    It 'succeeds ValidatePlan when source hashes match the plan and advances to Build' {
        $root = Join-Path $TestDrive 'ValidatePlanOk'
        $runPath = New-FixtureRun -Root $root

        $summary = Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false

        $summary.CurrentApp | Should -Be 'Fixture'
        $summary.CurrentStage | Should -Be 'Build'
        $summary.CurrentStageState | Should -Be 'Pending'
    }

    It 'fails ValidatePlan clearly when the source has drifted since planning' {
        $root = Join-Path $TestDrive 'ValidatePlanDrift'
        $runPath = New-FixtureRun -Root $root
        Set-Content -LiteralPath (Join-Path $root 'Apps\Fixture\Source\DownloadInstall_Fixture.ps1') -Value '# setup CHANGED'

        { Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false } | Should -Throw '*changed since planning*'

        $summary = Get-NSPAppDeploymentRunSummary -RunPath $runPath
        $summary.Status | Should -Be 'AttentionRequired'
        $summary.CurrentStage | Should -Be 'ValidatePlan'
    }

    It 'dispatches the Build stage and advances to Sign, leaving Package pending' {
        $root = Join-Path $TestDrive 'BuildFold'
        $runPath = New-FixtureRun -Root $root
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null

        Mock New-NSPAppPackage { [pscustomobject]@{ AppName = 'Fixture'; PackagePath = 'C:\fake\Fixture.intunewin' } } -ModuleName NSP.IntuneApps

        $summary = Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false

        Should -Invoke New-NSPAppPackage -Times 1 -ModuleName NSP.IntuneApps
        $summary.CurrentApp | Should -Be 'Fixture'
        $summary.CurrentStage | Should -Be 'Sign'
        $document = Get-Content -LiteralPath $runPath -Raw | ConvertFrom-Json
        ($document.Entries[0].Stages | Where-Object Name -eq 'Build').Status | Should -Be 'Succeeded'
        ($document.Entries[0].Stages | Where-Object Name -eq 'Package').Status | Should -Be 'Pending'
    }

    It 'dispatches the Sign stage, then the Package stage as a no-op once it is current' {
        $root = Join-Path $TestDrive 'SignDispatch'
        $runPath = New-FixtureRun -Root $root
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null
        Mock New-NSPAppPackage { [pscustomobject]@{ AppName = 'Fixture'; PackagePath = 'C:\fake\Fixture.intunewin' } } -ModuleName NSP.IntuneApps
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null

        Mock Set-NSPAppSignature { [pscustomobject]@{ AppName = 'Fixture'; Thumbprint = 'ABC123'; SignedFiles = @(1, 2, 3) } } -ModuleName NSP.IntuneApps

        $signSummary = Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false
        Should -Invoke Set-NSPAppSignature -Times 1 -ModuleName NSP.IntuneApps
        $signSummary.CurrentStage | Should -Be 'Package'

        $packageSummary = Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false
        $packageSummary.CurrentStage | Should -Be 'CreateApp'
        $document = Get-Content -LiteralPath $runPath -Raw | ConvertFrom-Json
        ($document.Entries[0].Stages | Where-Object Name -eq 'Package').Status | Should -Be 'Succeeded'
    }

    It 'dispatches CreateApp, requires a matching tenant registration, and treats RecordManagementNotes as a no-op' {
        $root = Join-Path $TestDrive 'CreateAppDispatch'
        $runPath = New-FixtureRun -Root $root
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null
        Mock New-NSPAppPackage { [pscustomobject]@{ AppName = 'Fixture'; PackagePath = 'C:\fake\Fixture.intunewin' } } -ModuleName NSP.IntuneApps
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null
        Mock Set-NSPAppSignature { [pscustomobject]@{ AppName = 'Fixture'; Thumbprint = 'ABC123'; SignedFiles = @(1) } } -ModuleName NSP.IntuneApps
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null

        $packagePath = Join-Path $root 'Config\Local\Build\Fixture\DownloadInstall_Fixture.intunewin'
        New-Item -ItemType Directory -Path (Split-Path -Path $packagePath -Parent) -Force | Out-Null
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        $registrationDir = Join-Path $root 'Config\Local'
        New-Item -ItemType Directory -Path $registrationDir -Force | Out-Null
        [ordered]@{ TenantId = 'tenant-1'; ClientId = 'client-1'; AppName = 'NSP-IntuneApps-Win32AppDeployment'; CreatedAtUtc = (Get-Date).ToString('o'); GrantedScopes = @() } |
            ConvertTo-Json | Set-Content -LiteralPath (Join-Path $registrationDir 'GraphAppRegistration.json')

        Mock New-NSPIntuneWin32App {
            [pscustomobject]@{ Status = 'Created'; AppName = 'Fixture'; IntuneAppId = 'intune-app-1'; DisplayName = 'Fixture App'; TenantId = 'tenant-1'; ManagementNotes = '[NSP-IntuneApps:Fixture]' }
        } -ModuleName NSP.IntuneApps

        $createAppSummary = Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false

        Should -Invoke New-NSPIntuneWin32App -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $PackagePath -eq $packagePath -and $TenantId -eq 'tenant-1' -and $ClientId -eq 'client-1'
        }
        $createAppSummary.CurrentStage | Should -Be 'RecordManagementNotes'

        $finalSummary = Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false
        $finalSummary.Status | Should -Be 'Completed'
        $document = Get-Content -LiteralPath $runPath -Raw | ConvertFrom-Json
        ($document.Entries[0].Stages | Where-Object Name -eq 'CreateApp').Status | Should -Be 'Succeeded'
        ($document.Entries[0].Stages | Where-Object Name -eq 'RecordManagementNotes').Status | Should -Be 'Succeeded'
    }

    It 'fails CreateApp clearly when no tenant app registration is recorded' {
        $root = Join-Path $TestDrive 'CreateAppNoRegistration'
        $runPath = New-FixtureRun -Root $root
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null
        Mock New-NSPAppPackage { [pscustomobject]@{ AppName = 'Fixture'; PackagePath = 'C:\fake\Fixture.intunewin' } } -ModuleName NSP.IntuneApps
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null
        Mock Set-NSPAppSignature { [pscustomobject]@{ AppName = 'Fixture'; Thumbprint = 'ABC123'; SignedFiles = @(1) } } -ModuleName NSP.IntuneApps
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null

        $packagePath = Join-Path $root 'Config\Local\Build\Fixture\DownloadInstall_Fixture.intunewin'
        New-Item -ItemType Directory -Path (Split-Path -Path $packagePath -Parent) -Force | Out-Null
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        { Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false } | Should -Throw '*Register-NSPIntuneWin32AppRegistration*'
    }

    It 'fails stages belonging to not-yet-implemented executor paths clearly' {
        $root = Join-Path $TestDrive 'Unimplemented'
        $runPath = New-FixtureRun -Root $root -PlannedAction 'UpdateMetadataInPlace'
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null

        $summary = Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false

        $summary.Status | Should -Be 'AttentionRequired'
        $summary.CurrentStage | Should -Be 'PatchMetadata'
    }

    It 'returns the final summary without error once the run is already complete' {
        $root = Join-Path $TestDrive 'AlreadyDone'
        $runPath = New-FixtureRun -Root $root -PlannedAction 'NoChange'
        Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false | Out-Null

        $summary = Invoke-NSPAppDeploymentRunStage -RunPath $runPath -Execute -Confirm:$false
        $summary.Status | Should -Be 'Completed'
    }
}
