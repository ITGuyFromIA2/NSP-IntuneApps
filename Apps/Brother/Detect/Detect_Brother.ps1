param ($IPAddress="10.0.0.24", $PrinterMFG="Brother", $PrinterModel="MFC-L2710DW",$Package="Full")

#Name of Printer, as seen by user
    $PrinterName = "$($PrinterMFG) $($PrinterModel)"

$Printer = Get-Printer -Name $PrinterName
if ($Printer) {
    $Installed="$PrinterName Installed"
    write-output $installed
     [Environment]::Exit(0)
} else {
    $Installed="$PrinterName NOT Installed"
    write-output $Installed
     [Environment]::Exit(1)
}