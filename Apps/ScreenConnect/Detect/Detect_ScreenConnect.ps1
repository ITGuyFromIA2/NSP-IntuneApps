$AppName = "ScreenConnect"
$GUIDMatch = "8bfa52c26e666213"

$ProgramList = @( "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" )
$Programs = Get-ItemProperty $ProgramList -EA 0
$App = @(($Programs | Where-Object { $_.DisplayName -like "*$($AppName)*$($GUIDMatch)*"}))

if ($App.Count -gt 0) {
    $Installed="$($App) Installed"
    write-output $installed
     [Environment]::Exit(0)
} else {
    $Installed="$($App) NOT Installed"
    write-output $Installed
     [Environment]::Exit(1)
}