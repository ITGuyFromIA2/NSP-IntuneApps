function Start-NSPInstallerCapture {
    <#
    .SYNOPSIS
        Launches an installer and records a reviewed draft of its UI states and actions.
    .DESCRIPTION
        Ctrl+Shift+F12 captures the foreground window and focused control without moving
        focus back to PowerShell. Ctrl+Shift+F11 ends observation. The technician then
        reviews each observation and describes the intended action. Sensitive data is
        represented by a named runtime parameter and is never collected by the recorder.

        The resulting schema-v2 JSON is an editable automation design, not executable
        endpoint code. AutoIt is the planned execution layer; its delivery form is
        selected after interpreted-versus-compiled testing in a disposable VM.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]$InstallerPath,

        [string[]]$ArgumentList,

        [string]$OutputPath
    )

    $resolvedInstaller = (Resolve-Path -LiteralPath $InstallerPath).Path
    if (-not $OutputPath) {
        $repoRoot = if ($script:moduleRoot) { $script:moduleRoot } else { Split-Path -Path $PSScriptRoot -Parent }
        $captureRoot = Join-Path $repoRoot 'Config\Local\InstallerCaptures'
        New-Item -ItemType Directory -Path $captureRoot -Force | Out-Null
        $OutputPath = Join-Path $captureRoot ("{0}-{1}.json" -f [IO.Path]::GetFileNameWithoutExtension($resolvedInstaller), (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }

    if (-not $PSCmdlet.ShouldProcess($resolvedInstaller, 'Launch installer and begin technician-guided UI capture')) { return }

    if (-not ('NSPInstallerCaptureNative' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class NSPInstallerCaptureNative {
    [StructLayout(LayoutKind.Sequential)]
    private struct POINT { public int X; public int Y; }

    [StructLayout(LayoutKind.Sequential)]
    private struct MSG {
        public IntPtr hwnd;
        public uint message;
        public UIntPtr wParam;
        public IntPtr lParam;
        public uint time;
        public POINT pt;
    }

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint modifiers, uint virtualKey);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    [DllImport("user32.dll")]
    private static extern int GetMessage(out MSG message, IntPtr hWnd, uint min, uint max);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    public static string ReadWindowTitle(IntPtr hWnd) {
        StringBuilder text = new StringBuilder(2048);
        GetWindowText(hWnd, text, text.Capacity);
        return text.ToString();
    }

    // Returns 1 for capture (Ctrl+Shift+F12) or 2 for finish (Ctrl+Shift+F11).
    public static int WaitForCommand() {
        const uint MOD_CONTROL = 0x0002;
        const uint MOD_SHIFT = 0x0004;
        const uint VK_F11 = 0x7A;
        const uint VK_F12 = 0x7B;
        const uint WM_HOTKEY = 0x0312;
        const int CAPTURE_ID = 0x4E53;
        const int FINISH_ID = 0x4E54;

        bool captureRegistered = RegisterHotKey(IntPtr.Zero, CAPTURE_ID, MOD_CONTROL | MOD_SHIFT, VK_F12);
        bool finishRegistered = RegisterHotKey(IntPtr.Zero, FINISH_ID, MOD_CONTROL | MOD_SHIFT, VK_F11);
        if (!captureRegistered || !finishRegistered) {
            if (captureRegistered) UnregisterHotKey(IntPtr.Zero, CAPTURE_ID);
            if (finishRegistered) UnregisterHotKey(IntPtr.Zero, FINISH_ID);
            throw new InvalidOperationException("The installer capture hotkeys are already in use.");
        }

        try {
            MSG message;
            while (GetMessage(out message, IntPtr.Zero, 0, 0) > 0) {
                if (message.message != WM_HOTKEY) continue;
                int id = unchecked((int)message.wParam.ToUInt64());
                if (id == CAPTURE_ID) return 1;
                if (id == FINISH_ID) return 2;
            }
            return 2;
        }
        finally {
            UnregisterHotKey(IntPtr.Zero, CAPTURE_ID);
            UnregisterHotKey(IntPtr.Zero, FINISH_ID);
        }
    }
}
'@ -ErrorAction Stop
    }

    Add-Type -AssemblyName UIAutomationClient -ErrorAction Stop
    Add-Type -AssemblyName UIAutomationTypes -ErrorAction Stop

    $version = [Diagnostics.FileVersionInfo]::GetVersionInfo($resolvedInstaller)
    $signature = Get-AuthenticodeSignature -LiteralPath $resolvedInstaller
    $startParameters = @{ FilePath = $resolvedInstaller; PassThru = $true }
    if ($ArgumentList) { $startParameters.ArgumentList = $ArgumentList }
    $installerProcess = Start-Process @startParameters

    $observations = [Collections.Generic.List[object]]::new()
    Write-Host ''
    Write-Host 'Installer observation is active.' -ForegroundColor Cyan
    Write-Host '  Ctrl+Shift+F12  Capture the current window and focused control'
    Write-Host '  Ctrl+Shift+F11  Finish observation and review the captured states'
    Write-Warning 'Do not enter passwords, license keys, client identifiers, or other secrets during capture.'

    while ($true) {
        $command = [NSPInstallerCaptureNative]::WaitForCommand()
        if ($command -eq 2) { break }

        $handle = [NSPInstallerCaptureNative]::GetForegroundWindow()
        [uint32]$foregroundProcessId = 0
        [void][NSPInstallerCaptureNative]::GetWindowThreadProcessId($handle, [ref]$foregroundProcessId)
        $focused = [Windows.Automation.AutomationElement]::FocusedElement

        $observations.Add([pscustomobject][ordered]@{
            WindowTitle  = [NSPInstallerCaptureNative]::ReadWindowTitle($handle)
            ProcessId    = $foregroundProcessId
            ControlName  = if ($focused) { $focused.Current.Name } else { '' }
            AutomationId = if ($focused) { $focused.Current.AutomationId } else { '' }
            ControlType  = if ($focused -and $focused.Current.ControlType) { $focused.Current.ControlType.ProgrammaticName } else { '' }
        })
        Write-Host ("Captured observation {0}." -f $observations.Count) -ForegroundColor Green
    }

    if ($observations.Count -eq 0) {
        Write-Warning 'No installer states were captured. No capture file was written.'
        return
    }

    Write-Host ''
    Write-Host 'Review each observation and describe the intended automation step.' -ForegroundColor Cyan
    Write-Host 'Use a runtime parameter for anything sensitive or customer-specific.'
    $steps = [Collections.Generic.List[object]]::new()
    $runtimeParameters = [ordered]@{}

    foreach ($observation in $observations) {
        Write-Host ''
        Write-Host ("Observation {0}: {1}" -f ($steps.Count + 1), $observation.WindowTitle) -ForegroundColor Yellow
        Write-Host ("Focused control: {0} [{1}]  AutomationId: {2}" -f $observation.ControlName, $observation.ControlType, $observation.AutomationId)
        Write-Host '[1] Click  [2] Set value  [3] Select option  [4] Send keys'
        Write-Host '[5] Wait for window  [6] Wait for window to close  [7] Skip this observation'
        $actionChoice = Read-NSPMenuChoice -Prompt 'Action' -Allowed @('1','2','3','4','5','6','7') -Default '1'
        if ($actionChoice -eq '7') { continue }

        $action = @{
            '1' = 'Click'; '2' = 'SetValue'; '3' = 'Select'; '4' = 'SendKeys'
            '5' = 'WaitForWindow'; '6' = 'WaitForWindowClose'
        }[$actionChoice]

        $expectedText = Read-Host ("Expected visible window text (Enter accepts '{0}')" -f $observation.ControlName)
        if ([string]::IsNullOrWhiteSpace($expectedText)) { $expectedText = $observation.ControlName }
        $matchChoice = Read-NSPMenuChoice -Prompt 'Window matching: [1] Contains  [2] Exact' -Allowed @('1','2') -Default '1'
        $timeoutText = Read-Host 'Timeout in seconds (Enter accepts 60)'
        $timeoutSeconds = 60
        if ($timeoutText -and (-not [int]::TryParse($timeoutText, [ref]$timeoutSeconds) -or $timeoutSeconds -lt 1)) {
            throw "Invalid timeout: $timeoutText"
        }
        $optional = (Read-NSPMenuChoice -Prompt 'May this screen be absent? [Y/N]' -Allowed @('Y','N') -Default 'N') -eq 'Y'

        $valueDefinition = $null
        if ($action -in @('SetValue','Select','SendKeys')) {
            Write-Host '[1] Safe literal value  [2] Runtime parameter (required for secrets/client values)'
            $valueChoice = Read-NSPMenuChoice -Prompt 'Value source' -Allowed @('1','2') -Default '2'
            if ($valueChoice -eq '1') {
                $literalValue = Read-Host 'Non-sensitive literal value'
                $valueDefinition = [ordered]@{ Source = 'Literal'; Value = $literalValue }
            }
            else {
                do { $parameterName = Read-Host 'Runtime parameter name (for example LicenseKey)' }
                while ($parameterName -notmatch '^[A-Za-z][A-Za-z0-9_]*$')
                $isSensitive = (Read-NSPMenuChoice -Prompt 'Is this parameter sensitive? [Y/N]' -Allowed @('Y','N') -Default 'Y') -eq 'Y'
                $description = Read-Host 'Parameter explanation (do not enter its value)'
                $runtimeParameters[$parameterName] = [ordered]@{
                    Name        = $parameterName
                    Sensitive   = $isSensitive
                    Description = $description
                }
                $valueDefinition = [ordered]@{ Source = 'RuntimeParameter'; Name = $parameterName }
            }
        }

        $step = [ordered]@{
            Order  = $steps.Count + 1
            Window = [ordered]@{
                Title     = $observation.WindowTitle
                Text      = $expectedText
                MatchMode = if ($matchChoice -eq '2') { 'Exact' } else { 'Contains' }
            }
            Control = [ordered]@{
                Name           = $observation.ControlName
                AutomationId   = $observation.AutomationId
                ControlType    = $observation.ControlType
                AutoItSelector = ''
            }
            Action         = $action
            Value          = $valueDefinition
            TimeoutSeconds = $timeoutSeconds
            Optional       = $optional
            Note           = Read-Host 'Optional explanation for the implementing technician'
        }
        $steps.Add([pscustomobject]$step)
    }

    $capture = [ordered]@{
        SchemaVersion    = '2.0'
        Installer        = [ordered]@{
            File            = [IO.Path]::GetFileName($resolvedInstaller)
            Sha256          = (Get-FileHash -LiteralPath $resolvedInstaller -Algorithm SHA256).Hash
            FileVersion     = $version.FileVersion
            ProductVersion  = $version.ProductVersion
            SignerSubject   = if ($signature.SignerCertificate) { $signature.SignerCertificate.Subject } else { $null }
            SignatureStatus = $signature.Status.ToString()
        }
        CapturedAtUtc    = (Get-Date).ToUniversalTime().ToString('o')
        CaptureProcessId = $installerProcess.Id
        ExecutionEngine = 'AutoIt'
        RuntimeParameters = @($runtimeParameters.Values)
        Steps             = @($steps)
    }

    $parent = Split-Path -Path $OutputPath -Parent
    if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $capture | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    Write-Host ("Capture written to {0}" -f $OutputPath) -ForegroundColor Green
    Get-Item -LiteralPath $OutputPath
}
