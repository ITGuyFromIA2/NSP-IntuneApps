$FullDest = "C:\Program Files\VideoLAN\VLC\uninstall.exe"
$FullDest2 = "C:\Program Files\VideoLAN (x86)\VLC\uninstall.exe"
start-process -filepath "$FullDest" -ArgumentList "/S" -wait
start-process -filepath "$FullDest2" -ArgumentList "/S" -wait