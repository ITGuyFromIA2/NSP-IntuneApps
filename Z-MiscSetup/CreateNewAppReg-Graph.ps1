#Get the current working DIR - used for outputting the GraphInfo file AND for DotSourcing the MSGraphDefs.ps1
    if ($psISE) {$BaseDir = Split-Path -Path $psISE.CurrentFile.FullPath    #IF running in ISE, with line by line execution this will work
    } else {$BaseDir = $PSScriptRoot} 

#DotSource our app and tenant info
     $OUT_AppAuthInfo = "$(Split-Path $BaseDir -Parent)\Apps\GraphInfo.ps1"
     
# Step 1: Install the Microsoft Graph module (if not already installed)
# Uncomment the next line if you need to install the module
# Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force -AllowClobber

$ReqModule = @(
    "Microsoft.Graph.Applications", 
    "Microsoft.Graph.Identity.SignIns", 
    "Microsoft.Graph.Beta.ManagedTenants"
)

#Application Permissions
    #SCOPE is delegated
    #Role is App Role
$DefList = @(
    @{Name="DeviceManagementApps.Read.All"; Type="Scope"},
    @{Name="DeviceManagementApps.ReadWrite.All"; Type="Scope"},
    @{Name="DeviceManagementConfiguration.Read.All"; Type="Scope"},
    @{Name="DeviceManagementConfiguration.ReadWrite.All"; Type="Scope"}
)

# Step 2: Import the Microsoft Graph module
Import-Module Microsoft.Graph.Identity.SignIns


# Step 3: Authenticate to Azure AD (this will prompt you for credentials)
Connect-MgGraph -UseDeviceCode -Scopes "Application.ReadWrite.All", "Directory.ReadWrite.All", "DelegatedPermissionGrant.ReadWrite.All"

$GraphContext = get-mgcontext

# Step 4: Define the application details
$appName = "Intune-MSGraph"            # Name of the new application
$appUri = "urn:ietf:wg:oauth:2.0:oob"
$apiUri = "https://graph.microsoft.com"  # API URI (for APIs exposed by the app)
$signInAudience = "AzureADMyOrg"  # Change this to your desired audience: "AzureADMyOrg", "AzureADMultipleOrgs", or "AzureADPersonalMicrosoftAccount"

#Build our 'RequiredResourceAccess'
    $BuildAccess = (@{
        "ResourceAppId" = "00000003-0000-0000-c000-000000000000"
        "ResourceAccess" = @()
    })

#DotSource our MSGraph_AppRegDefs.ps1 file
    $BuiltPerms = $( . "$($BaseDir)\MSGraph_AppRegDefs.ps1" -DefList $Deflist )

#Loop through each entry in BuiltPerms and add to ResourceAccess

$BuiltPerms | Select-Object -Property @{name="Id"; expression={$_.PermissionID}}, @{name="Id"; expression={$_.Type}}

    $BuildAccess2 = (@{
        "ResourceAppId" = "00000003-0000-0000-c000-000000000000"
        "ResourceAccess" = @($BuiltPerms | Select-Object -property  @{Name="Id"; Expression={$($_.PermissionID)}}, @{Name="Type"; expression={$($_.Type)}})
    })
    $BuiltPerms[0]
    $BuildAccess -eq $BuildAccess2
foreach ($Entry in $BuiltPerms) {
$BuildAccess.ResourceAccess += @{
                               "Id"=  "$($Entry.PermissionID)"
                               "Type"=  "$($Entry.Type)"
                           }

}
#This is the 'tester' / how to use it portion

$BuildAccess2.ResourceAccess



# Step 5: Create the new application registration
$newApp = New-MgApplication -DisplayName $appName -SignInAudience $signInAudience -RequiredResourceAccess $BuildAccess2 -IsFallbackPublicClient

$AppRedirectURI = @("https://login.microsoftonline.com/common/oauth2/nativeclient",
                    "https://login.live.com/oauth20_desktop.srf",
                    "msal$($newApp.AppId)://auth",
                    "urn:ietf:wg:oauth:2.0:oob"
                    )


