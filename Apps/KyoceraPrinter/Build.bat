@echo off
mkdir ".\Package"
IntuneWinAppUtil.exe -c ".\Source" -s ".\Source\DownloadInstall_Kyocera.ps1" -o ".\Package"
pause