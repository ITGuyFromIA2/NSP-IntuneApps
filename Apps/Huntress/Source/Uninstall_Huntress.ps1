$AppSearch = "*Huntress*"

$ProgramList = @( "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" )
$Programs = Get-ItemProperty $ProgramList -EA 0
$App = ($Programs | Where-Object { $_.DisplayName -like $AppSearch -and $_.UninstallString -like "*msiexec*" }).PSChildName

#$Programs | Where-Object { $_.DisplayName -like $AppSearch -and $_.UninstallString -like "*msiexec*" } | Select-Object -Property *


foreach ($a in $App) {

	$Params = @(
		"/qn"
		"/norestart"
		"/X"
		"$a"
	)

	Start-Process "msiexec.exe" -ArgumentList $Params -Wait -NoNewWindow

}