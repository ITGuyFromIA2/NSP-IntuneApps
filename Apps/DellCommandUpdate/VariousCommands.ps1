cmd /c """$Env:ProgramFiles\Dell\CommandUpdate\dcu-cli.exe"" /driverInstall -silent"


$Config = @{}
$Config.DCU_exe = """$($Env:ProgramFiles)\Dell\CommandUpdate\dcu-cli.exe"""

$Config.DellCommandLogLocation = "C:\admin\installers\DellCommand\"
if (!(Test-Path -Path $Config.DellCommandLogLocation)) {new-item -itemtype Directory -Path $Config.DellCommandLogLocation -Force}

$Config.DriverScan_LogLocation = ((-join($($Config.DellCommandLogLocation),"DriverScanLog.log")).Replace("\","\\"))
$Config.DriverScan_XMLLocation = ((-join($($Config.DellCommandLogLocation),"DriverScanLog.xml")).Replace("\","\\"))

$DriverScan = @{}
$DriverScan.args = @()

$DriverScan.args += "/scan"

$DriverScan.args += "-updateType=driver"

$DriverScan.args += "-outputLog=$($Config.DriverScan_LogLocation)"
$DriverScan.args += "-report=$($Config.DriverScan_XMLLocation)"

Start-Process -FilePath $Config.DCU_exe -ArgumentList $DriverScan.args


<#
#Scan
    dcu-cli.exe /scan -<option>=<value> 
    -silent
    -outputLog
    -updateSeverity 
    -updateType 
    -updateDeviceCategory 
    -catalogLocation 
    -report 

dcu-cli.exe /scan -updateType=driver -outputLog=
 

#>


<#
dcu-cli.exe /configure - autoSuspendBitLocker=enable 


#>


<#
dcu-cli.exe /applyUpdates -reboot=enable 

#>


<#
dcu-cli.exe /scan -report=C:\Temp\UpdatesReport.xml 

#>


<#
dcu-cli.exe /configure - scheduleWeekly=Mon,23:45 
				

#>


<#
dcu-cli /configure -systemRestartDeferral=enable -deferralRestartInterval=1 -deferralRestartCount=2 

#>