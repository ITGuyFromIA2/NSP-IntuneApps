@echo off
mkdir ".\Package"
IntuneWinAppUtil.exe -c ".\Source" -s ".\Source\DownloadInstall_Brother.ps1" -o ".\Package"
pause