$script:intuneWin32AppAvailable = [bool](Get-Module -ListAvailable IntuneWin32App)

Describe 'Add-NSPIntuneWin32AppSupersedence' {
    BeforeAll {
        Import-Module (Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'NSP.IntuneApps.psd1') -Force
        if ($script:intuneWin32AppAvailable) { Import-Module IntuneWin32App -Force }
    }

    It 'reports a plan without connecting to any tenant when -Execute is not passed' {
        $result = Add-NSPIntuneWin32AppSupersedence -NewIntuneObjectId 'new-app-1' -NewAppDisplayName 'Fixture v2' -SupersededIntuneObjectId 'old-app-1' -SupersededAppDisplayName 'Fixture v1' -SupersedenceType Update -TenantId 'tenant-1' -ClientId 'client-1'

        $result.Status | Should -Be 'PlanOnly'
        $result.Message | Should -Match "Update-supersede 'Fixture v1' with 'Fixture v2'"
    }

    It 'defaults SupersedenceType to Update' {
        $result = Add-NSPIntuneWin32AppSupersedence -NewIntuneObjectId 'new-app-1' -SupersededIntuneObjectId 'old-app-1' -TenantId 'tenant-1' -ClientId 'client-1'

        $result.SupersedenceType | Should -Be 'Update'
    }

    It 'relates the new app to the superseded app' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Get-IntuneWin32AppSupersedence { @() } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppSupersedence { [ordered]@{ '@odata.type' = '#microsoft.graph.mobileAppSupersedence'; supersedenceType = 'update'; targetId = 'old-app-1' } } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppSupersedence { } -ModuleName NSP.IntuneApps

        $result = Add-NSPIntuneWin32AppSupersedence -NewIntuneObjectId 'new-app-1' -SupersededIntuneObjectId 'old-app-1' -SupersedenceType Update -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.Status | Should -Be 'Related'
        $result.GraphNodeCount | Should -Be 2
        Should -Invoke New-IntuneWin32AppSupersedence -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter { $ID -eq 'old-app-1' -and $SupersedenceType -eq 'Update' }
        Should -Invoke Add-IntuneWin32AppSupersedence -Times 1 -ModuleName NSP.IntuneApps -ParameterFilter { $ID -eq 'new-app-1' }
    }

    It 'counts every distinct node already in the chain before adding the new one' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Get-IntuneWin32AppSupersedence {
            switch ($ID) {
                'old-app-1' { @([pscustomobject]@{ targetId = 'old-app-2' }) }
                'old-app-2' { @([pscustomobject]@{ targetId = 'old-app-3' }) }
                default { @() }
            }
        } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppSupersedence { [ordered]@{ '@odata.type' = '#microsoft.graph.mobileAppSupersedence'; supersedenceType = 'update'; targetId = 'old-app-1' } } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppSupersedence { } -ModuleName NSP.IntuneApps

        $result = Add-NSPIntuneWin32AppSupersedence -NewIntuneObjectId 'new-app-1' -SupersededIntuneObjectId 'old-app-1' -SupersedenceType Update -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.GraphNodeCount | Should -Be 4
    }

    It 'refuses to add a relationship that would exceed the 10-node limit' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Get-IntuneWin32AppSupersedence {
            $index = [int]($ID -replace '\D', '')
            if ($index -lt 10) { @([pscustomobject]@{ targetId = "old-app-$($index + 1)" }) } else { @() }
        } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppSupersedence { } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppSupersedence { } -ModuleName NSP.IntuneApps

        { Add-NSPIntuneWin32AppSupersedence -NewIntuneObjectId 'new-app-1' -SupersededIntuneObjectId 'old-app-1' -SupersedenceType Update -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false } |
            Should -Throw "*over Intune's 10-node limit*"
        Should -Invoke Add-IntuneWin32AppSupersedence -Times 0 -ModuleName NSP.IntuneApps
    }

    It 'is cycle-safe when the existing chain loops back on itself' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { } -ModuleName NSP.IntuneApps
        Mock Get-IntuneWin32AppSupersedence {
            switch ($ID) {
                'old-app-1' { @([pscustomobject]@{ targetId = 'old-app-2' }) }
                'old-app-2' { @([pscustomobject]@{ targetId = 'old-app-1' }) }
                default { @() }
            }
        } -ModuleName NSP.IntuneApps
        Mock New-IntuneWin32AppSupersedence { [ordered]@{ '@odata.type' = '#microsoft.graph.mobileAppSupersedence'; supersedenceType = 'update'; targetId = 'old-app-1' } } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppSupersedence { } -ModuleName NSP.IntuneApps

        $result = Add-NSPIntuneWin32AppSupersedence -NewIntuneObjectId 'new-app-1' -SupersededIntuneObjectId 'old-app-1' -SupersedenceType Update -TenantId 'tenant-1' -ClientId 'client-1' -Execute -Confirm:$false

        $result.GraphNodeCount | Should -Be 3
    }

    It 'writes nothing under -WhatIf' -Skip:(-not $script:intuneWin32AppAvailable) {
        Mock Connect-MSIntuneGraph { throw 'should not be called' } -ModuleName NSP.IntuneApps
        Mock Add-IntuneWin32AppSupersedence { throw 'should not be called' } -ModuleName NSP.IntuneApps

        $result = Add-NSPIntuneWin32AppSupersedence -NewIntuneObjectId 'new-app-1' -SupersededIntuneObjectId 'old-app-1' -TenantId 'tenant-1' -ClientId 'client-1' -Execute -WhatIf
        $result | Should -BeNullOrEmpty
    }
}
