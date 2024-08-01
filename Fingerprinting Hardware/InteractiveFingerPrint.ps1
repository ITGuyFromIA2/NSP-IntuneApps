param($GroupTag)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts";
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force -Confirm:$false;
Install-Script -Name Get-WindowsAutopilotInfo;
#Get-WindowsAutopilotInfo -OutputFile AutopilotHWID.csv;
#Get-WindowsAutopilotInfo -Online
#get-WindowsAutopilotInfo -Online -GroupTag "Simpco-RemoteLT"
get-WindowsAutopilotInfo -Online -GroupTag "$GroupTag"