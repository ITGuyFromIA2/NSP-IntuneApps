$codeCertificate = (Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq 'CN="Network Systems Plus, Inc."'})[0]

#Get the current working DIR
    if ($psISE) {$CS_BaseDir = Split-Path -Path $psISE.CurrentFile.FullPath    #IF running in ISE, with line by line execution this will work
    } else {$CS_BaseDir = $PSScriptRoot} 

#DotSource our app and tenant info
     $OUT_AppAuthInfo = "$($CS_BaseDir)\GraphInfo.ps1"
     . "$($OUT_AppAuthInfo)"
<#
    #This is meant to be DotSourced before the 'ConnectionSettings' script is ran
    $TenantName = "sschousingagency.onmicrosoft.com"
    $UsertoUse = 'nspadmin@caasiouxland.org'
    $AppID = "3f43ac8c-4ceb-42ce-8165-eb36a6c46f1c"
    $AppName = "Intune"

#>

#Import-Module Microsoft.Graph.Intune
#Select-MsalClientApplication -ClientId  -RedirectUri 
#Update-MSGraphEnvironment -AppID 4504c783-bc42-4ff6-afbb-5db21f327d5d -RedirectLink 
try {
if (($MSGraphConnection.ExpiresOn).AddHours(-6) -lt (get-date)) {
    $MSGraphConnection = Connect-MSIntuneGraph -TenantID $TenantName -ClientID $AppID -RedirectUri "msal$($AppID)://auth"
    $MSGraphConnection.Authorization
    
} else {
    Write-Output "Already Connected to MS Graph Intune.`n`tExpires: $($MSGraphConnection.ExpiresOn)"
}
} catch {
$MSGraphConnection = Connect-MSIntuneGraph -TenantID $TenantName -ClientID $AppID -RedirectUri "msal$($AppID)://auth"

}


if (!($AzureADConnection)) {
    $AzureADConnection = Connect-AzureAD
    }