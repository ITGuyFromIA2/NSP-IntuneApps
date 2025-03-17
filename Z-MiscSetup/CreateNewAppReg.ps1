#Get the current working DIR
    if ($psISE) {$BaseDir = Split-Path -Path $psISE.CurrentFile.FullPath    #IF running in ISE, with line by line execution this will work
    } else {$BaseDir = $PSScriptRoot} 

#DotSource our app and tenant info
     $OUT_AppAuthInfo = "$(Split-Path $BaseDir -Parent)\Apps\GraphInfo.ps1"
     

connect-azuread

#Permissions needed
"$(Split-Path $BaseDir -Parent)\Apps\GraphInfo.ps1"
$App = @{
    Name = "Intune2"
    RequiredResourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
    AppRedirectURI = $null
    myapp = $null
}

    $DefList = @(
    @{Name="DeviceManagementApps.Read.All"; Type="Role"},
    @{Name="DeviceManagementApps.ReadWrite.All"; Type="Role"},
    @{Name="DeviceManagementConfiguration.Read.All"; Type="Role"},
    @{Name="DeviceManagementConfiguration.ReadWrite.All"; Type="Role"}
)

#This is the 'tester' / how to use it portion


$BuiltPerms = $( . "$($BaseDir)\MSGraph_AppRegDefs.ps1" -DefList $Deflist )

$app.RequiredResourceAccess.ResourceAppId = "00000003-0000-0000-c000-000000000000"
$app.RequiredResourceAccess.ResourceAccess = @(
  $BuiltPerms | %{  New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "$($_.PermissionID)","$($_.Type)" }
)

    $app.myApp = New-AzureADApplication -DisplayName $app.name -RequiredResourceAccess $app.RequiredResourceAccess


$App.AppRedirectURI = @("https://login.microsoftonline.com/common/oauth2/nativeclient","https://login.live.com/oauth20_desktop.srf","msal$($App.myapp.AppId)://auth","urn:ietf:wg:oauth:2.0:oob")
Set-AzureADApplication -ObjectId $app.myapp.ObjectId -PublicClient $false -ReplyUrls $app.AppRedirectURI

$OutputStr = @"
#This is meant to be DotSourced before the 'ConnectionSettings' script is ran
`$TenantName = "$((Get-AzureADDomain | Where-Object -FilterScript {$_.Name -like "*.onmicrosoft.com"}).name)"
`$UsertoUse = '$((get-azcontext).Account.id)'
`$AppID = "$($App.myapp.AppId)"
`$AppName = "$($App.Name)"
"@

set-content -path $OUT_AppAuthInfo -Value $OutputStr -Force -ErrorAction SilentlyContinue