$AppliationName = 'VLC media player'

$Path = "C:\Program Files\VideoLAN\VLC\vlc.exe"
$Path2 = "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
if ((test-path -Path $path) -or (test-path -Path $path2)) {
    $Installed="$AppliationName Installed"
    write-output $installed
     [Environment]::Exit(0)
} else {
    $Installed="$AppliationName NOT Installed"
    write-output $Installed
     [Environment]::Exit(1)
}