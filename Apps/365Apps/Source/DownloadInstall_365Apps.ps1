param($uninstall=$false)

# Download ODT
function Get-ODTURL {

$htmlContent = Invoke-WebRequest -Uri "https://www.microsoft.com/en-us/download/details.aspx?id=49117"
$regex = '"url":"(https://download\.microsoft\.com/download/[^\s"]+\.exe)"'
if ($htmlContent.Content -match $regex) {
    $downloadUrl = $matches[1]
    #Write-Host "Download URL: $downloadUrl"
    $downloadUrl
} else {
    #Write-Host "Download URL not found."
    return "Error Downloading"
}
 }

 if ($uninstall) {
 $XMLConfig = @"
<Configuration>
    <Display Level="None" AcceptEULA="TRUE" />
    <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
    <Remove ALL="TRUE" />
</Configuration>
"@
 } else {

 $XMLConfig = @"
<Configuration ID="cffd6d5a-aa68-4538-8e08-73c49dbc7f27">
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365BusinessRetail">
      <Language ID="en-us" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <AppSettings>
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="51" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="27" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
  </AppSettings>
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
"@
}

$BaseDir = "C:\admin\Office365"
$ConfigFile = "$($BaseDir)\Microsoft_365_Apps_for_Business_64bit.xml"
set-content -path $ConfigFile -Value $XMLConfig -Force -ErrorAction SilentlyContinue

if (!(Test-Path $BaseDir)) {new-item -path $BaseDir -ItemType Directory -Force -ErrorAction SilentlyContinue}

Set-Location -Path $BaseDir

# Step 1 Download ODT
$ODTInstallLink = Get-ODTURL
Invoke-WebRequest -Uri $ODTInstallLink -OutFile "ODTSetup.exe"

# Step 2 Extract ODT
#$CurrentPath = Get-Location
Start-Process "ODTSetup.exe" -ArgumentList "/quiet /extract:$BaseDir" -Wait

if (!($uninstall)) {
# Step 3 Download Office Files
    Start-Process "setup.exe" -ArgumentList "/download Microsoft_365_Apps_for_Business_64bit.xml" -Wait -PassThru
}

# Step 4 Install Office
Start-Process "setup.exe" -ArgumentList "/configure Microsoft_365_Apps_for_Business_64bit.xml" -Wait -PassThru