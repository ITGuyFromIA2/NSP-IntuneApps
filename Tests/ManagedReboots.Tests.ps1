Describe 'Managed Reboots policy' {
    BeforeAll {
        $repoRoot = Split-Path -Path $PSScriptRoot -Parent
        Import-Module (Join-Path $repoRoot 'NSP.IntuneApps.psd1') -Force
        . (Join-Path $repoRoot 'Templates\ManagedReboots\Source\ManagedReboots.Core.ps1')
        $policy = [pscustomobject]@{ GraceHours=24; DeferralHours=4; MaxDeferrals=2; MaxUptimeDays=14 }
        $boot = [datetime]'2026-09-01T00:00:00Z'
        $now = [datetime]'2026-09-18T12:00:00Z'
    }

    It 'creates a notification and fixed hard deadline when a reboot condition begins' {
        $result = Get-NSPManagedRebootTransition -Policy $policy -Signals @('Maximum uptime') -NowUtc $now -BootTimeUtc $boot
        $result.Action | Should -Be 'Notify'
        ([datetime]$result.State.DeadlineUtc) | Should -Be $now.AddHours(24)
    }

    It 'defers the next prompt without moving the hard deadline' {
        $initial = Get-NSPManagedRebootTransition -Policy $policy -Signals @('Maximum uptime') -NowUtc $now -BootTimeUtc $boot
        $response = [pscustomobject]@{ Id='one'; Result='Defer'; TimestampUtc=$now.ToString('o') }
        $deferred = Get-NSPManagedRebootTransition -Policy $policy -State $initial.State -Signals @('Maximum uptime') -Responses @($response) -NowUtc $now -BootTimeUtc $boot
        $deferred.Action | Should -Be 'Wait'
        $deferred.State.DeferralCount | Should -Be 1
        ([datetime]$deferred.State.DeadlineUtc) | Should -Be ([datetime]$initial.State.DeadlineUtc)
    }

    It 'requires reboot at the hard deadline even with no user response' {
        $initial = Get-NSPManagedRebootTransition -Policy $policy -Signals @('Windows Update') -NowUtc $now -BootTimeUtc $boot
        $expired = Get-NSPManagedRebootTransition -Policy $policy -State $initial.State -Signals @('Windows Update') -NowUtc $now.AddHours(24) -BootTimeUtc $boot
        $expired.Action | Should -Be 'Reboot'
    }

    It 'ignores a malformed response rather than crashing the evaluator' {
        $initial = Get-NSPManagedRebootTransition -Policy $policy -Signals @('Windows Update') -NowUtc $now -BootTimeUtc $boot
        $bad = [pscustomobject]@{ Id='bad'; Result='Defer'; TimestampUtc='not-a-time' }
        { $script:malformed = Get-NSPManagedRebootTransition -Policy $policy -State $initial.State -Signals @('Windows Update') -Responses @($bad) -NowUtc $now -BootTimeUtc $boot } | Should -Not -Throw
        $script:malformed.State.DeferralCount | Should -Be 0
    }

    It 'clears prior state after a real reboot' {
        $initial = Get-NSPManagedRebootTransition -Policy $policy -Signals @('Maximum uptime') -NowUtc $now -BootTimeUtc $boot
        $cleared = Get-NSPManagedRebootTransition -Policy $policy -State $initial.State -Signals @() -NowUtc $now.AddHours(1) -BootTimeUtc $now.AddMinutes(30)
        $cleared.Action | Should -Be 'None'
        $cleared.State.DeferralCount | Should -Be 0
        $cleared.State.RequiredSinceUtc | Should -BeNullOrEmpty
    }

    It 'generates a self-contained app using the SuperScript-derived prompt bridge' {
        $result = New-NSPManagedRebootsApp -RepoRoot $repoRoot -OutputRoot (Join-Path $TestDrive 'apps')
        $text = (Get-ChildItem -LiteralPath $result.Path -Recurse -File | Where-Object Extension -in @('.ps1','.json') | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
        $text | Should -Match 'WTSEnumerateSessions'
        $text | Should -Match 'AssignmentColl = @\(\)'
        $text | Should -Not -Match 'ServiceUI|AnyBox|Install-Module|PSGallery|C:\\admin'
    }
}
