$script:gitAvailable = [bool](Get-Command git -ErrorAction SilentlyContinue)

Describe 'Test-NSPPublicUpstreamRepository' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
    }

    It 'returns true when origin points at the public NSP-IntuneApps repository' -Skip:(-not $script:gitAvailable) {
        $repoRoot = Join-Path $TestDrive 'public-origin'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null
        git -C $repoRoot init -q
        git -C $repoRoot remote add origin 'https://github.com/ITGuyFromIA2/NSP-IntuneApps.git'

        InModuleScope NSP.IntuneApps -Parameters @{ RepoRoot = $repoRoot } {
            Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot | Should -BeTrue
        }
    }

    It 'returns false when origin points at a downstream fork' -Skip:(-not $script:gitAvailable) {
        $repoRoot = Join-Path $TestDrive 'fork-origin'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null
        git -C $repoRoot init -q
        git -C $repoRoot remote add origin 'https://github.com/SomeClient/CLIENT-IntuneApps.git'

        InModuleScope NSP.IntuneApps -Parameters @{ RepoRoot = $repoRoot } {
            Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot | Should -BeFalse
        }
    }

    It 'returns false when there is no origin remote at all' -Skip:(-not $script:gitAvailable) {
        $repoRoot = Join-Path $TestDrive 'no-origin'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null
        git -C $repoRoot init -q

        InModuleScope NSP.IntuneApps -Parameters @{ RepoRoot = $repoRoot } {
            Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot | Should -BeFalse
        }
    }

    It 'returns false rather than throwing when RepoRoot is not a git repository at all' {
        $repoRoot = Join-Path $TestDrive 'not-a-repo'
        New-Item -ItemType Directory -Path $repoRoot -Force | Out-Null

        InModuleScope NSP.IntuneApps -Parameters @{ RepoRoot = $repoRoot } {
            Test-NSPPublicUpstreamRepository -RepoRoot $RepoRoot | Should -BeFalse
        }
    }
}

Describe 'Guided template default output location' {
    BeforeAll {
        $realRepoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $realRepoRoot 'NSP.IntuneApps.psd1') -Force

        function New-FixtureRepoWithTemplates {
            param([string]$Path, [string]$OriginUrl)
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            git -C $Path init -q
            git -C $Path remote add origin $OriginUrl
            Copy-Item -LiteralPath (Join-Path $realRepoRoot 'Templates\DriveMaps') -Destination (Join-Path $Path 'Templates\DriveMaps') -Recurse -Force
        }
    }

    It 'defaults New-NSPDriveMapApp to Apps\ outside the public upstream repo' -Skip:(-not $script:gitAvailable) {
        $repoRoot = Join-Path $TestDrive 'downstream-default'
        New-FixtureRepoWithTemplates -Path $repoRoot -OriginUrl 'https://github.com/SomeClient/CLIENT-IntuneApps.git'

        $result = New-NSPDriveMapApp -RepoRoot $repoRoot -Name 'Example Shared Drive' -DriveLetter S -Path '\\files.example.invalid\Shared'

        $result.Path | Should -Be (Join-Path $repoRoot 'Apps\DriveMapExampleSharedDrive')
        Test-Path -LiteralPath (Join-Path $result.Path 'Source\Install-DriveMap.ps1') | Should -BeTrue
    }

    It 'defaults New-NSPDriveMapApp to the ignored local folder inside the public upstream repo' -Skip:(-not $script:gitAvailable) {
        $repoRoot = Join-Path $TestDrive 'public-default'
        New-FixtureRepoWithTemplates -Path $repoRoot -OriginUrl 'https://github.com/ITGuyFromIA2/NSP-IntuneApps.git'

        $result = New-NSPDriveMapApp -RepoRoot $repoRoot -Name 'Example Shared Drive' -DriveLetter S -Path '\\files.example.invalid\Shared'

        $result.Path | Should -Be (Join-Path $repoRoot 'Config\Local\GeneratedApps\DriveMapExampleSharedDrive')
        Test-Path -LiteralPath (Join-Path $result.Path 'Source\Install-DriveMap.ps1') | Should -BeTrue
    }
}
