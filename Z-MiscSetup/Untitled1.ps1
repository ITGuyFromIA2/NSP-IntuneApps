#Get the current working DIR
    if ($psISE) {$BaseDir = Split-Path -Path $psISE.CurrentFile.FullPath    #IF running in ISE, with line by line execution this will work
    } else {$BaseDir = $PSScriptRoot} 
