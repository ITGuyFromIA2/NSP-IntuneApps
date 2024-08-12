#Get the current working DIR
    if ($psISE) {$BaseDir = Split-Path -Path $psISE.CurrentFile.FullPath} else {$BaseDir = $PSScriptRoot} 
    $SharedDefs = "$($BaseDir)\SharedDefs.ps1"
    . $SharedDefs

$AppSearch = "*PL23XX USB-to-Serial*"

$ProgramList = @( "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" )
$Programs = Get-ItemProperty $ProgramList -EA 0
$App = $Programs | Where-Object { $_.DisplayName -like $AppSearch}

#This will need to be adjusted IF order ever changes
$pEntry = $Config.ParseLinks[1]


foreach ($a in $App) {

    if ($($a.UninstallString) -match '\".*\.exe\"') {
        $PathEXE = $Matches[0]
    }

$Replaced = $UninFile.replace("{ReplaceWith_ProductGuid}","$($a.ProductGuid)")
set-content -path "$($pEntry.Answer_Uninstall)" -Value $Replaced -Force

#Recalcualte our FinalUninstallString
$pEntry.FinalUninstall = $pEntry.UninstallCommand -f $(Invoke-Expression $pEntry.UninstallRepl)
}

foreach ($pEntry in @($config.ParseLinks)) {
Invoke-Expression "$($pEntry.FinalUninstall)"

}
$AppName = "PL23XX USB-to-Serial"

$ProgramList = @( "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" )
$Programs = Get-ItemProperty $ProgramList -EA 0
$App = @(($Programs | Where-Object { $_.DisplayName -like "*$AppName*"}))

if ($App.Count -gt 0) {
    $Installed="$AppName Installed"
    write-output $installed
    [Environment]::Exit(0)
} else {
    $Installed="$AppName NOT Installed"
    write-output $Installed
    [Environment]::Exit(1)
}