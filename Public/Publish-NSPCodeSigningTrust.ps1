function Publish-NSPCodeSigningTrust {
    <#
    .SYNOPSIS
        Reviews or explicitly executes an NSP code-signing trust deployment.
    .DESCRIPTION
        Plan-only is the default. Use -Execute and approve ShouldProcess to create or
        update the combined Root and TrustedPublisher profile. Existing conflicting
        layouts are never consolidated or deleted automatically.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [ValidateSet('AllDevices','Group','None')][string]$AssignmentTarget = 'AllDevices',
        [string]$GroupId,
        [switch]$Execute
    )

    $plan = Get-NSPCodeSigningTrustPlan -RepoRoot $RepoRoot -AssignmentTarget $AssignmentTarget -GroupId $GroupId -Connect:$Execute -WriteAccess:$Execute
    if (-not $Execute) { return $plan }
    if (@($plan.Conflicts).Count -gt 0) { throw "Execution stopped because conflicts were found: $($plan.Conflicts -join '; ')" }
    if (-not $plan.CanExecute) { throw 'The plan is not executable. Confirm Graph authentication and resolve any conflicts.' }
    if ($plan.Action -eq 'NoChange') {
        Write-Warning "The expected generation is already present in profile $($plan.ExistingProfile.id). No profile content was changed."
        return $plan
    }
    if (-not $PSCmdlet.ShouldProcess("tenant $($plan.TenantId), assignment $AssignmentTarget", "$($plan.Action) '$($plan.ProfileName)'")) { return $plan }

    $newSettings = @(
        @{ '@odata.type'='#microsoft.graph.omaSettingBase64'; displayName="NSP Code Signing $($plan.Thumbprint.Substring($plan.Thumbprint.Length - 8)) - Root"; description='Trusts the NSP self-signed root certificate.'; omaUri=$plan.RootOmaUri; fileName='NSP-CodeSigning-Root.cer'; value=$plan.CertificateBase64 }
        @{ '@odata.type'='#microsoft.graph.omaSettingBase64'; displayName="NSP Code Signing $($plan.Thumbprint.Substring($plan.Thumbprint.Length - 8)) - Trusted Publisher"; description='Trusts NSP as an Authenticode publisher.'; omaUri=$plan.TrustedPublisherOmaUri; fileName='NSP-CodeSigning-Publisher.cer'; value=$plan.CertificateBase64 }
    )
    $settings = @($plan.ExistingSettings) + @($newSettings | Where-Object omaUri -in $plan.MissingUris)
    $bodyObject = @{
        displayName=$plan.ProfileName
        description='NSP Authenticode trust. Old generations remain trusted so correctly timestamped packages continue to validate.'
        omaSettings=$settings
    }
    if (-not $plan.ExistingProfile) { $bodyObject['@odata.type'] = '#microsoft.graph.windows10CustomConfiguration' }
    $body = $bodyObject | ConvertTo-Json -Depth 12
    if ($plan.ExistingProfile) {
        Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($plan.ExistingProfile.id)" -Body $body -ContentType 'application/json' | Out-Null
        $profile = $plan.ExistingProfile
    } else {
        $profile = Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations' -Body $body -ContentType 'application/json' -OutputType PSObject -ErrorAction Stop
    }

    try {
        if ($AssignmentTarget -ne 'None') {
            $target = if ($AssignmentTarget -eq 'AllDevices') {
                @{ '@odata.type'='#microsoft.graph.allDevicesAssignmentTarget' }
            } else {
                @{ '@odata.type'='#microsoft.graph.groupAssignmentTarget'; groupId=$GroupId }
            }
            $assignmentBody = @{ assignments=@(@{ target=$target }) } | ConvertTo-Json -Depth 8
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($profile.id)/assign" -Body $assignmentBody -ContentType 'application/json' | Out-Null
        }
    } catch {
        throw "Profile $($profile.id) was changed, but assignment failed. It was left in place for recovery. $($_.Exception.Message)"
    }

    [pscustomobject]@{ Status=$plan.Action; ProfileId=$profile.id; ProfileName=$plan.ProfileName; TenantId=$plan.TenantId; AssignmentTarget=$AssignmentTarget }
}
