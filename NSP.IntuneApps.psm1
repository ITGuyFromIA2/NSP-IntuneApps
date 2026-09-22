$moduleRoot = $PSScriptRoot

foreach ($folder in @('Private', 'Public')) {
    $path = Join-Path $moduleRoot $folder
    if (Test-Path -LiteralPath $path) {
        Get-ChildItem -LiteralPath $path -Filter '*.ps1' -File |
            Sort-Object Name |
            ForEach-Object { . $_.FullName }
    }
}

Export-ModuleMember -Function @(
    'Export-NSPAppDeploymentRunReport'
    'Get-NSPIntuneAppCatalog'
    'Get-NSPIntuneAppInventory'
    'Get-NSPAppSourceState'
    'Get-NSPAppDeploymentPlanSummary'
    'Get-NSPAppDeploymentPlanReview'
    'Get-NSPAppDeploymentRunSummary'
    'Test-NSPIntuneAppsPreflight'
    'Start-NSPIntuneApps'
    'New-NSPDriveMapApp'
    'New-NSPAdobeApp'
    'New-NSPManagedRebootsApp'
    'New-NSPFortiClientVpnConfigApp'
    'New-NSPRdpApp'
    'New-NSPShortcutApp'
    'New-NSPPrinterApp'
    'Start-NSPInstallerCapture'
    'Test-NSPInteractiveInstallerCapture'
    'New-NSPAppDeploymentPlan'
    'New-NSPAppDeploymentRun'
    'Set-NSPAppDeploymentDecisions'
    'Set-NSPAppDeploymentRunStage'
    'Update-NSPAppDeploymentPlan'
    'Resolve-NSPAppDeploymentAction'
    'Get-NSPReleaseAsset'
    'New-NSPCodeSigningCertificate'
    'Get-NSPCodeSigningCertificate'
    'Get-NSPCodeSigningTrustPlan'
    'Publish-NSPCodeSigningTrust'
    'Register-NSPIntuneWin32AppRegistration'
    'Set-NSPAppSignature'
    'New-NSPAppPackage'
    'New-NSPIntuneWin32App'
    'Invoke-NSPAppDeploymentRunStage'
    'Update-NSPIntuneWin32AppContent'
    'Set-NSPAppManagementNotes'
    'Remove-NSPIntuneWin32App'
    'Get-NSPIntuneAppAssignmentInventory'
)
