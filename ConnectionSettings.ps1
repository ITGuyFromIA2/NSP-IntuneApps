$codeCertificate = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq 'CN="Network Systems Plus, Inc."'}

$TenantName = "contoso.onmicrosoft.com"
$UsertoUse = 'nspadmin@contoso.org'

try {
if (($MSGraphConnection.ExpiresOn).AddHours(-6) -lt (get-date)) {
    $MSGraphConnection = Connect-MSIntuneGraph -TenantID $TenantName
    $MSGraphConnection.Authorization
    
} else {
    Write-Output "Already Connected to MS Graph Intune.`n`tExpires: $($MSGraphConnection.ExpiresOn)"
}
} catch {
$MSGraphConnection = Connect-MSIntuneGraph -TenantID $TenantName

}


if (!($AzureADConnection)) {
    $AzureADConnection = Connect-AzureAD
    }