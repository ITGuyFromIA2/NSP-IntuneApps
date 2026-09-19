$repoRoot = Split-Path -Path $PSScriptRoot -Parent

Describe 'Deployment action resolver' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
        $metadataA = 'A' * 64
        $metadataB = 'B' * 64
        $contentA = 'C' * 64
        $contentB = 'D' * 64
        $notes = "[NSP-IntuneApps:ExampleApp]`n[NSP-Metadata-SHA256:$metadataA]`n[NSP-Content-SHA256:$contentA]"
        $managed = [pscustomobject]@{ Id='existing-id'; DisplayName='Example App'; Publisher='Network Systems Plus, Inc.'; Notes=$notes }
    }

    It 'creates when no app matches' {
        (Resolve-NSPAppDeploymentAction -SourceId ExampleApp -DisplayName 'Example App' -Publisher 'Network Systems Plus, Inc.' -MetadataSha256 $metadataA -ContentSha256 $contentA).Action | Should -Be 'Create'
    }

    It 'preserves the object id for compatible content changes' {
        $result = Resolve-NSPAppDeploymentAction -SourceId ExampleApp -DisplayName 'Example App' -Publisher 'Network Systems Plus, Inc.' -MetadataSha256 $metadataB -ContentSha256 $contentB -ExistingApp $managed
        $result.Action | Should -Be 'UpdateContentInPlace'
        $result.ExistingObjectId | Should -Be 'existing-id'
    }

    It 'uses side-by-side supersedence for a declared breaking change' {
        (Resolve-NSPAppDeploymentAction -SourceId ExampleApp -DisplayName 'Example App' -Publisher 'Network Systems Plus, Inc.' -MetadataSha256 $metadataB -ContentSha256 $contentB -ExistingApp $managed -BreakingChange).Action | Should -Be 'CreateSupersedingApp'
    }

    It 'requires review before adopting an unmarked app' {
        $unmarked = [pscustomobject]@{ Id='unmanaged'; DisplayName='Example App'; Publisher='Network Systems Plus, Inc.'; Notes='' }
        $result = Resolve-NSPAppDeploymentAction -SourceId ExampleApp -DisplayName 'Example App' -Publisher 'Network Systems Plus, Inc.' -MetadataSha256 $metadataA -ContentSha256 $contentA -ExistingApp $unmarked
        $result.Action | Should -Be 'AdoptOrReview'
        $result.CanExecute | Should -BeFalse
    }

    It 'stops on duplicate identities' {
        $duplicate = [pscustomobject]@{ Id='duplicate'; DisplayName='Other name'; Publisher='Other publisher'; Notes=$notes }
        (Resolve-NSPAppDeploymentAction -SourceId ExampleApp -DisplayName 'Example App' -Publisher 'Network Systems Plus, Inc.' -MetadataSha256 $metadataA -ContentSha256 $contentA -ExistingApp @($managed,$duplicate)).Action | Should -Be 'Conflict'
    }
}
