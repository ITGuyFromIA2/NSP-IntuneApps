connect-azuread


$App = @{
    Name = "Intune"
    RequiredResourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
    AppRedirectURI = $null
    myapp = $null
}




$app.RequiredResourceAccess.ResourceAppId = "00000003-0000-0000-c000-000000000000"
$app.RequiredResourceAccess.ResourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "7b3f05d5-f68c-4b8d-8c59-a2ecd12f24af","Scope"


    $app.myApp = New-AzureADApplication -DisplayName $app.name -RequiredResourceAccess $app.RequiredResourceAccess


$App.AppRedirectURI = @("https://login.microsoftonline.com/common/oauth2/nativeclient","https://login.live.com/oauth20_desktop.srf","msal$($App.myapp.AppId)://auth","urn:ietf:wg:oauth:2.0:oob")
Set-AzureADApplication -ObjectId $app.myapp.ObjectId -PublicClient $true -ReplyUrls $app.AppRedirectURI