@echo off
mkdir ".\Package"
IntuneWinAppUtil.exe -c ".\Source" -s ".\Source\DownloadInstall_HPUniversal.ps1" -o ".\Package"
pause