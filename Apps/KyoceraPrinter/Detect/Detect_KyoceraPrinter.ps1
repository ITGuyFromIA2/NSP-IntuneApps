#Name of Printer, as seen by user
    $PrinterName = "Kyocera EcoSys M3540idn"

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