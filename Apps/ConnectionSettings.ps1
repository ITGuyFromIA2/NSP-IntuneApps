$codeCertificate = (Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq 'CN="Network Systems Plus, Inc."'})[0]

#DotSource our app and tenant info
     $OUT_AppAuthInfo = "$(Split-Path $BaseDir -Parent)\Apps\GraphInfo.ps1"
     . "$($OUT_AppAuthInfo)"
<#

$TenantName = "CONTOSO.onmicrosoft.com"
$UsertoUse = 'nspadmin@CONTOSO.com'
$AppID = "880ac12b-89d6-4ed6-80a7-9dd13dd3f8da"
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