function Invoke-NSPGuidedTemplateWizardMenu {
    <#
    .SYNOPSIS
        Runs the guided-template chooser and dispatches to the matching generator, interactively.
    .DESCRIPTION
        Shared by the dashboard's standalone "Create from a guided template" action and its
        "build a tracker" flow, so a new app can be generated without leaving the tracker's app
        picker. Returns the generator's result object, which always exposes .Path (the new app's
        root folder under Apps\ or Config\Local\GeneratedApps\) when one was created, so a caller
        can fold it into an in-progress selection via Split-Path -Leaf. The installer-capture
        template records a capture sequence, not a new app, and returns $null.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$RepoRoot)

    Write-Host '[A] Drive map' -ForegroundColor Cyan
    Write-Host '[B] RDP / RemoteApp'
    Write-Host '[C] Printer driver / queue'
    Write-Host '[D] Capture an interactive installer sequence'
    Write-Host '[E] FortiClient VPN configuration'
    Write-Host '[F] Web / file shortcut'
    Write-Host '[G] Adobe Acrobat / Reader package'
    Write-Host '[H] Managed Reboots policy'
    $template = Read-NSPMenuChoice -Prompt 'Template' -Allowed @('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H') -Default 'A'
    switch ($template) {
        'A' { New-NSPDriveMapApp -RepoRoot $RepoRoot -Interactive }
        'B' { New-NSPRdpApp -RepoRoot $RepoRoot -Interactive }
        'C' { New-NSPPrinterApp -RepoRoot $RepoRoot -Interactive }
        'D' {
            Write-Host 'Example: C:\Temp\VendorSetup.exe' -ForegroundColor DarkGray
            $installerPath = Read-Host 'Installer path'
            Start-NSPInstallerCapture -InstallerPath $installerPath | Out-Null
            $null
        }
        'E' { New-NSPFortiClientVpnConfigApp -RepoRoot $RepoRoot -Interactive }
        'F' { New-NSPShortcutApp -RepoRoot $RepoRoot -Interactive }
        'G' { New-NSPAdobeApp -RepoRoot $RepoRoot -Interactive }
        'H' { New-NSPManagedRebootsApp -RepoRoot $RepoRoot -Interactive }
    }
}
