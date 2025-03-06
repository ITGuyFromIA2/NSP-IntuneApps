[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Result = invoke-webrequest -uri "http://www.videolan.org/" -UseBasicParsing

$32Pattern = 'get.videolan.org/vlc/[0-9]+.[0-9]+.[0-9]+/win32/vlc-[0-9]+.[0-9]+.[0-9]+-win32.exe'
$64Pattern = 'get.videolan.org/vlc/[0-9]+.[0-9]+.[0-9]+/win64/vlc-[0-9]+.[0-9]+.[0-9]+-win64.exe'
#href="//get.videolan.org/vlc/3.0.16/win32/vlc-3.0.16-win32.exe">Windows</a>                    
#<a href="//get.videolan.org/vlc/3.0.16/win64/vlc-3.0.16-win64.exe">Windows 64bit<

if ([Environment]::Is64BitOperatingSystem) {
    $URL = ((($Result.links) -match $64Pattern).href).replace("//","")
} else {
    $URL = ((($Result.links) -match $32Pattern).href).replace("//","")[0]
}
$URL = (-join("https://",$URL))


$DestFolder = 'C:\admin\Installers'
$DestEXE = 'VLCInstaller.exe'
$FullDest = (-join($DestFolder,"\",$DestEXE))

if (!(Test-Path -Path $DestFolder)) {New-Item -ItemType Directory -Path $DestFolder}


if (Test-Path -Path $FullDest) {Remove-Item -Path $FullDest -Confirm:$false -force}



$DownloadLink = Invoke-WebRequest -Uri $URL -UseBasicParsing
$URL = ($DownloadLink.Links -match "Click Here").href

Invoke-WebRequest -Uri $URL -OutFile $FullDest -UseBasicParsing

Unblock-File -Path $FullDest

start-process -filepath "$FullDest" -ArgumentList "/L=1033 /S" -wait