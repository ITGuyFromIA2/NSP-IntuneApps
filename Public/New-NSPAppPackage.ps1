function New-NSPAppPackage {
    <#
    .SYNOPSIS
        Builds the .intunewin package for a catalog app: the Build and Package stages.
    .DESCRIPTION
        Entirely offline: no Graph connection, no tenant contact. Resolves the app's build
        inputs via Resolve-NSPAppBuildPlan, then produces the .intunewin package with the
        IntuneWin32App module and returns its full metadata alongside the resolved build plan.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$AppName,
        [string]$OutputPath
    )

    $entry = Get-NSPIntuneAppCatalog -RepoRoot $RepoRoot | Where-Object Name -eq $AppName
    if (-not $entry) { throw "App was not found in the catalog: $AppName" }
    if (-not $entry.SettingsPath) { throw "App does not have one settings file: $AppName" }

    $VariableConfig = $null
    . $entry.SettingsPath
    $buildPlan = Resolve-NSPAppBuildPlan -Name $AppName -SettingsPath $entry.SettingsPath -Path $entry.Path -VariableConfig $VariableConfig

    if (-not $OutputPath) { $OutputPath = Join-Path $RepoRoot "Config\Local\Build\$AppName" }

    if (-not $PSCmdlet.ShouldProcess($OutputPath, "Build the Win32 app package for '$AppName'")) { return }

    if (-not (Get-Module -ListAvailable IntuneWin32App)) {
        Import-NSPBootstrap | Out-Null
        Install-NSPModule -Name IntuneWin32App -Scope CurrentUser
    }
    Import-Module IntuneWin32App -ErrorAction Stop

    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    $package = New-IntuneWin32AppPackage -SourceFolder $buildPlan.SourceFolder -SetupFile $buildPlan.SetupFileName -OutputFolder $OutputPath -Force
    if (-not $package) { throw "Packaging failed for app '$AppName'. See the IntuneWinAppUtil.exe output above for details." }
    $metadata = Get-IntuneWin32AppMetaData -FilePath $package.Path

    [pscustomobject]@{
        AppName     = $AppName
        PackagePath = $package.Path
        Metadata    = $metadata
        BuildPlan   = $buildPlan
    }
}
