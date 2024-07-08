new-item -path C:\admin -ItemType Directory -Force -ErrorAction SilentlyContinue
start-transcript -Path C:\admin\TRAFxDrivers.txt -Append -Force

#Get the current working DIR
    if ($psISE) {$BaseDir = Split-Path -Path $psISE.CurrentFile.FullPath} else {$BaseDir = $PSScriptRoot} 
    $SharedDefs = "$($BaseDir)\SharedDefs.ps1"
    . $SharedDefs
   
foreach ($pEntry in $Config.ParseLinks) {
   
    #Perform download
    invoke-webrequest -Uri $($pEntry.FinalLink) -OutFile "$($pEntry.FullDest)" -UseBasicParsing

    #Save version information. Using greatest of "FileVersion" or "ProductVersion"
    $FileInfo = get-item -path "$($pEntry.FullDest)" | Select-Object -Property *
    $pEntry.VersionInfo = @($FileInfo.VersionInfo.ProductVersion, $FileInfo.VersionInfo.FileVersion) | Sort-Object -Descending | Select-Object -First 1

    if ($pEntry.ExtractCommand) {
        Write-Output "Doing Extraction first"
        if (!(Test-Path -Path $($pEntry.ExtractFolder))) {
            new-item -ItemType Directory -Path $($pEntry.ExtractFolder)
        }

    Invoke-Expression "$($pEntry.ExtractCommand -f $($pEntry.FullDest), $($pEntry.ExtractFolder))"

    $Raw = get-content -path "$($pEntry.ExtractFolder)\$($pEntry.EXParseFile)"

    $Tempr = [regex]$($pEntry.EXRegex)
    $Found = $tempr.Matches($Raw)
    $FoundGUID = "{$(($Found.Groups | Where-Object -FilterScript {$_.Name -eq 'GUID'}).value)}"

   
    $Replaced = $InstallFile.replace("{ReplaceWith_ProductGuid}","$($FoundGUID)")
    set-content -path "$($pEntry.Answer_Install)" -Value $Replaced -Force

    $pEntry.FinalCommand = $pEntry.InstallCommand -f $pEntry.FullDest, $pEntry.Answer_Install

    }

}



#$pEntry = $Config.ParseLinks[1]

foreach ($pEntry in $Config.ParseLinks) {
    #Do the install
    Invoke-Expression -Command "$($pEntry.FinalCommand)"

}

start-sleep -Seconds 10

#Final Check
$AppName = "PL23XX USB-to-Serial"

$ProgramList = @( "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" )
$Programs = Get-ItemProperty $ProgramList -EA 0
$App = @(($Programs | Where-Object { $_.DisplayName -like "*$AppName*"}))

if ($App.Count -gt 0) {
    $Installed="$AppName Installed"
    write-output $installed
    $ExitCode = 0
} else {
    $Installed="$AppName NOT Installed"
    write-output $Installed
    $ExitCode = 1618
}
[Environment]::Exit($ExitCode)
