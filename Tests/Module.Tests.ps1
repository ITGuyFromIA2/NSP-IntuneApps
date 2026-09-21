Describe 'NSP.IntuneApps module' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        $manifest = Join-Path $repoRoot 'NSP.IntuneApps.psd1'
        Import-Module $manifest -Force
    }

    It 'exports every function declared by the manifest' {
        $declared = (Import-PowerShellDataFile -LiteralPath $manifest).FunctionsToExport | Sort-Object
        $actual = Get-Command -Module NSP.IntuneApps | Select-Object -ExpandProperty Name | Sort-Object
        Compare-Object $declared $actual | Should -BeNullOrEmpty
    }

    It 'passes repository preflight without parser blockers' {
        $result = Test-NSPIntuneAppsPreflight -RepoRoot $repoRoot
        @($result.SyntaxErrors).Count | Should -Be 0
        @($result.Results | Where-Object { $_.Name -eq 'Duplicate deployable identities' -and $_.Status -eq 'Blocked' }).Count | Should -Be 0
        @($result.EmbeddedAssignments).Count | Should -Be 0
        @($result.MissingDeployableIdentity).Count | Should -Be 0
        @($result.MutatingDeployableSettings).Count | Should -Be 0
        @($result.EmbeddedSecrets).Count | Should -Be 0
        @($result.OperationalIdentifiers).Count | Should -Be 0
        @($result.PrivateKeyArtifacts).Count | Should -Be 0
        @($result.BinaryPayloads).Count | Should -Be 0
    }

    It 'blocks literal Bitdefender GravityZone package identifiers' {
        $fixtureRoot = Join-Path $TestDrive 'Repo'
        New-Item -ItemType Directory -Path (Join-Path $fixtureRoot 'Apps\Fixture\Source') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $fixtureRoot 'Apps\Create_UploadToIntune_SplitScript.ps1') -Value '# intentionally disabled'
        Set-Content -LiteralPath (Join-Path $fixtureRoot 'Apps\Fixture\Source\Install.ps1') -Value 'msiexec /i wrapper.msi /qn GZ_PACKAGE_ID=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

        Mock Get-NSPIntuneAppCatalog { @() } -ModuleName NSP.IntuneApps
        Mock Get-NSPCodeSigningConfiguration { [pscustomobject]@{ Current=[pscustomobject]@{ Thumbprint='' }; CodeSigningDir=$fixtureRoot } } -ModuleName NSP.IntuneApps

        $result = Test-NSPIntuneAppsPreflight -RepoRoot $fixtureRoot
        @($result.OperationalIdentifiers).Count | Should -Be 1
        @($result.Results | Where-Object { $_.Name -eq 'Embedded operational deployment identifiers' }).Status | Should -Be 'Blocked'
    }

    It 'preserves TRAFx identity while excluding its incorrect scaffold from deployment planning' {
        $entry = Get-NSPIntuneAppCatalog -RepoRoot $repoRoot | Where-Object Name -eq 'TRAFx'
        $entry.Classification | Should -Be 'RequiresRepair'
        $entry.Replacement | Should -BeNullOrEmpty
        $entry.Reason | Should -Match 'distinct application'
    }

    It 'keeps the hard-coded RDS prototype out of deployment planning' {
        $entry = Get-NSPIntuneAppCatalog -RepoRoot $repoRoot | Where-Object Name -eq 'RemoteDesktop-Shortcut'
        $entry.Classification | Should -Be 'RetiredTemplate'
        $entry.Replacement | Should -Be 'New-NSPRdpApp'
    }

    It 'requires generation of a client-specific FortiClient VPN configuration' {
        $entry = Get-NSPIntuneAppCatalog -RepoRoot $repoRoot | Where-Object Name -eq 'FortiClient_ImportConfig'
        $entry.Classification | Should -Be 'RequiresConfiguration'
        $entry.ConfigurationMarkerCount | Should -BeGreaterThan 0
    }

    It 'keeps generated Intune packages out of source control' {
        Get-Content -LiteralPath (Join-Path $repoRoot '.gitignore') | Should -Contain '*.intunewin'
        @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'Apps') -Recurse -File -Filter '*.intunewin').Count | Should -Be 0
    }

    It 'keeps private keys and executable payloads out of public source control' {
        $ignore = Get-Content -LiteralPath (Join-Path $repoRoot '.gitignore')
        $ignore | Should -Contain '*.pfx'
        $ignore | Should -Contain '*.exe'
        $result = Test-NSPIntuneAppsPreflight -RepoRoot $repoRoot
        @($result.PrivateKeyArtifacts).Count | Should -Be 0
        @($result.BinaryPayloads).Count | Should -Be 0
    }

    It 'keeps the Gen1 delete/recreate uploader guarded' {
        (Get-Content -LiteralPath (Join-Path $repoRoot 'Apps\Create_UploadToIntune_SplitScript.ps1') -TotalCount 3) -join "`n" | Should -Match 'intentionally disabled'
    }

    It 'keeps settings files free of doubled carriage-return line endings' {
        foreach ($file in Get-ChildItem -LiteralPath (Join-Path $repoRoot 'Apps') -Recurse -File -Filter '*_SplitScriptSettings.ps1') {
            $bytes = [IO.File]::ReadAllBytes($file.FullName)
            $hasDoubledCarriageReturn = $false
            for ($index = 0; $index -lt ($bytes.Length - 2); $index++) {
                if ($bytes[$index] -eq 13 -and $bytes[$index + 1] -eq 13 -and $bytes[$index + 2] -eq 10) {
                    $hasDoubledCarriageReturn = $true
                    break
                }
            }
            $hasDoubledCarriageReturn | Should -BeFalse -Because $file.FullName
        }
    }

    It 'does not contain known downstream client markers' {
        $pattern = 'simpco|greenberg|chesterman|klass|scigrain|sscha|hnrco|\bHnR\b|gm\.nsp|gmrds|accubuild|caasiouxland|sschousingagency'
        $files = @(Get-ChildItem -LiteralPath $repoRoot -Recurse -File |
            Where-Object { $_.FullName -notlike '*\.git\*' -and $_.Name -notin @('Test-NSPIntuneAppsPreflight.ps1','Module.Tests.ps1') })
        $matches = @($files |
            Where-Object { $_.Extension -in @('.ps1','.psd1','.json','.md','.txt','.reg','.xml','.ini','.cmd','.bat') } |
            Select-String -Pattern $pattern)
        $pathMatches = @($files | Where-Object FullName -Match $pattern)
        $matches.Count | Should -Be 0
        $pathMatches.Count | Should -Be 0
    }
}
