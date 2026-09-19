[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
param(
    [ValidateSet('Offline','Networked')]
    [string]$Mode = 'Offline',
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$resultRoot = Join-Path $repoRoot 'Config\Local\SandboxResults'
New-Item -ItemType Directory -Path $resultRoot -Force | Out-Null
if (-not $OutputPath) {
    $OutputPath = Join-Path (Join-Path $repoRoot 'Config\Local') ("NSP-IntuneApps-{0}.wsb" -f $Mode)
}

$networking = if ($Mode -eq 'Networked') { 'Enable' } else { 'Disable' }
$escapedRepo = [Security.SecurityElement]::Escape($repoRoot)
$escapedResults = [Security.SecurityElement]::Escape($resultRoot)
$configuration = @"
<Configuration>
  <VGpu>Disable</VGpu>
  <Networking>$networking</Networking>
  <AudioInput>Disable</AudioInput>
  <VideoInput>Disable</VideoInput>
  <PrinterRedirection>Disable</PrinterRedirection>
  <ClipboardRedirection>Disable</ClipboardRedirection>
  <ProtectedClient>Enable</ProtectedClient>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>$escapedRepo</HostFolder>
      <SandboxFolder>C:\NSP-IntuneApps</SandboxFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
    <MappedFolder>
      <HostFolder>$escapedResults</HostFolder>
      <SandboxFolder>C:\NSP-Results</SandboxFolder>
      <ReadOnly>false</ReadOnly>
    </MappedFolder>
  </MappedFolders>
  <LogonCommand>
    <Command>powershell.exe -NoLogo -NoExit -ExecutionPolicy Bypass -Command "&amp; 'C:\NSP-IntuneApps\tools\VM\Test-NSPTestVMReadiness.ps1' -OutputPath 'C:\NSP-Results\Readiness.json'"</Command>
  </LogonCommand>
</Configuration>
"@

if ($PSCmdlet.ShouldProcess($OutputPath, "Create $Mode Windows Sandbox configuration")) {
    $parent = Split-Path -Path $OutputPath -Parent
    if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $configuration | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    Get-Item -LiteralPath $OutputPath
}

