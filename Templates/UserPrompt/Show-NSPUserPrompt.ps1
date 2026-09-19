param(
    [Parameter(Mandatory)][string]$ConfigPath,
    [Parameter(Mandatory)][string]$ResultPath,
    [int]$TimeoutSeconds = 900
)
$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
Add-Type -Name NativeWindow -Namespace NSPIntuneApps.UserPrompt -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr handle, int command);
[System.Runtime.InteropServices.DllImport("kernel32.dll")] public static extern System.IntPtr GetConsoleWindow();
'@
[NSPIntuneApps.UserPrompt.NativeWindow]::ShowWindow([NSPIntuneApps.UserPrompt.NativeWindow]::GetConsoleWindow(), 0) | Out-Null
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Text = [string]$config.Title
$form.Size = New-Object Drawing.Size(560,270)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true
$message = New-Object Windows.Forms.Label
$message.Location = New-Object Drawing.Point(20,20)
$message.Size = New-Object Drawing.Size(505,115)
$message.Text = [string]$config.Message
$form.Controls.Add($message)
$countdown = New-Object Windows.Forms.Label
$countdown.Location = New-Object Drawing.Point(20,140)
$countdown.Size = New-Object Drawing.Size(505,25)
$form.Controls.Add($countdown)
$accept = New-Object Windows.Forms.Button
$accept.Location = New-Object Drawing.Point(95,175)
$accept.Size = New-Object Drawing.Size(145,32)
$accept.Text = [string]$config.AcceptLabel
$defer = New-Object Windows.Forms.Button
$defer.Location = New-Object Drawing.Point(305,175)
$defer.Size = New-Object Drawing.Size(145,32)
$defer.Text = [string]$config.DeferLabel
$form.Controls.Add($accept)
$form.Controls.Add($defer)
$script:result = 'Timeout'
$script:seconds = $TimeoutSeconds
$accept.Add_Click({ $script:result = 'Accept'; $form.Close() })
$defer.Add_Click({ $script:result = 'Defer'; $form.Close() })
$timer = New-Object Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    $script:seconds--
    $remaining = [timespan]::FromSeconds([math]::Max(0,$script:seconds))
    $countdown.Text = 'Time remaining: {0:00}:{1:00}' -f [math]::Floor($remaining.TotalMinutes), $remaining.Seconds
    if ($script:seconds -le 0) { $timer.Stop(); $form.Close() }
})
$timer.Start()
[void]$form.ShowDialog()
$timer.Stop(); $timer.Dispose(); $form.Dispose()
$result = [ordered]@{ Result=$script:result; Username=[Security.Principal.WindowsIdentity]::GetCurrent().Name; TimestampUtc=[datetime]::UtcNow.ToString('o') }
$temporary = "$ResultPath.$([guid]::NewGuid().ToString('N')).tmp"
$result | ConvertTo-Json | Set-Content -LiteralPath $temporary -Encoding UTF8
try {
    [IO.File]::Move($temporary, $ResultPath)
} catch [IO.IOException] {
    # Another active session won the race. Preserve the first response.
    Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue
}
