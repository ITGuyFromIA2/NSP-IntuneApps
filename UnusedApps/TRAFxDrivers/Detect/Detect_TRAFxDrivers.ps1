$AppName = "PL23XX USB-to-Serial"

$ProgramList = @( "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" )
$Programs = Get-ItemProperty $ProgramList -EA 0
$App = @(($Programs | Where-Object { $_.DisplayName -like "*$AppName*"}))

cls
if ($App.Count -gt 0) {
    $Installed="$AppName Installed"
    write-output $installed
    $ExitCode = 0
} else {
    $Installed="$AppName NOT Installed"
    write-output $Installed
    $ExitCode = 1
}
[Environment]::Exit($ExitCode)