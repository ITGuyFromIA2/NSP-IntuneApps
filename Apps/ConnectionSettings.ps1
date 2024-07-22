cls
$codeCertificate = ((Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq 'CN="Network Systems Plus, Inc."'} | Sort-Object -Property NotAfter -Descending)[0])

$TenantName = "hnrco.onmicrosoft.com"
$UsertoUse = 'nspadmin@hnrco.com'
$TenantID = "8d069910-855a-4854-bcba-c85fd77f97b8"

$AppID = "090ece0f-135f-4f60-883e-3737dd5187a6"

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