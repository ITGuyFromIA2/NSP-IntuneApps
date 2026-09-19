$repoRoot = Split-Path -Path $PSScriptRoot -Parent

Describe 'Printer release manifests' {
    BeforeAll {
        $manifestRoot = Join-Path $repoRoot 'Artifacts\PrinterDrivers'
        $manifests = @(Get-ChildItem -LiteralPath $manifestRoot -File -Filter '*.release.json')
    }

    It 'contains the curated Canon and HP first-wave manifests' {
        $manifests.Name | Should -Contain 'Canon-Generic-Plus-UFR-II-v2.72.0.0.release.json'
        $manifests.Name | Should -Contain 'HP-Universal-PCL6-v61.240.01.24630.release.json'
    }

    It 'uses complete hash-pinned release metadata for every curated manifest' {
        foreach ($manifestFile in $manifests) {
            $manifest = Get-Content -LiteralPath $manifestFile.FullName -Raw | ConvertFrom-Json
            $manifest.Repository | Should -Be 'ITGuyFromIA2/NSP-IntuneApps'
            $manifest.Tag | Should -Match '^printer-drivers-v\d+$'
            $manifest.AssetName | Should -Match '\.zip$'
            $manifest.Sha256 | Should -Match '^[A-F0-9]{64}$'
            $manifest.InfRelativePath | Should -Match '\.inf$'
            $manifest.DriverName | Should -Not -BeNullOrEmpty
            ($manifest | ConvertTo-Json -Depth 5) | Should -Not -Match 'REPLACE_WITH_'
        }
    }

    It 'does not track staged ZIP payloads in normal Git source' {
        $trackedZip = @(git -C $repoRoot ls-files 'Artifacts/PrinterDrivers/*.zip')
        $trackedZip.Count | Should -Be 0
    }

    It 'uses only documentation addresses in sanitized first-wave queue examples' {
        $exampleRoot = Join-Path $repoRoot 'Templates\Printers\Examples'
        $examples = @(Get-ChildItem -LiteralPath $exampleRoot -File -Filter '*.example.json')
        $examples.Count | Should -Be 2
        foreach ($exampleFile in $examples) {
            $example = Get-Content -LiteralPath $exampleFile.FullName -Raw | ConvertFrom-Json
            $example.HostAddress | Should -Match '^(192\.0\.2|198\.51\.100|203\.0\.113)\.'
            $example.DriverName | Should -Not -BeNullOrEmpty
            $example.DriverAppName | Should -Not -BeNullOrEmpty
        }
    }
}
