$script:intuneWin32AppAvailable = [bool](Get-Module -ListAvailable IntuneWin32App)

Describe 'New-NSPIntuneWin32App' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
        if ($script:intuneWin32AppAvailable) { Import-Module IntuneWin32App -Force }

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

        function New-FixtureRegistryDetectionRepo {
            param([string]$Root)
            $appRoot = Join-Path $Root 'Apps\Fixture'
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Source') -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $appRoot 'Detect') -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\DownloadInstall_Fixture.ps1') -Value '# setup'
            Set-Content -LiteralPath (Join-Path $appRoot 'Source\Uninstall_Fixture.ps1') -Value '# uninstall'
            $settings = @'
$VariableConfig = @{}
$VariableConfig.DisplayName = 'Fixture App'
$VariableConfig.Description = 'Fixture description.'
$VariableConfig.Publisher = 'Fixture Publisher'
$VariableConfig.IsFeatured = $false
$VariableConfig.Category = @('Computer Management')
$VariableConfig.SetupType = 'PoSH_sysnative'
$VariableConfig.InstallExperience = 'system'
$VariableConfig.RestartExperience = 'basedOnReturnCode'
$VariableConfig.REQ_Architecture = 'All'
$VariableConfig.REQ_MinWindowsRelase = 'W10_1607'
$VariableConfig.DetectionStyle = 'Registry_Exist'
$VariableConfig.Detection_KeyPath = 'HKEY_LOCAL_MACHINE\SOFTWARE\Fixture'
$VariableConfig.Detection_ValueName = 'Installed'
$VariableConfig.SetupFile_Filter = 'DownloadInstall_*.ps1'
$VariableConfig.PoSH = @{ Sign_SourceFilter = '*.ps1'; UninstallFile_Filter = 'Uninstall_*.ps1' }
$VariableConfig.EnforceSignature_Detection = $true
$VariableConfig.RunAs32Bit_Detection = $false
'@
            Set-Content -LiteralPath (Join-Path $appRoot 'Fixture_SplitScriptSettings.ps1') -Value $settings
        }
    }

    It 'reports a plan without connecting to any tenant when -Execute is not passed' {
        $repoRoot = Join-Path $TestDrive 'PlanOnly'
        New-FixtureRepo -Root $repoRoot
        $packagePath = Join-Path $TestDrive 'PlanOnly\Fixture.intunewin'
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        $result = New-NSPIntuneWin32App -RepoRoot $repoRoot -AppName 'Fixture' -PackagePath $packagePath -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.DisplayName | Should -Be 'Fixture App'
    }

    It 'throws when the package file does not exist' {
        $repoRoot = Join-Path $TestDrive 'MissingPackage'
        New-FixtureRepo -Root $repoRoot
        { New-NSPIntuneWin32App -RepoRoot $repoRoot -AppName 'Fixture' -PackagePath (Join-Path $TestDrive 'MissingPackage\nope.intunewin') -TenantId 'tenant-1' -ClientId 'client-1' } |
            Should -Throw '*Package not found*'
    }

    It 'creates the app and records management notes via a separate PATCH' -Skip:(-not $script:intuneWin32AppAvailable) {
        $repoRoot = Join-Path $TestDrive 'CreateApp'
        New-FixtureRepo -Root $repoRoot
        $packagePath = Join-Path $repoRoot 'Fixture.intunewin'
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppDetectionRuleScript { [ordered]@{ '@odata.type' = 'fake.detectionRule' } } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppRequirementRule { [ordered]@{ '@odata.type' = 'fake.requirementRule' } } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32App { [pscustomobject]@{ id = 'intune-app-1' } } -ModuleName NSP.IntuneApps
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { [pscustomobject]@{} } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneWin32App -RepoRoot $repoRoot -AppName 'Fixture' -PackagePath $packagePath -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Created'
        $result.IntuneAppId | Should -Be 'intune-app-1'
        $result.ManagementNotes | Should -Match '\[NSP-IntuneApps:Fixture\]'
        Should -Invoke Add-IntuneWin32App -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter { $null -eq $Notes }
        Should -Invoke Invoke-MgGraphRequest -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Method -eq 'PATCH' -and $Uri -eq 'https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/intune-app-1'
        }
    }

    It 'throws when Graph returns an error payload for the notes PATCH without actually throwing' -Skip:(-not $script:intuneWin32AppAvailable) {
        $repoRoot = Join-Path $TestDrive 'NotesErrorPayload'
        New-FixtureRepo -Root $repoRoot
        $packagePath = Join-Path $repoRoot 'Fixture.intunewin'
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppDetectionRuleScript { [ordered]@{ '@odata.type' = 'fake.detectionRule' } } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppRequirementRule { [ordered]@{ '@odata.type' = 'fake.requirementRule' } } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32App { [pscustomobject]@{ id = 'intune-app-1' } } -ModuleName NSP.IntuneApps
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { [pscustomobject]@{ error = [pscustomobject]@{ code = 'BadRequest'; message = 'Notes were rejected.' } } } -ModuleName NSP.IntuneApps

        { New-NSPIntuneWin32App -RepoRoot $repoRoot -AppName 'Fixture' -PackagePath $packagePath -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false } |
            Should -Throw '*Graph rejected the management-notes PATCH*Notes were rejected*'
    }

    It 'throws instead of patching notes when the second Graph session lands in the wrong tenant' -Skip:(-not $script:intuneWin32AppAvailable) {
        $repoRoot = Join-Path $TestDrive 'TenantMismatch'
        New-FixtureRepo -Root $repoRoot
        $packagePath = Join-Path $repoRoot 'Fixture.intunewin'
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppDetectionRuleScript { [ordered]@{ '@odata.type' = 'fake.detectionRule' } } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppRequirementRule { [ordered]@{ '@odata.type' = 'fake.requirementRule' } } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32App { [pscustomobject]@{ id = 'intune-app-1' } } -ModuleName NSP.IntuneApps
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-2'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { throw 'should not be called' } -ModuleName NSP.IntuneApps

        { New-NSPIntuneWin32App -RepoRoot $repoRoot -AppName 'Fixture' -PackagePath $packagePath -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false } |
            Should -Throw '*tenant-2*'
    }

    It 'builds a registry detection rule instead of a script rule for DetectionStyle Registry_Exist' -Skip:(-not $script:intuneWin32AppAvailable) {
        $repoRoot = Join-Path $TestDrive 'RegistryDetection'
        New-FixtureRegistryDetectionRepo -Root $repoRoot
        $packagePath = Join-Path $repoRoot 'Fixture.intunewin'
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppDetectionRuleScript { throw 'should not be called for Registry_Exist' } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppDetectionRuleRegistry { [ordered]@{ '@odata.type' = 'fake.registryDetectionRule' } } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppRequirementRule { [ordered]@{ '@odata.type' = 'fake.requirementRule' } } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32App { [pscustomobject]@{ id = 'intune-app-1' } } -ModuleName NSP.IntuneApps
        Mock Connect-NSPGraph { [pscustomobject]@{ TenantId = 'tenant-1'; Account = 'operator@example.com' } } -ModuleName NSP.IntuneApps
        Mock Invoke-MgGraphRequest { [pscustomobject]@{} } -ModuleName NSP.IntuneApps

        $result = New-NSPIntuneWin32App -RepoRoot $repoRoot -AppName 'Fixture' -PackagePath $packagePath -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Created'
        Should -Invoke New-IntuneWin32AppDetectionRuleRegistry -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $Existence -eq $true -and $KeyPath -eq 'HKEY_LOCAL_MACHINE\SOFTWARE\Fixture' -and $ValueName -eq 'Installed' -and $DetectionType -eq 'exists'
        }
        Should -Invoke Add-IntuneWin32App -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter {
            $InstallCommandLine -match '^%windir%\\Sysnative\\WindowsPowerShell\\v1\.0\\powershell\.exe '
        }
    }

    It 'throws clearly when app creation does not return a result' -Skip:(-not $script:intuneWin32AppAvailable) {
        $repoRoot = Join-Path $TestDrive 'CreateFailure'
        New-FixtureRepo -Root $repoRoot
        $packagePath = Join-Path $repoRoot 'Fixture.intunewin'
        New-Item -ItemType File -Path $packagePath -Force | Out-Null

        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppDetectionRuleScript { [ordered]@{ '@odata.type' = 'fake.detectionRule' } } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppRequirementRule { [ordered]@{ '@odata.type' = 'fake.requirementRule' } } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32App { $null } -ModuleName NSP.IntuneApps

        { New-NSPIntuneWin32App -RepoRoot $repoRoot -AppName 'Fixture' -PackagePath $packagePath -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false } |
            Should -Throw '*did not return the created app*'
    }
}
