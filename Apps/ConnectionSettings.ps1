cls
$codeCertificate = ((Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq 'CN="Network Systems Plus, Inc."'} | Sort-Object -Property NotAfter -Descending)[0])

$TenantName = "greenbergsjewelers.onmicrosoft.com"
$UsertoUse = 'nspadmin@greenbergsjewelers.com'
$TenantID = "6205a6a6-e748-4566-861f-3ae433f9aaf2"

$AppID = "298e2889-7b07-4430-9b24-bdfcc2ccebd4"

try {
if (($MSGraphConnection.ExpiresOn).AddHours(-6) -lt (get-date)) {
    $MSGraphConnection = Connect-MSIntuneGraph -ClientID $AppID  -tenantid $TenantID
    #$MSGraphConnection.Authorization
    
} else {
    Write-Output "Already Connected to MS Graph Intune.`n`tExpires: $($MSGraphConnection.ExpiresOn)"
}
} catch {
$MSGraphConnection = Connect-MSIntuneGraph -TenantID $TenantID -ClientID $AppID 

}


if (!($AzureADConnection)) {
    $AzureADConnection = Connect-AzureAD
    }