Update-MgApplication -ApplicationId $newApp.id -Web @{RedirectUris = $AppRedirectURI}











#$GraphProperties = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Property Oauth2PermissionScopes | Select -ExpandProperty Oauth2PermissionScopes
#$GraphProperties | Where-Object -FilterScript {$_.Value -eq "DeviceManagementApps.ReadWrite.All"} | FL
#$GraphProperties | Where-Object -FilterScript {$_.Value -eq "DeviceManagementApps.Read.All"} | FL
#$GraphProperties | Where-Object -FilterScript {$_.ID -eq "78145de6-330d-4800-a6ce-494ff2d33d07"} | FL

    #$DefList = @(
    #"DeviceManagementApps.Read.All", "DeviceManagementApps.ReadWrite.All", "DeviceManagementConfiguration.Read.All", "DeviceManagementConfiguration.ReadWrite.All"


# The app for which consent is being granted.
$clientAppId = $newApp.AppId # Microsoft Graph Explorer

# The API to which access will be granted. Microsoft Graph Explorer makes API 
# requests to the Microsoft Graph API, so we'll use that here.
$resourceAppId = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API

# The permissions to grant. Here we're including "openid", "profile", "User.Read"
# and "offline_access" (for basic sign-in), as well as "User.ReadBasic.All" (for 
# reading other users' basic profile).
#$permissions = @("openid", "profile", "offline_access", "User.Read", "User.ReadBasic.All")
$permissions = @("DeviceManagementApps.Read.All", "DeviceManagementApps.ReadWrite.All", "DeviceManagementConfiguration.Read.All", "DeviceManagementConfiguration.ReadWrite.All")

# The user on behalf of whom access will be granted. The app will be able to access 
# the API on behalf of this user.
$userUpnOrId = "$($GraphContext.Account)"


# Step 0. Connect to Microsoft Graph PowerShell. We need User.ReadBasic.All to get
#    users' IDs, Application.ReadWrite.All to list and create service principals, 
#    DelegatedPermissionGrant.ReadWrite.All to create delegated permission grants, 
#    and AppRoleAssignment.ReadWrite.All to assign an app role.
#    WARNING: These are high-privilege permissions!

# Step 1. Check if a service principal exists for the client application. 
#     If one doesn't exist, create it.
$clientSp = Get-MgServicePrincipal -Filter "appId eq '$($clientAppId)'"
if (-not $clientSp) {
   $clientSp = New-MgServicePrincipal -AppId $clientAppId
}

# Step 2. Create a delegated permission that grants the client app access to the
#     API, on behalf of the user. (This example assumes that an existing delegated 
#     permission grant does not already exist, in which case it would be necessary 
#     to update the existing grant, rather than create a new one.)
$user = Get-MgUser -UserId $userUpnOrId
$resourceSp = Get-MgServicePrincipal -Filter "appId eq '$($resourceAppId)'"
#$scopeToGrant = $permissions -join " "
$scopeToGrant = $DefList.Name -join " "
#$grant = New-MgOauth2PermissionGrant -ResourceId $resourceSp.Id -Scope $scopeToGrant -ClientId $clientSp.Id -ConsentType "AllPrincipals" -PrincipalId $user.Id
$params = @{
"ClientId" = "$($clientSp.Id)"
"ConsentType" = "AllPrincipals"
"ResourceId" = "$($resourceSp.Id)"
"Scope" = $scopeToGrant
}

$grant = New-MgOauth2PermissionGrant -BodyParameter $params



$OutputStr = @"
#This is meant to be DotSourced before the 'ConnectionSettings' script is ran
`$TenantName = "$((Get-MgDomain | Where-Object {$_.isInitial}).id)"
`$UsertoUse = '$($userUpnOrId)'
`$AppID = "$($newApp.AppId)"
`$AppName = "$($newApp.DisplayName)"
"@

set-content -path $OUT_AppAuthInfo -Value $OutputStr -Force -ErrorAction SilentlyContinue