@echo off
mkdir ".\Package"
IntuneWinAppUtil.exe -c ".\DownloadSource" -s ".\DownloadSource\DownloadUnpack_KyoceraDrivers.ps1" -o ".\Package"
pause