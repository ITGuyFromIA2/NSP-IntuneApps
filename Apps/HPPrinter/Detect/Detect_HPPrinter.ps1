#Name of Printer, as seen by user
    $PrinterName = "HP LaserJet Pro M148fdw"

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