param($DefList)
<#
#SCOPES aare Delegated Permissions
#ROLES are Application (Role) Permissions

#This is the 'tester' / how to use it portion
$DefList = @(
    @{Name="Mail.Send"; Type="Role"},
    @{Name="User.Read"; Type="Scope"},
    @{Name="UserAuthenticationMethod.Read.All"; Type="Role"},
    @{Name="AuditLog.Read.All"; Type="Role"}
)
#>

#Need to define my perm list

   # $APIDefs = @()
<#
    $APIDefs += @{
        Name = "https://graph.microsoft.com/PermName"
        ResourceAppID = "ResourceID"
        TypeID = @(
            @{PermissionID = "ScopePermID"; Type = "Scope"},
            @{PermissionID = "RolePermID"; Type = "Role"}
            )
    }
#>
<#
    $APIDefs += @{
        Name = "https://graph.microsoft.com/Mail.Send"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "e383f46e-2787-4529-855e-0e479a3ffac0"; Type = "Scope"},
            @{PermissionID = "b633e1c5-b582-4048-a93e-9f11b44c7e96"; Type = "Role"}
            )
    }

    $APIDefs += @{
        Name = "https://graph.microsoft.com/Mail.Read.Shared"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "7b9103a5-4610-446b-9670-80643382c1fa"; Type = "Scope"},
            @{PermissionID = "RolePermID"; Type = "Role"}
            )
    }

    $APIDefs += @{
        Name = "https://graph.microsoft.com/Mail.ReadWrite"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "024d486e-b451-40bb-833d-3e66d98c5c73"; Type = "Scope"},
            @{PermissionID = "RolePermID"; Type = "Role"}
            )
    }

    $APIDefs += @{
        Name = "https://graph.microsoft.com/Mail.Send.Shared"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "a367ab51-6b49-43bf-a716-a1fb06d2a174"; Type = "Scope"},
            @{PermissionID = "RolePermID"; Type = "Role"}
            )
    }

    $APIDefs += @{
        Name = "https://graph.microsoft.com/offline_access"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"; Type = "Scope"},
            @{PermissionID = "RolePermID"; Type = "Role"}
            )
    }

    $APIDefs += @{
        Name = "https://graph.microsoft.com/openid"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "37f7f235-527c-4136-accd-4a02d197296e"; Type = "Scope"},
            @{PermissionID = "RolePermID"; Type = "Role"}
            )
    }

    $APIDefs += @{
        Name = "https://graph.microsoft.com/profile"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "14dad69e-099b-42c9-810b-d002981feec1"; Type = "Scope"},
            @{PermissionID = "RolePermID"; Type = "Role"}
            )
    }

    $APIDefs += @{
        Name = "https://graph.microsoft.com/User.Read"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"; Type = "Scope"},
            @{PermissionID = "RolePermID"; Type = "Role"}
            )
    }

    $APIDefs += @{
        Name = "https://graph.microsoft.com/UserAuthenticationMethod.Read.All"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "ScopePermID"; Type = "Scope"},
            @{PermissionID = "38d9df27-64da-44fd-b7c5-a6fbac20248f"; Type = "Role"}
            )
    }

    $APIDefs += @{
        Name = "https://graph.microsoft.com/AuditLog.Read.All"
        ResourceAppID = "00000003-0000-0000-c000-000000000000"
        TypeID = @(
            @{PermissionID = "ScopePermID"; Type = "Scope"},
            @{PermissionID = "b0afded3-3588-46d8-8b3d-9842eff778da"; Type = "Role"}
            )
    }
    #>

    <#
       $APIDefs += @{
    Name = "https://graph.microsoft.com/AccessReview.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ebfcd32b-babb-40f4-a14b-42706e83bd28"; Type = "Scope"},
        @{PermissionID = "d07a8cc0-3d51-4b77-b3b0-32704d1f69fa"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AccessReview.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e4aa47b9-9a69-4109-82ed-36ec70d85ff1"; Type = "Scope"},
        @{PermissionID = "ef5f7d5c-338f-44b0-86c3-351f46c8bb5f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AccessReview.ReadWrite.Membership"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5af8c3f5-baca-439a-97b0-ea58a435e269"; Type = "Scope"},
        @{PermissionID = "18228521-a591-40f1-b215-5fad4488c117"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Acronym.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9084c10f-a2d6-4713-8732-348def50fe02"; Type = "Scope"},
        @{PermissionID = "8c0aed2c-0c61-433d-b63c-6370ddc73248"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AdministrativeUnit.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3361d15d-be43-4de6-b441-3c746d05163d"; Type = "Scope"},
        @{PermissionID = "134fd756-38ce-4afd-ba33-e9623dbe66c2"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AdministrativeUnit.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7b8a2d34-6b3f-4542-a343-54651608ad81"; Type = "Scope"},
        @{PermissionID = "5eb59dd3-1da2-4329-8733-9dabdc435916"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Agreement.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "af2819c9-df71-4dd3-ade7-4d7c9dc653b7"; Type = "Scope"},
        @{PermissionID = "2f3e6f8c-093b-4c57-a58b-ba5ce494a169"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Agreement.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ef4b5d93-3104-4664-9053-a5c49ab44218"; Type = "Scope"},
        @{PermissionID = "c9090d00-6101-42f0-a729-c41074260d47"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AgreementAcceptance.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0b7643bb-5336-476f-80b5-18fbfbc91806"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AgreementAcceptance.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a66a5341-e66e-4897-9d52-c2df58c2bfb9"; Type = "Scope"},
        @{PermissionID = "d8e4ec18-f6c0-4620-8122-c8b1f2bf400e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Analytics.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e03cf23f-8056-446a-8994-7d93dfc8b50e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/APIConnectors.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1b6ff35f-31df-4332-8571-d31ea5a4893f"; Type = "Scope"},
        @{PermissionID = "b86848a7-d5b1-41eb-a9b4-54a4e6306e97"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/APIConnectors.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c67b52c5-7c69-48b6-9d48-7b3af3ded914"; Type = "Scope"},
        @{PermissionID = "1dfe531a-24a6-4f1b-80f4-7a0dc5a0a171"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AppCatalog.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "88e58d74-d3df-44f3-ad47-e89edf4472e4"; Type = "Scope"},
        @{PermissionID = "e12dae10-5a57-4817-b79d-dfbec5348930"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AppCatalog.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1ca167d5-1655-44a1-8adf-1414072e1ef9"; Type = "Scope"},
        @{PermissionID = "dc149144-f292-421e-b185-5953f2e98d7f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AppCatalog.Submit"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3db89e36-7fa6-4012-b281-85f3d9d9fd2e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AppCertTrustConfiguration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "af281d3a-030d-4122-886e-146fb30a0413"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AppCertTrustConfiguration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4bae2ed4-473e-4841-a493-9829cfd51d48"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Application.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c79f8feb-a9db-4090-85f9-90d820caa0eb"; Type = "Scope"},
        @{PermissionID = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Application.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bdfbf15f-ee85-4955-8675-146e8e5296b5"; Type = "Scope"},
        @{PermissionID = "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Application.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "18a4783c-866b-4cc7-a460-3d5e5662c884"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Application-RemoteDesktopConfig.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ffa91d43-2ad8-45cc-b592-09caddeb24bb"; Type = "Scope"},
        @{PermissionID = "3be0012a-cc4e-426b-895b-f9c836bf6381"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AppRoleAssignment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "84bccea3-f856-4a8a-967b-dbe0a3d53a64"; Type = "Scope"},
        @{PermissionID = "06b708a9-e830-4db3-a914-8e69da51d44f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AttackSimulation.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "104a7a4b-ca76-4677-b7e7-2f4bc482f381"; Type = "Scope"},
        @{PermissionID = "93283d0a-6322-4fa8-966b-8c121624760d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AttackSimulation.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "27608d7c-2c66-4cad-a657-951d575f5a60"; Type = "Scope"},
        @{PermissionID = "e125258e-8c8a-42a8-8f55-ab502afa52f3"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuditLog.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e4c9e354-4dc5-45b8-9e7c-e1393b0b1a20"; Type = "Scope"},
        @{PermissionID = "b0afded3-3588-46d8-8b3d-9842eff778da"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuditLogsQuery.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1d9e7ac3-0eca-442c-82f9-e92625af6e6d"; Type = "Scope"},
        @{PermissionID = "5e1e9171-754d-478c-812c-f1755a9a4c2d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuditLogsQuery-CRM.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba78b16f-1e01-41b6-89ca-73e0a32b304c"; Type = "Scope"},
        @{PermissionID = "20e6f8e4-ffac-4cf7-82f7-70ddb7564318"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuditLogsQuery-Endpoint.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ee3409fe-617f-43cf-bd1e-fc8b38049e69"; Type = "Scope"},
        @{PermissionID = "0bc85aed-7b0b-437a-bac8-3b29a1b84c99"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuditLogsQuery-Entra.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5ff2f415-e0f1-4d11-bfd0-6d87c0f667fd"; Type = "Scope"},
        @{PermissionID = "7276d950-48fc-4269-8348-f22f2bb296d0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuditLogsQuery-Exchange.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6c8c71d2-c7e1-45b0-ac6d-1d2724fba6ae"; Type = "Scope"},
        @{PermissionID = "6b0d2622-d34e-4470-935b-b96550e5ca8d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuditLogsQuery-OneDrive.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4a72c235-a50d-4870-b598-fd88fd1fa074"; Type = "Scope"},
        @{PermissionID = "8a169a81-841c-45fd-ad43-96aede8801a0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuditLogsQuery-SharePoint.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "30630b65-ed12-4a81-9130-e3a964109fae"; Type = "Scope"},
        @{PermissionID = "91c64a47-a524-4fce-9bf3-3d569a344ecf"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuthenticationContext.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "57b030f1-8c35-469c-b0d9-e4a077debe70"; Type = "Scope"},
        @{PermissionID = "381f742f-e1f8-4309-b4ab-e3d91ae4c5c1"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/AuthenticationContext.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba6d575a-1344-4516-b777-1404f5593057"; Type = "Scope"},
        @{PermissionID = "a88eef72-fed0-4bf7-a2a9-f19df33f8b83"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BillingConfiguration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2bf6d319-dfca-4c22-9879-f88dcfaee6be"; Type = "Scope"},
        @{PermissionID = "9e8be751-7eee-4c09-bcfd-d64f6b087fd8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BitlockerKey.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b27a61ec-b99c-4d6a-b126-c4375d08ae30"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BitlockerKey.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5a107bfc-4f00-4e1a-b67e-66451267bc68"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Bookings.Manage.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7f36b48e-542f-4d3b-9bcb-8406f0ab9fdb"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Bookings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "33b1df99-4b29-4548-9339-7a7b83eaeebc"; Type = "Scope"},
        @{PermissionID = "6e98f277-b046-4193-a4f2-6bf6a78cd491"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Bookings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "948eb538-f19d-4ec5-9ccc-f059e1ea4c72"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BookingsAppointment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "02a5a114-36a6-46ff-a102-954d89d9ab02"; Type = "Scope"},
        @{PermissionID = "9769393e-5a9f-4302-9e3d-7e018ecb64a7"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Bookmark.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "98b17b35-f3b1-4849-a85f-9f13733002f0"; Type = "Scope"},
        @{PermissionID = "be95e614-8ef3-49eb-8464-1c9503433b86"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BrowserSiteLists.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "fb9be2b7-a7fc-4182-aec1-eda4597c43d5"; Type = "Scope"},
        @{PermissionID = "c5ee1f21-fc7f-4937-9af0-c91648ff9597"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BrowserSiteLists.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "83b34c85-95bf-497b-a04e-b58eca9d49d0"; Type = "Scope"},
        @{PermissionID = "8349ca94-3061-44d5-9bfb-33774ea5e4f9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BusinessScenarioConfig.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d16480b2-e469-4118-846b-d3d177327bee"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BusinessScenarioConfig.Read.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c47e7b6e-d6f1-4be9-9ffd-1e00f3e32892"; Type = "Scope"},
        @{PermissionID = "acc0fc4d-2cd6-4194-8700-1768d8423d86"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BusinessScenarioConfig.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "755e785b-b658-446f-bb22-5a46abd029ea"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BusinessScenarioConfig.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b3b7fcff-b4d4-4230-bf6f-90bd91285395"; Type = "Scope"},
        @{PermissionID = "bbea195a-4c47-4a4f-bff2-cba399e11698"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BusinessScenarioData.Read.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "25b265c4-5d34-4e44-952d-b567f6d3b96d"; Type = "Scope"},
        @{PermissionID = "6c0257fd-cffe-415b-8239-2d0d70fdaa9c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/BusinessScenarioData.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "19932d57-2952-4c60-8634-3655c79fc527"; Type = "Scope"},
        @{PermissionID = "f2d21f22-5d80-499e-91cc-0a8a4ce16f54"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calendars.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "465a38f9-76ea-45b9-9f34-9e8b0d4b0b42"; Type = "Scope"},
        @{PermissionID = "798ee544-9d2d-430c-a058-570e29e34338"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calendars.Read.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2b9c4092-424d-4249-948d-b43879977640"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calendars.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "662d75ba-a364-42ad-adee-f5f880ea4878"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calendars.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "8ba4a692-bc31-4128-9094-475872af8a53"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calendars.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1ec239c2-d7c9-4623-a91a-a9775856bb36"; Type = "Scope"},
        @{PermissionID = "ef54d2bf-783f-4e0f-bca1-3210c0444d99"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calendars.ReadWrite.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "12466101-c9b8-439a-8589-dd09ee67e8e9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CallEvents.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "43431c03-960e-400f-87c6-8f910321dca3"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CallEvents.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1abb026f-7572-49f6-9ddd-ad61cbba181e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CallRecord-PstnCalls.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a2611786-80b3-417e-adaa-707d4261a5f0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CallRecords.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "45bbb07e-7321-4fd7-a8f6-3ff27e6a81c8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calls.AccessMedia.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a7a681dc-756e-4909-b988-f160edc6655f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calls.Initiate.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "284383ee-7f6e-4e40-a2a8-e85dcb029101"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calls.InitiateGroupCall.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "4c277553-8a09-487b-8023-29ee378d8324"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calls.JoinGroupCall.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f6b49018-60ab-4f81-83bd-22caeabfed2d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Calls.JoinGroupCallAsGuest.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "fd7ccf6b-3d28-418b-9701-cd10f5cd2fd4"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Channel.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "101147cf-4178-4455-9d58-02b5c164e759"; Type = "Scope"},
        @{PermissionID = "f3a65bd4-b703-46df-8f7e-0174fea562aa"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Channel.Delete.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cc83893a-e232-4723-b5af-bd0b01bcfe65"; Type = "Scope"},
        @{PermissionID = "6a118a39-1227-45d4-af0c-ea7b40d210bc"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Channel.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9d8982ae-4365-4f57-95e9-d6032a4c0b87"; Type = "Scope"},
        @{PermissionID = "59a6b24b-4225-4393-8165-ebaec5f55d7a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChannelMember.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2eadaff8-0bce-4198-a6b9-2cfc35a30075"; Type = "Scope"},
        @{PermissionID = "3b55498e-47ec-484f-8136-9013221c06a9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChannelMember.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0c3e411a-ce45-4cd1-8f30-f99a3efa7b11"; Type = "Scope"},
        @{PermissionID = "35930dcf-aceb-4bd1-b99a-8ffed403c974"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChannelMessage.Edit"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2b61aa8a-6d36-4b2f-ac7b-f29867937c53"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChannelMessage.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "767156cb-16ae-4d10-8f8b-41b657c8c8c8"; Type = "Scope"},
        @{PermissionID = "7b2449af-6ccd-4f4d-9f78-e550c193f0d1"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChannelMessage.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5922d31f-46c8-4404-9eaf-2117e390a8a4"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChannelMessage.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ebf0f66e-9fb1-49e4-a278-222f76911cf4"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChannelMessage.UpdatePolicyViolation.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "4d02b0cc-d90b-441f-8d82-4fb55c34d6bb"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChannelSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "233e0cf1-dd62-48bc-b65b-b38fe87fcf8e"; Type = "Scope"},
        @{PermissionID = "c97b873f-f59f-49aa-8a0e-52b32d762124"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChannelSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d649fb7c-72b4-4eec-b2b4-b15acf79e378"; Type = "Scope"},
        @{PermissionID = "243cded2-bd16-4fd6-a953-ff8177894c3d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "38826093-1258-4dea-98f0-00003be2b8d0"; Type = "Scope"},
        @{PermissionID = "d9c48af6-9ad9-47ad-82c3-63757137b9af"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.ManageDeletion.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bb64e6fc-6b6d-4752-aea0-dd922dbba588"; Type = "Scope"},
        @{PermissionID = "9c7abde0-eacd-4319-bf9e-35994b1a1717"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f501c180-9344-439a-bca0-6cbf209fd270"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6b7d71aa-70aa-4810-a8d9-5d9fb2830017"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.Read.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1c1b4c8e-3cc7-4c58-8470-9b92c9d5848b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9547fcb5-d03f-419d-9948-5928bbf71b0f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b2e060da-3baf-4687-9611-f4ebc0f0cbde"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.ReadBasic.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "818ba5bd-5b3e-4fe0-bbe6-aa4686669073"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9ff7295e-131b-4d94-90e1-69fde507ac11"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7e9a077b-3711-42b9-b7cb-5fa5f3f7fea7"; Type = "Scope"},
        @{PermissionID = "294ce7c9-31ba-490a-ad7d-97a7d075e4ed"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.ReadWrite.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "ad73ce80-f3cd-40ce-b325-df12c33df713"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Chat.UpdatePolicyViolation.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "7e847308-e030-4183-9899-5235d7270f58"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChatMember.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c5a9e2b1-faf6-41d4-8875-d381aa549b24"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChatMember.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a3410be2-8e48-4f32-8454-c29a7465209d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChatMember.Read.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "93e7c9e4-54c5-4a41-b796-f2a5adaacda7"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChatMember.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dea13482-7ea6-488f-8b98-eb5bbecf033d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChatMember.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "57257249-34ce-4810-a8a2-a03adf0c5693"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChatMember.ReadWrite.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "e32c2cd9-0124-4e44-88fc-772cd98afbdb"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChatMessage.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cdcdac3a-fd45-410d-83ef-554db620e5c7"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChatMessage.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b9bb2381-47a4-46cd-aafb-00cb12f68504"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ChatMessage.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "116b7235-7cc6-461e-b163-8e55691d839e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CloudApp-Discovery.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ad46d60e-1027-4b75-af88-7c14ccf43a19"; Type = "Scope"},
        @{PermissionID = "64a59178-dad3-4673-89db-84fdcd622fec"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CloudPC.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5252ec4e-fd40-4d92-8c68-89dd1d3c6110"; Type = "Scope"},
        @{PermissionID = "a9e09520-8ed4-4cde-838e-4fdea192c227"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CloudPC.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9d77138f-f0e2-47ba-ab33-cd246c8b79d1"; Type = "Scope"},
        @{PermissionID = "3b4349e1-8cf5-45a3-95b7-69d1751d3e6a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Community.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "12ae2e92-14b5-47b2-babb-4e890bbedc0a"; Type = "Scope"},
        @{PermissionID = "407f0cce-3212-441f-9f55-3bc91342cf86"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Community.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9e69467d-e0e2-402b-a926-3d796990197f"; Type = "Scope"},
        @{PermissionID = "35d59e32-eab5-4553-9345-abb62b4c703c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ConsentRequest.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f2143d35-9b4b-480d-951c-d083e69eeb2c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ConsentRequest.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5942b2f6-5a7b-40af-aa37-4b6ea5447506"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ConsentRequest.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f3bfad56-966e-4590-a536-82ecf548ac1e"; Type = "Scope"},
        @{PermissionID = "1260ad83-98fb-4785-abbb-d6cc1806fd41"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ConsentRequest.ReadApprove.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e694a3a1-7878-46d8-8c29-3d195f6589f4"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ConsentRequest.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "497d9dfa-3bd1-481a-baab-90895e54568c"; Type = "Scope"},
        @{PermissionID = "9f1b81a7-0223-4428-bfa4-0bcb5535f27d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Contacts.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ff74d97f-43af-4b68-9f2a-b77ee6968c5d"; Type = "Scope"},
        @{PermissionID = "089fe4d0-434a-44c5-8827-41ba8a0b17f5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Contacts.Read.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "242b9d9e-ed24-4d09-9a52-f43769beb9d4"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Contacts.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d56682ec-c09e-4743-aaf4-1a3aac4caa21"; Type = "Scope"},
        @{PermissionID = "6918b873-d17a-4dc1-b314-35f528134491"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Contacts.ReadWrite.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "afb6c84b-06be-49af-80bb-8f3f77004eab"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CrossTenantInformation.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "81594d25-e88e-49cf-ac8c-fecbff49f994"; Type = "Scope"},
        @{PermissionID = "cac88765-0581-4025-9725-5ebc13f729ee"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CrossTenantUserProfileSharing.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cb1ba48f-d22b-4325-a07f-74135a62ee41"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CrossTenantUserProfileSharing.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "759dcd16-3c90-463c-937e-abf89f991c18"; Type = "Scope"},
        @{PermissionID = "8b919d44-6192-4f3d-8a3b-f86f8069ae3c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CrossTenantUserProfileSharing.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "eed0129d-dc60-4f30-8641-daf337a39ffd"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CrossTenantUserProfileSharing.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "64dfa325-cbf8-48e3-938d-51224a0cac01"; Type = "Scope"},
        @{PermissionID = "306785c5-c09b-4ba0-a4ee-023f3da165cb"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomAuthenticationExtension.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b2052569-c98c-4f36-a5fb-43e5c111e6d0"; Type = "Scope"},
        @{PermissionID = "88bb2658-5d9e-454f-aacd-a3933e079526"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomAuthenticationExtension.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8dfcf82f-15d0-43b3-bc78-a958a13a5792"; Type = "Scope"},
        @{PermissionID = "c2667967-7050-4e7e-b059-4cbbb3811d03"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomAuthenticationExtension.Receive.Payload"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "214e810f-fda8-4fd7-a475-29461495eb00"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomDetection.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b13ff42e-f321-4d7d-a462-141c46a1b832"; Type = "Scope"},
        @{PermissionID = "673a007a-9e0f-4c97-b066-3c0164486909"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomDetection.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c34088fb-0649-4714-af0b-bcbfec155897"; Type = "Scope"},
        @{PermissionID = "e0fd9c8d-a12e-4cc9-9827-20c8c3cd6fb8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomSecAttributeAssignment.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b46ffa80-fe3d-4822-9a1a-c200932d54d0"; Type = "Scope"},
        @{PermissionID = "3b37c5a4-1226-493d-bec3-5d6c6b866f3f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomSecAttributeAssignment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ca46335e-8453-47cd-a001-8459884efeae"; Type = "Scope"},
        @{PermissionID = "de89b5e4-5b8f-48eb-8925-29c2b33bd8bd"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomSecAttributeAuditLogs.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1fcdeaab-b519-44dd-bffc-ed1fd15a24e0"; Type = "Scope"},
        @{PermissionID = "2a4f026d-e829-4e84-bdbf-d981a2703059"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomSecAttributeDefinition.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ce026878-a0ff-4745-a728-d4fedd086c07"; Type = "Scope"},
        @{PermissionID = "b185aa14-d8d2-42c1-a685-0f5596613624"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomSecAttributeDefinition.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8b0160d4-5743-482b-bb27-efc0a485ca4a"; Type = "Scope"},
        @{PermissionID = "12338004-21f4-4896-bf5e-b75dfaf1016d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomTags.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "de6ea87d-10bd-467c-8682-d525a0c61b89"; Type = "Scope"},
        @{PermissionID = "ab8a5872-7c88-47a6-8141-7becce939190"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/CustomTags.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2f1bbe0a-f34b-4efb-9edb-8db8dcb50eca"; Type = "Scope"},
        @{PermissionID = "2f503208-e509-4e39-974c-8cc16e5785c9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DelegatedAdminRelationship.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0c0064ea-477b-4130-82a5-4c2cc4ff68aa"; Type = "Scope"},
        @{PermissionID = "f6e9e124-4586-492f-adc0-c6f96e4823fd"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DelegatedAdminRelationship.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "885f682f-a990-4bad-a642-36736a74b0c7"; Type = "Scope"},
        @{PermissionID = "cc13eba4-8cd8-44c6-b4d4-f93237adce58"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DelegatedPermissionGrant.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a197cdc4-a8e8-4d49-9d35-4ca7c83887b4"; Type = "Scope"},
        @{PermissionID = "81b4724a-58aa-41c1-8a55-84ef97466587"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DelegatedPermissionGrant.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "41ce6ca6-6826-4807-84f1-1c82854f7ee5"; Type = "Scope"},
        @{PermissionID = "8e8e4742-1d95-4f68-9d56-6ee75648c72a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Device.Command"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bac3b9c2-b516-4ef4-bd3b-c2ef73d8d804"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Device.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "11d4cd79-5ba5-460f-803f-e22c8ab85ccd"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Device.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "951183d1-1a61-466f-a6d1-1fde911bfd95"; Type = "Scope"},
        @{PermissionID = "7438b122-aefc-4978-80ed-43db9fcc7715"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Device.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1138cb37-bd11-4084-a2b7-9f71582aeddb"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceLocalCredential.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "280b3b69-0437-44b1-bc20-3b2fca1ee3e9"; Type = "Scope"},
        @{PermissionID = "884b599e-4d48-43a5-ba94-15c414d00588"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceLocalCredential.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9917900e-410b-4d15-846e-42a357488545"; Type = "Scope"},
        @{PermissionID = "db51be59-e728-414b-b800-e0f010df1a79"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementApps.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4edf5f54-4666-44af-9de9-0144fb4b6e8c"; Type = "Scope"},
        @{PermissionID = "7a6ee1e7-141e-4cec-ae74-d9db155731ff"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementApps.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7b3f05d5-f68c-4b8d-8c59-a2ecd12f24af"; Type = "Scope"},
        @{PermissionID = "78145de6-330d-4800-a6ce-494ff2d33d07"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementConfiguration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f1493658-876a-4c87-8fa7-edb559b3476a"; Type = "Scope"},
        @{PermissionID = "dc377aa6-52d8-4e23-b271-2a7ae04cedf3"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementConfiguration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0883f392-0a7a-443d-8c76-16a6d39c7b63"; Type = "Scope"},
        @{PermissionID = "9241abd9-d0e6-425a-bd4f-47ba86e767a4"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementManagedDevices.PrivilegedOperations.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3404d2bf-2b13-457e-a330-c24615765193"; Type = "Scope"},
        @{PermissionID = "5b07b0dd-2377-4e44-a38d-703f09a0dc3c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementManagedDevices.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "314874da-47d6-4978-88dc-cf0d37f0bb82"; Type = "Scope"},
        @{PermissionID = "2f51be20-0bb4-4fed-bf7b-db946066c75e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementManagedDevices.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "44642bfe-8385-4adc-8fc6-fe3cb2c375c3"; Type = "Scope"},
        @{PermissionID = "243333ab-4d21-40cb-a475-36241daa0842"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementRBAC.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "49f0cc30-024c-4dfd-ab3e-82e137ee5431"; Type = "Scope"},
        @{PermissionID = "58ca0d9a-1575-47e1-a3cb-007ef2e4583b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementRBAC.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0c5e8a55-87a6-4556-93ab-adc52c4d862d"; Type = "Scope"},
        @{PermissionID = "e330c4f0-4170-414e-a55a-2f022ec2b57b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementServiceConfig.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8696daa5-bce5-4b2e-83f9-51b6defc4e1e"; Type = "Scope"},
        @{PermissionID = "06a5fe6d-c49d-46a7-b082-56b1b14103c7"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DeviceManagementServiceConfig.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "662ed50a-ac44-4eef-ad86-62eed9be2a29"; Type = "Scope"},
        @{PermissionID = "5ac13192-7ace-4fcf-b828-1a26f28068ee"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Directory.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0e263e50-5827-48a4-b97c-d940288653c7"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Directory.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "06da0dbc-49e2-44d2-8312-53f166ab848a"; Type = "Scope"},
        @{PermissionID = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Directory.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c5366453-9fb0-48a5-a156-24f0c49a4b84"; Type = "Scope"},
        @{PermissionID = "19dbc75e-c2e2-444c-a770-ec69d8559fc7"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Directory.Write.Restricted"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cba5390f-ed6a-4b7f-b657-0efc2210ed20"; Type = "Scope"},
        @{PermissionID = "f20584af-9290-4153-9280-ff8bb2c0ea7f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DirectoryRecommendations.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "34d3bd24-f6a6-468c-b67c-0c365c1d6410"; Type = "Scope"},
        @{PermissionID = "ae73097b-cb2a-4447-b064-5d80f6093921"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/DirectoryRecommendations.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f37235e8-90a0-4189-93e2-e55b53867ccd"; Type = "Scope"},
        @{PermissionID = "0e9eea12-4f01-45f6-9b8d-3ea4c8144158"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Domain.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2f9ee017-59c1-4f1d-9472-bd5529a7b311"; Type = "Scope"},
        @{PermissionID = "dbb9058a-0e50-45d7-ae91-66909b5d4664"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Domain.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0b5d694c-a244-4bde-86e6-eb5cd07730fe"; Type = "Scope"},
        @{PermissionID = "7e05723c-0bb0-42da-be95-ae9f08a6e53c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EAS.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ff91d191-45a0-43fd-b837-bd682c4a0b0f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/eDiscovery.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "99201db3-7652-4d5a-809a-bdb94f85fe3c"; Type = "Scope"},
        @{PermissionID = "50180013-6191-4d1e-a373-e590ff4e66af"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/eDiscovery.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "acb8f680-0834-4146-b69e-4ab1b39745ad"; Type = "Scope"},
        @{PermissionID = "b2620db1-3bf7-4c5b-9cb9-576d29eac736"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAdministration.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8523895c-6081-45bf-8a5d-f062a2f12c9f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAdministration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "7c9db06a-ec2d-4e7b-a592-5a1e30992566"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAdministration.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "63589852-04e3-46b4-bae9-15d5b1050748"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAdministration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9bc431c3-b8bc-4a8d-a219-40f10f92eff6"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAssignments.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "091460c9-9c4a-49b2-81ef-1f3d852acce2"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAssignments.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "4c37e1b6-35a1-43bf-926a-6f30f2cdf585"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAssignments.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c0b0103b-c053-4b2e-9973-9f3a544ec9b8"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAssignments.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6e0a958b-b7fc-4348-b7c4-a6ab9fd3dd0e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAssignments.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2f233e90-164b-4501-8bce-31af2559a2d3"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAssignments.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "0d22204b-6cad-4dd0-8362-3e3f2ae699d9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAssignments.ReadWriteBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2ef770a1-622a-47c4-93ee-28d6adbed3a0"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduAssignments.ReadWriteBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f431cc63-a2de-48c4-8054-a34bc093af84"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduCurricula.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "484859e8-b9e2-4e92-b910-84db35dadd29"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduCurricula.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6cdb464c-3a03-40f8-900b-4cb7ea1da9c0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduCurricula.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4793c53b-df34-44fd-8d26-d15c517732f5"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduCurricula.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6a0c2318-d59d-4c7d-bf2e-5f3902dc2593"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduReports-Reading.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "ad248c30-1919-40c8-b3d2-304481894e88"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduReports-Reading.ReadAnonymous.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "040330d7-be7e-4130-b349-a6eb3a56e2f8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduReports-Reflect.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "c5debf73-bdc8-473d-bf07-f4074ad05f71"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduReports-Reflect.ReadAnonymous.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f5d05dba-7ef0-46fc-b62c-a7282555f428"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduRoster.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a4389601-22d9-4096-ac18-36a927199112"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduRoster.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "e0ac9e1b-cb65-4fc5-87c5-1a8bc181f648"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduRoster.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5d186531-d1bf-4f07-8cea-7c42119e1bd9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduRoster.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "0d412a8c-a06c-439f-b3ec-8abcf54d2f96"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduRoster.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "359e19a6-e3fa-4d7f-bcab-d28ec592b51e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EduRoster.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "d1808e82-ce13-47af-ae0d-f9b254e6d58a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/email"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EntitlementManagement.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5449aa12-1393-4ea2-a7c7-d0e06c1a56b2"; Type = "Scope"},
        @{PermissionID = "c74fd47d-ed3c-45c3-9a9e-b8676de685d2"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EntitlementManagement.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ae7a573d-81d7-432b-ad44-4ed5c9d89038"; Type = "Scope"},
        @{PermissionID = "9acd699f-1e81-4958-b001-93b1d2506e19"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EntitlementMgmt-SubjectAccess.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e9fdcbbb-8807-410f-b9ec-8d5468c7c2ac"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EventListener.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f7dd3bed-5eec-48da-bc73-1c0ef50bc9a1"; Type = "Scope"},
        @{PermissionID = "b7f6385c-6ce6-4639-a480-e23c42ed9784"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EventListener.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d11625a6-fe21-4fc6-8d3d-063eba5525ad"; Type = "Scope"},
        @{PermissionID = "0edf5e9e-4ce8-468a-8432-d08631d18c43"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/EWS.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9769c687-087d-48ac-9cb3-c37dde652038"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ExternalConnection.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a38267a5-26b6-4d76-9493-935b7599116b"; Type = "Scope"},
        @{PermissionID = "1914711b-a1cb-4793-b019-c2ce0ed21b8c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ExternalConnection.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bbbbd9b3-3566-4931-ac37-2b2180d9e334"; Type = "Scope"},
        @{PermissionID = "34c37bc0-2b40-4d5e-85e1-2365cd256d79"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ExternalConnection.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4082ad95-c812-4f02-be92-780c4c4f1830"; Type = "Scope"},
        @{PermissionID = "f431331c-49a6-499f-be1c-62af19c34a9d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ExternalItem.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "922f9392-b1b7-483c-a4be-0089be7704fb"; Type = "Scope"},
        @{PermissionID = "7a7cffad-37d2-4f48-afa4-c6ab129adcc2"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ExternalItem.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b02c54f8-eb48-4c50-a9f0-a149e5a2012f"; Type = "Scope"},
        @{PermissionID = "38c3d6ee-69ee-422f-b954-e17819665354"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ExternalItem.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4367b9d7-cee7-4995-853c-a0bdfe95c1f9"; Type = "Scope"},
        @{PermissionID = "8116ae0f-55c2-452d-9944-d18420f5b2c8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ExternalUserProfile.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "47167bec-55a7-4caf-9ecc-8d4566e3cfb1"; Type = "Scope"},
        @{PermissionID = "1987d7a0-d602-4262-ab90-cfdd43b37545"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ExternalUserProfile.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c6068dc7-a791-46a4-a811-b8228e6649ab"; Type = "Scope"},
        @{PermissionID = "761327c9-d819-4c08-9a5f-874cd2826608"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Family.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3a1e4806-a744-4c70-80fc-223bf8582c46"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Files.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "10465720-29dd-4523-a11a-6a75c743c9d9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Files.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "df85f4d6-205c-4ac5-a5ea-6bf408dba283"; Type = "Scope"},
        @{PermissionID = "01d4889c-1287-42c6-ac1f-5d1e02578ef6"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Files.Read.Selected"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5447fe39-cb82-4c1a-b977-520e67e724eb"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Files.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5c28f0bf-8a70-41f1-8ab2-9032436ddb65"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Files.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "863451e7-0667-486c-a5d6-d135439485f0"; Type = "Scope"},
        @{PermissionID = "75359482-378d-4052-8f01-80520e7db3cd"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Files.ReadWrite.AppFolder"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8019c312-3263-48e6-825e-2b833497195b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Files.ReadWrite.Selected"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "17dde5bd-8c17-420f-a486-969730c1b827"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/FileStorageContainer.Selected"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "085ca537-6565-41c2-aca7-db852babc212"; Type = "Scope"},
        @{PermissionID = "40dc41bc-0f7e-42ff-89bd-d9516947e474"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Financials.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f534bf13-55d4-45a9-8f3c-c92fe64d6131"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Goals-Export.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "092211d9-ca1a-427b-813e-b79c7653fe71"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Goals-Export.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2edeb9fd-4228-480c-a26d-2ed52011cf3d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Group.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "bf7b1a76-6e77-406b-b258-bf5c7720e98f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Group.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5f8c59db-677d-491f-a6b8-5f174b11ec1d"; Type = "Scope"},
        @{PermissionID = "5b567255-7703-4780-807c-7be8301ae99b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Group.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4e46008b-f24c-477d-8fff-7bb4ec7aafe0"; Type = "Scope"},
        @{PermissionID = "62a82d76-70ea-41e2-9197-370581804d09"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/GroupMember.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bc024368-1153-4739-b217-4326f2e966d0"; Type = "Scope"},
        @{PermissionID = "98830695-27a2-44f7-8c18-0c3ebc9698f6"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/GroupMember.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f81125ac-d3b7-4573-a3b2-7099cc39df9e"; Type = "Scope"},
        @{PermissionID = "dbaae8cf-10b5-4b86-a4a1-f871c94c6695"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityProvider.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "43781733-b5a7-4d1b-98f4-e8edff23e1a9"; Type = "Scope"},
        @{PermissionID = "e321f0bb-e7f7-481e-bb28-e3b0b32d4bd0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityProvider.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f13ce604-1677-429f-90bd-8a10b9f01325"; Type = "Scope"},
        @{PermissionID = "90db2b9a-d928-4d33-a4dd-8442ae3d41e4"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityRiskEvent.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8f6a01e7-0391-4ee5-aa22-a3af122cef27"; Type = "Scope"},
        @{PermissionID = "6e472fd1-ad78-48da-a0f0-97ab2c6b769e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityRiskEvent.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9e4862a5-b68f-479e-848a-4e07e25c9916"; Type = "Scope"},
        @{PermissionID = "db06fb33-1953-4b7b-a2ac-f1e2c854f7ae"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityRiskyServicePrincipal.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ea5c4ab0-5a73-4f35-8272-5d5337884e5d"; Type = "Scope"},
        @{PermissionID = "607c7344-0eed-41e5-823a-9695ebe1b7b0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityRiskyServicePrincipal.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bb6f654c-d7fd-4ae3-85c3-fc380934f515"; Type = "Scope"},
        @{PermissionID = "cb8d6980-6bcb-4507-afec-ed6de3a2d798"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityRiskyUser.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d04bb851-cb7c-4146-97c7-ca3e71baf56c"; Type = "Scope"},
        @{PermissionID = "dc5007c0-2d7d-4c42-879c-2dab87571379"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityRiskyUser.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e0a7cdbb-08b0-4697-8264-0069786e9674"; Type = "Scope"},
        @{PermissionID = "656f6061-f9fe-4807-9708-6a2e0934df76"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityUserFlow.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2903d63d-4611-4d43-99ce-a33f3f52e343"; Type = "Scope"},
        @{PermissionID = "1b0c317f-dd31-4305-9932-259a8b6e8099"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IdentityUserFlow.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "281892cc-4dbf-4e3a-b6cc-b21029bb4e82"; Type = "Scope"},
        @{PermissionID = "65319a09-a2be-469d-8782-f6b07debf789"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IMAP.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "652390e4-393a-48de-9484-05f9b1212954"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "60382b96-1f5e-46ea-a544-0407e489e588"; Type = "Scope"},
        @{PermissionID = "4f5ac95f-62fd-472c-b60f-125d24ca0bc5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-DataConnector.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d19c0de5-7ecb-4aba-b090-da35ebcd5425"; Type = "Scope"},
        @{PermissionID = "7ab52c2f-a2ee-4d98-9ebc-725e3934aae2"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-DataConnector.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5ce933ac-3997-4280-aed0-cc072e5c062a"; Type = "Scope"},
        @{PermissionID = "eda0971c-482e-4345-b28f-69c309cb8a34"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-DataConnector.Upload"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "fc47391d-ab2c-410f-9059-5600f7af660d"; Type = "Scope"},
        @{PermissionID = "9334c44b-a7c6-4350-8036-6bf8e02b4c1f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-InboundFlow.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cb0774da-a605-42af-959c-32f438fb38f4"; Type = "Scope"},
        @{PermissionID = "305f6ba2-049a-4b1b-88bb-fe7e08758a00"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-InboundFlow.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "97044676-2cec-40ee-bd70-38df444c9e70"; Type = "Scope"},
        @{PermissionID = "e688c61f-d4c6-4d64-a197-3bcf6ba1d6ad"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-OutboundFlow.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4741a003-8952-4be4-9217-33a0ac327122"; Type = "Scope"},
        @{PermissionID = "61d0354c-5d88-483c-b974-a37ec3395a2c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-OutboundFlow.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "aeb68e0b-e562-4a1f-b6dd-3484ad0cbb4b"; Type = "Scope"},
        @{PermissionID = "24a65b4a-e501-47e2-8849-d679517887f0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-ReferenceDefinition.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a3f96ffe-cb84-40a8-ac85-582d7ef97c2a"; Type = "Scope"},
        @{PermissionID = "6ee891c3-74a4-4148-8463-0c834375dfaf"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-Run.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "92685235-50c4-4702-b2c8-36043db6fa79"; Type = "Scope"},
        @{PermissionID = "f6f5d10b-3024-4d1d-b674-aae4df4a1a73"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-SourceSystem.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "49b7016c-89ae-41e7-bd6f-b7170c5490bf"; Type = "Scope"},
        @{PermissionID = "bc167a60-39fe-4865-8b44-78400fc6ed03"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-SourceSystem.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9599f005-05d6-4ea7-b1b1-4929768af5d0"; Type = "Scope"},
        @{PermissionID = "7d866958-e06e-4dd6-91c6-a086b3f5cfeb"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-TimePeriod.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c9d51f28-8ccd-42b2-a836-fd8fe9ebf2ae"; Type = "Scope"},
        @{PermissionID = "7c55c952-b095-4c23-a522-022bce4cc1e3"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/IndustryData-TimePeriod.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b6d56528-3032-4f9d-830f-5a24a25e6661"; Type = "Scope"},
        @{PermissionID = "7afa7744-a782-4a32-b8c2-e3db637e8de7"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/InformationProtectionConfig.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "12f4bffb-b598-413c-984b-db99728f8b54"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/InformationProtectionConfig.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "14f49b9f-4bf2-4d24-b80e-b27ec58409bd"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/InformationProtectionContent.Sign.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "cbe6c7e4-09aa-4b8d-b3c3-2dbb59af4b54"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/InformationProtectionContent.Write.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "287bd98c-e865-4e8c-bade-1a85523195b9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/InformationProtectionPolicy.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4ad84827-5578-4e18-ad7a-86530b12f884"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/InformationProtectionPolicy.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "19da66cb-0fb0-4390-b071-ebc76a349482"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Insights-UserMetric.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7d249730-51a3-4180-8ec1-214f144f1bff"; Type = "Scope"},
        @{PermissionID = "34cbd96c-d824-4755-90d3-1008ef47efc1"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningAssignedCourse.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ac08cdae-e845-41db-adf9-5899a0ec9ef6"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningAssignedCourse.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "535e6066-2894-49ef-ab33-e2c6d064bb81"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningAssignedCourse.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "236c1cbd-1187-427f-b0f5-b1852454973b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningContent.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ea4c1fd9-6a9f-4432-8e5d-86e06cc0da77"; Type = "Scope"},
        @{PermissionID = "8740813e-d8aa-4204-860e-2a0f8f84dbc8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningContent.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "53cec1c4-a65f-4981-9dc1-ad75dbf1c077"; Type = "Scope"},
        @{PermissionID = "444d6fcb-b738-41e5-b103-ac4f2a2628a3"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningProvider.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dd8ce36f-9245-45ea-a99e-8ac398c22861"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningProvider.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "40c2eb57-abaf-49f5-9331-e90fd01f7130"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningSelfInitiatedCourse.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f6403ef7-4a96-47be-a190-69ba274c3f11"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningSelfInitiatedCourse.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "467524fc-ed22-4356-a910-af61191e3503"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LearningSelfInitiatedCourse.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "7654ed61-8965-4025-846a-0856ec02b5b0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LicenseAssignment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f55016cc-149c-447e-8f21-7cf3ec1d6350"; Type = "Scope"},
        @{PermissionID = "5facf0c1-8979-4e95-abcf-ff3d079771c0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LifecycleWorkflows.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9bcb9916-765a-42af-bf77-02282e26b01a"; Type = "Scope"},
        @{PermissionID = "7c67316a-232a-4b84-be22-cea2c0906404"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/LifecycleWorkflows.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "84b9d731-7db8-4454-8c90-fd9e95350179"; Type = "Scope"},
        @{PermissionID = "5c505cf4-8424-4b8e-aa14-ee06e3bb23e3"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Mail.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "570282fd-fa5c-430d-a7fd-fc8dc98a9dca"; Type = "Scope"},
        @{PermissionID = "810c84a8-4a9e-49e6-bf7d-12d183f40d01"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Mail.Read.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7b9103a5-4610-446b-9670-80643382c1fa"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Mail.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a4b8392a-d8d1-4954-a029-8e668a39a170"; Type = "Scope"},
        @{PermissionID = "6be147d2-ea4f-4b5a-a3fa-3eab6f3c140a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Mail.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "693c5e45-0940-467d-9b8a-1022fb9d42ef"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Mail.ReadBasic.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b11fa0e7-fdb7-4dc9-b1f1-59facd463480"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Mail.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "024d486e-b451-40bb-833d-3e66d98c5c73"; Type = "Scope"},
        @{PermissionID = "e2a3a72e-5f79-4c64-b1b1-878b674786c9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Mail.ReadWrite.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5df07973-7d5d-46ed-9847-1271055cbd51"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Mail.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e383f46e-2787-4529-855e-0e479a3ffac0"; Type = "Scope"},
        @{PermissionID = "b633e1c5-b582-4048-a93e-9f11b44c7e96"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Mail.Send.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a367ab51-6b49-43bf-a716-a1fb06d2a174"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/MailboxSettings.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "87f447af-9fa4-4c32-9dfa-4a57a73d18ce"; Type = "Scope"},
        @{PermissionID = "40f97065-369a-49f4-947c-6a255697ae91"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/MailboxSettings.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "818c620a-27a9-40bd-a6a5-d96f7d610b4b"; Type = "Scope"},
        @{PermissionID = "6931bccd-447a-43d1-b442-00a195474933"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ManagedTenants.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dc34164e-6c4a-41a0-be89-3ae2fbad7cd3"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ManagedTenants.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b31fa710-c9b3-4d9e-8f5e-8036eecddab9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Member.Read.Hidden"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f6a3db3e-f7e8-4ed2-a414-557c8c9830be"; Type = "Scope"},
        @{PermissionID = "658aa5d8-239f-45c4-aa12-864f4fc7e490"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/MultiTenantOrganization.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "526aa72a-5878-49fe-bf4e-357973af9b06"; Type = "Scope"},
        @{PermissionID = "4f994bc0-31bb-44bb-b480-7a7c1be8c02e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/MultiTenantOrganization.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "225db56b-15b2-4daa-acb3-0eec2bbe4849"; Type = "Scope"},
        @{PermissionID = "f9c2b2a7-3895-4b2e-80f6-c924b456e50b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/MultiTenantOrganization.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "77af1528-84f3-4023-8d90-d219cd433108"; Type = "Scope"},
        @{PermissionID = "920def01-ca61-4d2d-b3df-105b46046a70"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/NetworkAccess.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2f7013e0-ab4e-447f-a5e1-5d419950692d"; Type = "Scope"},
        @{PermissionID = "e30060de-caa5-4331-99d3-6ac6c966a9a4"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/NetworkAccess.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ae2df9c5-f18d-4ec4-a51b-bdeb807f177b"; Type = "Scope"},
        @{PermissionID = "b10642fc-a6cf-4c46-87f9-e1f96c2a18aa"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/NetworkAccessBranch.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4051c7fc-b429-4804-8d80-8f1f8c24a6f7"; Type = "Scope"},
        @{PermissionID = "39ae4a24-1ef0-49e8-9d63-2a66f5c39edd"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/NetworkAccessBranch.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b8a36cc2-b810-461a-baa4-a7281e50bd5c"; Type = "Scope"},
        @{PermissionID = "8137102d-ec16-4191-aaf8-7aeda8026183"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/NetworkAccessPolicy.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba22922b-752c-446f-89d7-a2d92398fceb"; Type = "Scope"},
        @{PermissionID = "8a3d36bf-cb46-4bcc-bec9-8d92829dab84"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/NetworkAccessPolicy.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b1fbad0f-ef6e-42ed-8676-bca7fa3e7291"; Type = "Scope"},
        @{PermissionID = "f0c341be-8348-4989-8e43-660324294538"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/NetworkAccess-Reports.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b0c61509-cfc3-42bd-9bd4-66d81785fee4"; Type = "Scope"},
        @{PermissionID = "40049381-3cc1-42af-94ec-5ce755db4b0d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Notes.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9d822255-d64d-4b7a-afdb-833b9a97ed02"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Notes.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "371361e4-b9e2-4a3f-8315-2a301a3b0a3d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Notes.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dfabfca6-ee36-4db2-8208-7a28381419b3"; Type = "Scope"},
        @{PermissionID = "3aeca27b-ee3a-4c2b-8ded-80376e2134a4"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Notes.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "615e26af-c38a-4150-ae3e-c3b0d4cb1d6a"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Notes.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "64ac0503-b4fa-45d9-b544-71a463f05da0"; Type = "Scope"},
        @{PermissionID = "0c458cef-11f3-48c2-a568-c66751c238c0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Notes.ReadWrite.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ed68249d-017c-4df5-9113-e684c7f8760b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Notifications.ReadWrite.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "89497502-6e42-46a2-8cb2-427fd3df970a"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/offline_access"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnlineMeetingArtifact.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "110e5abb-a10c-4b59-8b55-9b4daa4ef743"; Type = "Scope"},
        @{PermissionID = "df01ed3b-eb61-4eca-9965-6b3d789751b2"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnlineMeetingRecording.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "190c2bb6-1fdd-4fec-9aa2-7d571b5e1fe3"; Type = "Scope"},
        @{PermissionID = "a4a08342-c95d-476b-b943-97e100569c8d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnlineMeetings.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9be106e1-f4e3-4df5-bdff-e4bc531cbe43"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnlineMeetings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "c1684f21-1984-47fa-9d61-2dc8c296bb70"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnlineMeetings.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a65f2972-a4f8-4f5e-afd7-69ccb046d5dc"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnlineMeetings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b8bb2037-6e08-44ac-a4ea-4674e010e2a4"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnlineMeetingTranscript.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "30b87d18-ebb1-45db-97f8-82ccb1f0190c"; Type = "Scope"},
        @{PermissionID = "a4a80d8d-d283-4bd8-8504-555ec3870630"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnPremDirectorySynchronization.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f6609722-4100-44eb-b747-e6ca0536989d"; Type = "Scope"},
        @{PermissionID = "bb70e231-92dc-4729-aff5-697b3f04be95"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnPremDirectorySynchronization.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c2d95988-7604-4ba1-aaed-38a5f82a51c7"; Type = "Scope"},
        @{PermissionID = "c22a92cc-79bf-4bb1-8b6c-e0a05d3d80ce"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OnPremisesPublishingProfiles.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8c4d5184-71c2-4bf8-bb9d-bc3378c9ad42"; Type = "Scope"},
        @{PermissionID = "0b57845e-aa49-4e6f-8109-ce654fffa618"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/openid"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "37f7f235-527c-4136-accd-4a02d197296e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Organization.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4908d5b9-3fb2-4b1e-9336-1888b7937185"; Type = "Scope"},
        @{PermissionID = "498476ce-e0fe-48b0-b801-37ba7e2685c6"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Organization.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "46ca0847-7e6b-426e-9775-ea810a948356"; Type = "Scope"},
        @{PermissionID = "292d869f-3427-49a8-9dab-8c70152b74e9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrganizationalBranding.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9082f138-6f02-4f3a-9f4d-5f3c2ce5c688"; Type = "Scope"},
        @{PermissionID = "eb76ac34-0d62-4454-b97c-185e4250dc20"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrganizationalBranding.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "15ce63de-b141-4c9a-a9a5-241bf27c6aaf"; Type = "Scope"},
        @{PermissionID = "d2ebfbc1-a5f8-424b-83a6-56ab5927a73c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgContact.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "08432d1b-5911-483c-86df-7980af5cdee0"; Type = "Scope"},
        @{PermissionID = "e1a88a34-94c4-4418-be12-c87b00e26bea"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-AppsAndServices.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1e9b7a7e-4d64-44ff-acf5-2e9651c1519f"; Type = "Scope"},
        @{PermissionID = "56c84fa9-ea1f-4a15-90f2-90ef41ece2c9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-AppsAndServices.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c167b0e7-47c0-48e8-9eee-9892f58018fa"; Type = "Scope"},
        @{PermissionID = "4a8e4191-c1c8-45f8-b801-f9a1a5ee6ad3"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-DynamicsVoice.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9862d930-5aec-4a98-8d4f-7277a8db9bcb"; Type = "Scope"},
        @{PermissionID = "c18ae2dc-d9f3-4495-a93f-18980a0e159f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-DynamicsVoice.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4cea26fb-6967-4234-82c4-c044414743f8"; Type = "Scope"},
        @{PermissionID = "c3f1cc32-8bbd-4ab6-bd33-f270e0d9e041"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-Forms.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "210051a0-1ffc-435c-ae76-02d226d05752"; Type = "Scope"},
        @{PermissionID = "434d7c66-07c6-4b1f-ab21-417cf2cdaaca"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-Forms.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "346c19ff-3fb2-4e81-87a0-bac9e33990c1"; Type = "Scope"},
        @{PermissionID = "2cb92fee-97a3-4034-8702-24a6f5d0d1e9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-Microsoft365Install.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8cbdb9f6-9c2e-451a-814d-ec606e5d0212"; Type = "Scope"},
        @{PermissionID = "6cdf1fb1-b46f-424f-9493-07247caa22e2"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-Microsoft365Install.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1ff35e91-19eb-42d8-aa2d-cc9891127ae5"; Type = "Scope"},
        @{PermissionID = "83f7232f-763c-47b2-a097-e35d2cbe1da5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-Todo.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7ff96f41-f022-45ba-acd8-ef3f03063d6b"; Type = "Scope"},
        @{PermissionID = "e4d9cd09-d858-4363-9410-abb96737f0cf"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/OrgSettings-Todo.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "087502c2-5263-433e-abe3-8f77231a0627"; Type = "Scope"},
        @{PermissionID = "5febc9da-e0d0-4576-bd13-ae70b2179a39"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PartnerBilling.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8804798e-5934-4e30-8ce3-ef88257cecd4"; Type = "Scope"},
        @{PermissionID = "7c3e1994-38ff-4412-a99b-9369f6bb7706"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PendingExternalUserProfile.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d88fd3fb-53d3-4c1c-8c39-787fcac2ed7a"; Type = "Scope"},
        @{PermissionID = "bdfb26d9-bb36-49be-9b4c-b8cbf4b05808"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PendingExternalUserProfile.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "93a1fb28-c908-4826-904e-0c74ad352b73"; Type = "Scope"},
        @{PermissionID = "8363c2b8-6ff7-420b-9966-c5884c2d48bc"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/People.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba47897c-39ec-4d83-8086-ee8256fa737d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/People.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b89f9189-71a5-4e70-b041-9887f0bc7e4a"; Type = "Scope"},
        @{PermissionID = "b528084d-ad10-4598-8b93-929746b4d7d6"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PeopleSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ec762c5f-388b-4b16-8693-ac1efbc611bc"; Type = "Scope"},
        @{PermissionID = "ef02f2e7-e22d-4c77-8614-8f765683b86e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PeopleSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e67e6727-c080-415e-b521-e3f35d5248e9"; Type = "Scope"},
        @{PermissionID = "b6890674-9dd5-4e42-bb15-5af07f541ae1"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Place.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cb8f45a0-5c2e-4ea1-b803-84b870a7d7ec"; Type = "Scope"},
        @{PermissionID = "913b9306-0ce1-42b8-9137-6a7df690a760"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Place.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4c06a06a-098a-4063-868e-5dfee3827264"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PlaceDevice.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4c7f93d2-6b0b-4e05-91aa-87842f0a2142"; Type = "Scope"},
        @{PermissionID = "8b724a84-ceac-4fd9-897e-e31ba8f2d7a3"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PlaceDevice.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "eafd6a71-e95a-4f8a-bb6e-fb84ab7fbd9e"; Type = "Scope"},
        @{PermissionID = "2d510721-5c4e-43cd-bfdb-ac0f8819fb92"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PlaceDeviceTelemetry.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "27fc435f-44e2-4b30-bf3c-e0ce74aed618"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "572fea84-0151-49b2-9301-11cb16974376"; Type = "Scope"},
        @{PermissionID = "246dd0d5-5bd0-4def-940b-0421030a5b68"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.Read.ConditionalAccess"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "633e0fce-8c58-4cfb-9495-12bbd5a24f7c"; Type = "Scope"},
        @{PermissionID = "37730810-e9ba-4e46-b07e-8ca78d182097"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.Read.IdentityProtection"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d146432f-b803-4ed4-8d42-ba74193a6ede"; Type = "Scope"},
        @{PermissionID = "b21b72f6-4e6a-4533-9112-47eea9f97b28"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.Read.PermissionGrant"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "414de6ea-2d92-462f-b120-6e2a809a6d01"; Type = "Scope"},
        @{PermissionID = "9e640839-a198-48fb-8b9a-013fd6f6cbcd"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.AccessReview"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4f5bc9c8-ea54-4772-973a-9ca119cb0409"; Type = "Scope"},
        @{PermissionID = "77c863fd-06c0-47ce-a7eb-49773e89d319"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.ApplicationConfiguration"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b27add92-efb2-4f16-84f5-8108ba77985c"; Type = "Scope"},
        @{PermissionID = "be74164b-cff1-491c-8741-e671cb536e13"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.AuthenticationFlows"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "edb72de9-4252-4d03-a925-451deef99db7"; Type = "Scope"},
        @{PermissionID = "25f85f3c-f66c-4205-8cd5-de92dd7f0cec"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.AuthenticationMethod"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7e823077-d88e-468f-a337-e18f1f0e6c7c"; Type = "Scope"},
        @{PermissionID = "29c18626-4985-4dcd-85c0-193eef327366"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.Authorization"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "edd3c878-b384-41fd-95ad-e7407dd775be"; Type = "Scope"},
        @{PermissionID = "fb221be6-99f2-473f-bd32-01c6a0e9ca3b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.ConditionalAccess"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ad902697-1014-4ef5-81ef-2b4301988e8c"; Type = "Scope"},
        @{PermissionID = "01c0a623-fc9b-48e9-b794-0756f8e8f067"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.ConsentRequest"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4d135e65-66b8-41a8-9f8b-081452c91774"; Type = "Scope"},
        @{PermissionID = "999f8c63-0a38-4f1b-91fd-ed1947bdd1a9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.CrossTenantAccess"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "014b43d0-6ed4-4fc6-84dc-4b6f7bae7d85"; Type = "Scope"},
        @{PermissionID = "338163d7-f101-4c92-94ba-ca46fe52447c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.DeviceConfiguration"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "40b534c3-9552-4550-901b-23879c90bcf9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.ExternalIdentities"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b5219784-1215-45b5-b3f1-88fe1081f9c0"; Type = "Scope"},
        @{PermissionID = "03cc4f92-788e-4ede-b93f-199424d144a5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.FeatureRollout"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "92a38652-f13b-4875-bc77-6e1dbb63e1b2"; Type = "Scope"},
        @{PermissionID = "2044e4f1-e56c-435b-925c-44cd8f6ba89a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.FedTokenValidation"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "be1be369-4540-4ac9-8928-79de99f70d8f"; Type = "Scope"},
        @{PermissionID = "90bbca0b-227c-4cdc-8083-1c6cfb95bac6"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.IdentityProtection"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7256e131-3efb-4323-9854-cf41c6021770"; Type = "Scope"},
        @{PermissionID = "2dcf8603-09eb-4078-b1ec-d30a1a76b873"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.MobilityManagement"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a8ead177-1889-4546-9387-f25e658e2a79"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.PermissionGrant"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2672f8bb-fd5e-42e0-85e1-ec764dd2614e"; Type = "Scope"},
        @{PermissionID = "a402ca1c-2696-4531-972d-6e5ee4aa11ea"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.SecurityDefaults"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0b2a744c-2abf-4f1e-ad7e-17a087e2be99"; Type = "Scope"},
        @{PermissionID = "1c6e93a6-28e2-4cbb-9f64-1a46a821124d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.TrustFramework"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cefba324-1a70-4a6e-9c1d-fd670b7ae392"; Type = "Scope"},
        @{PermissionID = "79a677f7-b79d-40d0-a36a-3e6f8688dd7a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/POP.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d7b7f2d9-0f45-4ea1-9d42-e50810c06991"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Presence.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "76bc735e-aecd-4a1d-8b4c-2b915deabb79"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Presence.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9c7a330d-35b3-4aa1-963d-cb2b9f927841"; Type = "Scope"},
        @{PermissionID = "a70e0c2d-e793-494c-94c4-118fa0a67f42"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Presence.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8d3c54a7-cf58-4773-bf81-c0cd6ad522bb"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Presence.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "83cded22-8297-4ff6-a7fa-e97e9545a259"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintConnector.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d69c2d6d-4f72-4f99-a6b9-663e32f8cf68"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintConnector.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "79ef9967-7d59-4213-9c64-4b10687637d8"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Printer.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "90c30bed-6fd1-4279-bf39-714069619721"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Printer.FullControl.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "93dae4bd-43a1-4a23-9a1a-92957e1d9121"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Printer.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3a736c8a-018e-460a-b60c-863b2683e8bf"; Type = "Scope"},
        @{PermissionID = "9709bb33-4549-49d4-8ed9-a8f65e45bb0f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Printer.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "89f66824-725f-4b8f-928e-e1c5258dc565"; Type = "Scope"},
        @{PermissionID = "f5b3f73d-6247-44df-a74c-866173fddab0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrinterShare.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ed11134d-2f3f-440d-a2e1-411efada2502"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrinterShare.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5fa075e9-b951-4165-947b-c63396ff0a37"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrinterShare.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "06ceea37-85e2-40d7-bec3-91337a46038f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "21f0d9c0-9f13-48b3-94e0-b6b231c7d320"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.Manage.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "58a52f47-9e36-4b17-9ebe-ce4ef7f3e6c8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "248f5528-65c0-4c88-8326-876c7236df5e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "afdd6933-a0d8-40f7-bd1a-b5d778e8624b"; Type = "Scope"},
        @{PermissionID = "ac6f956c-edea-44e4-bd06-64b1b4b9aec9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6a71a747-280f-4670-9ca0-a9cbf882b274"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "04ce8d60-72ce-4867-85cf-6d82f36922f3"; Type = "Scope"},
        @{PermissionID = "fbf67eee-e074-4ef7-b965-ab5ce1c1f689"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b81dd597-8abb-4b3f-a07a-820b0316ed04"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "036b9544-e8c5-46ef-900a-0646cc42b271"; Type = "Scope"},
        @{PermissionID = "5114b07b-2898-4de7-a541-53b0004e2e13"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.ReadWriteBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6f2d22f2-1cb6-412c-a17c-3336817eaa82"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintJob.ReadWriteBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3a0db2f6-0d2a-4c19-971b-49109b19ad3d"; Type = "Scope"},
        @{PermissionID = "57878358-37f4-4d3a-8c20-4816e0d457b1"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "490f32fd-d90f-4dd7-a601-ff6cdc1a3f6c"; Type = "Scope"},
        @{PermissionID = "b5991872-94cf-4652-9765-29535087c6d8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9ccc526a-c51c-4e5c-a1fd-74726ef50b8f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrintTaskDefinition.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "456b71a7-0ee0-4588-9842-c123fcc8f664"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedAccess.Read.AzureAD"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b3a539c9-59cb-4ad5-825a-041ddbdc2bdb"; Type = "Scope"},
        @{PermissionID = "4cdc2547-9148-4295-8d11-be0db1391d6b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedAccess.Read.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d329c81c-20ad-4772-abf9-3f6fdb7e5988"; Type = "Scope"},
        @{PermissionID = "01e37dc9-c035-40bd-b438-b2879c4870a6"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedAccess.Read.AzureResources"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1d89d70c-dcac-4248-b214-903c457af83a"; Type = "Scope"},
        @{PermissionID = "5df6fe86-1be0-44eb-b916-7bd443a71236"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedAccess.ReadWrite.AzureAD"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3c3c74f5-cdaa-4a97-b7e0-4e788bfcfb37"; Type = "Scope"},
        @{PermissionID = "854d9ab1-6657-4ec8-be45-823027bcd009"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedAccess.ReadWrite.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "32531c59-1f32-461f-b8df-6f8a3b89f73b"; Type = "Scope"},
        @{PermissionID = "2f6817f8-7b12-4f0f-bc18-eeaf60705a9e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedAccess.ReadWrite.AzureResources"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a84a9652-ffd3-496e-a991-22ba5529156a"; Type = "Scope"},
        @{PermissionID = "6f9d5abc-2db6-400b-a267-7de22a40fb87"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedAssignmentSchedule.Read.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "02a32cc4-7ab5-4b58-879a-0586e0f7c495"; Type = "Scope"},
        @{PermissionID = "cd4161cb-f098-48f8-a884-1eda9a42434c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedAssignmentSchedule.ReadWrite.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "06dbc45d-6708-4ef0-a797-f797ee68bf4b"; Type = "Scope"},
        @{PermissionID = "41202f2c-f7ab-45be-b001-85c9728b9d69"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedEligibilitySchedule.Read.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8f44f93d-ecef-46ae-a9bf-338508d44d6b"; Type = "Scope"},
        @{PermissionID = "edb419d6-7edc-42a3-9345-509bfdf5d87c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/PrivilegedEligibilitySchedule.ReadWrite.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba974594-d163-484e-ba39-c330d5897667"; Type = "Scope"},
        @{PermissionID = "618b6020-bca8-4de6-99f6-ef445fa4d857"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/profile"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "14dad69e-099b-42c9-810b-d002981feec1"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ProgramControl.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c492a2e1-2f8f-4caa-b076-99bbf6e40fe4"; Type = "Scope"},
        @{PermissionID = "eedb7fdd-7539-4345-a38b-4839e4a84cbd"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ProgramControl.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "50fd364f-9d93-4ae1-b170-300e87cccf84"; Type = "Scope"},
        @{PermissionID = "60a901ed-09f7-4aa5-a16e-7dd3d6f9de36"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/QnA.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f73fa04f-b9a5-4df9-8843-993ce928925e"; Type = "Scope"},
        @{PermissionID = "ee49e170-1dd1-4030-b44c-61ad6e98f743"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RecordsManagement.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "07f995eb-fc67-4522-ad66-2b8ca8ea3efd"; Type = "Scope"},
        @{PermissionID = "ac3a2b8e-03a3-4da9-9ce0-cbe28bf1accd"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RecordsManagement.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f2833d75-a4e6-40ab-86d4-6dfe73c97605"; Type = "Scope"},
        @{PermissionID = "eb158f57-df43-4751-8b21-b8932adb3d34"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Reports.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "02e97553-ed7b-43d0-ab3c-f8bace0d040c"; Type = "Scope"},
        @{PermissionID = "230c1aed-a721-4c5d-9cb4-a90514e508ef"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ReportSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "84fac5f4-33a9-4100-aa38-a20c6d29e5e7"; Type = "Scope"},
        @{PermissionID = "ee353f83-55ef-4b78-82da-555bfa2b4b95"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ReportSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b955410e-7715-4a88-a940-dfd551018df3"; Type = "Scope"},
        @{PermissionID = "2a60023f-3219-47ad-baa4-40e17cd02a1d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ResourceSpecificPermissionGrant.ReadForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f1d91a8f-88e7-4774-8401-b668d5bca0c5"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ResourceSpecificPermissionGrant.ReadForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "acfca4d5-f49f-40ed-9648-84068b474c73"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleAssignmentSchedule.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "344a729c-0285-42c6-9014-f12b9b8d6129"; Type = "Scope"},
        @{PermissionID = "d5fe8ce8-684c-4c83-a52c-46e882ce4be1"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleAssignmentSchedule.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8c026be3-8e26-4774-9372-8d5d6f21daff"; Type = "Scope"},
        @{PermissionID = "dd199f4a-f148-40a4-a2ec-f0069cc799ec"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleEligibilitySchedule.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "eb0788c2-6d4e-4658-8c9e-c0fb8053f03d"; Type = "Scope"},
        @{PermissionID = "ff278e11-4a33-4d0c-83d2-d01dc58929a5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleEligibilitySchedule.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "62ade113-f8e0-4bf9-a6ba-5acb31db32fd"; Type = "Scope"},
        @{PermissionID = "fee28b28-e1f3-4841-818e-2704dc62245f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagement.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "48fec646-b2ba-4019-8681-8eb31435aded"; Type = "Scope"},
        @{PermissionID = "c7fbd983-d9aa-4fa7-84b8-17382c103bc4"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagement.Read.CloudPC"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9619b88a-8a25-48a7-9571-d23be0337a79"; Type = "Scope"},
        @{PermissionID = "031a549a-bb80-49b6-8032-2068448c6a3c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagement.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "741c54c3-0c1e-44a1-818b-3f97ab4e8c83"; Type = "Scope"},
        @{PermissionID = "483bed4a-2ad3-4361-a73b-c83ccdbdc53c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagement.Read.Exchange"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3bc15058-7858-4141-b24f-ae43b4e80b52"; Type = "Scope"},
        @{PermissionID = "c769435f-f061-4d0b-8ff1-3d39870e5f85"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagement.ReadWrite.CloudPC"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "501d06f8-07b8-4f18-b5c6-c191a4af7a82"; Type = "Scope"},
        @{PermissionID = "274d0592-d1b6-44bd-af1d-26d259bcb43a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagement.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d01b97e9-cbc0-49fe-810a-750afd5527a3"; Type = "Scope"},
        @{PermissionID = "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagement.ReadWrite.Exchange"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c1499fe0-52b1-4b22-bed2-7a244e0e879f"; Type = "Scope"},
        @{PermissionID = "025d3225-3f02-4882-b4c0-cd5b541a4e80"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagementAlert.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cce71173-f76d-446e-97ff-efb2d82e11b1"; Type = "Scope"},
        @{PermissionID = "ef31918f-2d50-4755-8943-b8638c0a077e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagementAlert.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "435644c6-a5b1-40bf-8f52-fe8e5b53e19c"; Type = "Scope"},
        @{PermissionID = "11059518-d6a6-4851-98ed-509268489c4a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagementPolicy.Read.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7e26fdff-9cb1-4e56-bede-211fe0e420e8"; Type = "Scope"},
        @{PermissionID = "69e67828-780e-47fd-b28c-7b27d14864e6"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagementPolicy.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3de2cdbe-0ff5-47d5-bdee-7f45b4749ead"; Type = "Scope"},
        @{PermissionID = "fdc4c997-9942-4479-bfcb-75a36d1138df"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagementPolicy.ReadWrite.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0da165c7-3f15-4236-b733-c0b0f6abe41d"; Type = "Scope"},
        @{PermissionID = "b38dcc4d-a239-4ed6-aa84-6c65b284f97c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/RoleManagementPolicy.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1ff1be21-34eb-448c-9ac9-ce1f506b2a68"; Type = "Scope"},
        @{PermissionID = "31e08e0a-d3f7-4ca2-ac39-7343fb83e8ad"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Schedule.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "fccf6dd8-5706-49fa-811f-69e2e1b585d0"; Type = "Scope"},
        @{PermissionID = "7b2ebf90-d836-437f-b90d-7b62722c4456"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Schedule.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "63f27281-c9d9-4f29-94dd-6942f7f1feb0"; Type = "Scope"},
        @{PermissionID = "b7760610-0545-4e8a-9ec3-cce9e63db01c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SchedulePermissions.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "07919803-6073-4cd8-bc55-28077db0ee10"; Type = "Scope"},
        @{PermissionID = "7239b71d-b402-4150-b13d-78ecfe8df441"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SearchConfiguration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7d307522-aa38-4cd0-bd60-90c6f0ac50bd"; Type = "Scope"},
        @{PermissionID = "ada977a5-b8b1-493b-9a91-66c206d76ecf"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SearchConfiguration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b1a7d408-cab0-47d2-a2a5-a74a3733600d"; Type = "Scope"},
        @{PermissionID = "0e778b85-fefa-466d-9eec-750569d92122"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityActions.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1638cddf-07a4-4de2-8645-69c96cacad73"; Type = "Scope"},
        @{PermissionID = "5e0edab9-c148-49d0-b423-ac253e121825"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityActions.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dc38509c-b87d-4da0-bd92-6bec988bac4a"; Type = "Scope"},
        @{PermissionID = "f2bf083f-0179-402a-bedb-b2784de8a49b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityAlert.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bc257fb8-46b4-4b15-8713-01e91bfbe4ea"; Type = "Scope"},
        @{PermissionID = "472e4a4d-bb4a-4026-98d1-0b0d74cb74a5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityAlert.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "471f2a7f-2a42-4d45-a2bf-594d0838070d"; Type = "Scope"},
        @{PermissionID = "ed4fca05-be46-441f-9803-1873825f8fdb"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityAnalyzedMessage.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "53e6783e-b127-4a35-ab3a-6a52d80a9077"; Type = "Scope"},
        @{PermissionID = "b48f7ac2-044d-4281-b02f-75db744d6f5f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityAnalyzedMessage.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "48eb8c83-6e58-46e7-a6d3-8805822f5940"; Type = "Scope"},
        @{PermissionID = "04c55753-2244-4c25-87fc-704ab82a4f69"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityEvents.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "64733abd-851e-478a-bffb-e47a14b18235"; Type = "Scope"},
        @{PermissionID = "bf394140-e372-4bf9-a898-299cfc7564e5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityEvents.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6aedf524-7e1c-45a7-bd76-ded8cab8d0fc"; Type = "Scope"},
        @{PermissionID = "d903a879-88e0-4c09-b0c9-82f6a1333f84"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityIdentitiesHealth.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a0d0da43-a6df-4416-b63d-99c79991aae8"; Type = "Scope"},
        @{PermissionID = "f8dcd971-5d83-4e1e-aa95-ef44611ad351"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityIdentitiesHealth.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "53e51eec-2d9b-4990-97f3-c9aa5d5652c3"; Type = "Scope"},
        @{PermissionID = "ab03ddd5-7ae4-4f2e-8af8-86654f7e0a27"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityIncident.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b9abcc4f-94fc-4457-9141-d20ce80ec952"; Type = "Scope"},
        @{PermissionID = "45cc0394-e837-488b-a098-1918f48d186c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SecurityIncident.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "128ca929-1a19-45e6-a3b8-435ec44a36ba"; Type = "Scope"},
        @{PermissionID = "34bf0e97-1971-4929-b999-9e2442d941d7"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ServiceActivity-Exchange.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1fe7aa48-9373-4a47-8df3-168335e0f4c9"; Type = "Scope"},
        @{PermissionID = "2b655018-450a-4845-81e7-d603b1ebffdb"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ServiceActivity-Microsoft365Web.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d74c75b1-d5a9-479d-902d-92f8f99182c1"; Type = "Scope"},
        @{PermissionID = "c766cb16-acc4-4663-ba09-6eedef5876c5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ServiceActivity-OneDrive.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "347e3c16-30f3-4ac7-9b52-fc3c053de9c9"; Type = "Scope"},
        @{PermissionID = "57b4f899-b8c5-47c7-bdd3-c410c55602b7"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ServiceActivity-Teams.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "404d76f0-e10e-460a-92be-ef19600c54d1"; Type = "Scope"},
        @{PermissionID = "4dfee10b-fa4a-41b5-b34d-ccf54cc0c394"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ServiceHealth.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "55896846-df78-47a7-aa94-8d3d4442ca7f"; Type = "Scope"},
        @{PermissionID = "79c261e0-fe76-4144-aad5-bdc68fbe4037"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ServiceMessage.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "eda39fa6-f8cf-4c3c-a909-432c683e4c9b"; Type = "Scope"},
        @{PermissionID = "1b620472-6534-4fe6-9df2-4680e8aa28ec"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ServiceMessageViewpoint.Write"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "636e1b0b-1cc2-4b1c-9aa9-4eeed9b9761b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ServicePrincipalEndpoint.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9f9ce928-e038-4e3b-8faf-7b59049a8ddc"; Type = "Scope"},
        @{PermissionID = "5256681e-b7f6-40c0-8447-2d9db68797a0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ServicePrincipalEndpoint.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7297d82c-9546-4aed-91df-3d4f0a9b3ff0"; Type = "Scope"},
        @{PermissionID = "89c8469c-83ad-45f7-8ff2-6e3d4285709e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SharePointTenantSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2ef70e10-5bfd-4ede-a5f6-67720500b258"; Type = "Scope"},
        @{PermissionID = "83d4163d-a2d8-4d3b-9695-4ae3ca98f888"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SharePointTenantSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "aa07f155-3612-49b8-a147-6c590df35536"; Type = "Scope"},
        @{PermissionID = "19b94e34-907c-4f43-bde9-38b1909ed408"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ShortNotes.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "50f66e47-eb56-45b7-aaa2-75057d9afe08"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ShortNotes.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "0c7d31ec-31ca-4f58-b6ec-9950b6b0de69"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ShortNotes.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "328438b7-4c01-4c07-a840-e625a749bb89"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ShortNotes.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "842c284c-763d-4a97-838d-79787d129bab"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Sites.FullControl.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5a54b8b3-347c-476d-8f8e-42d5c7424d29"; Type = "Scope"},
        @{PermissionID = "a82116e5-55eb-4c41-a434-62fe8a61c773"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Sites.Manage.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "65e50fdc-43b7-4915-933e-e8138f11f40a"; Type = "Scope"},
        @{PermissionID = "0c0bf378-bf22-4481-8f81-9e89a9b4960a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Sites.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "205e70e5-aba6-4c52-a976-6d2d46c48043"; Type = "Scope"},
        @{PermissionID = "332a536c-c7ef-4017-ab91-336970924f0d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Sites.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "89fe6a52-be36-487e-b7d8-d061c450a026"; Type = "Scope"},
        @{PermissionID = "9492366f-7969-46a4-8d15-ed1a20078fff"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Sites.Selected"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f89c84ef-20d0-4b54-87e9-02e856d66d53"; Type = "Scope"},
        @{PermissionID = "883ea226-0bf2-4a8f-9f9d-92c9162a727d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SMTP.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "258f6531-6087-4cc4-bb90-092c5fb3ed3f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SpiffeTrustDomain.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9b4aa4b1-aaf3-41b7-b743-698b27e77ff6"; Type = "Scope"},
        @{PermissionID = "dcdfc277-41fd-4d68-ad0c-c3057235bd8e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SpiffeTrustDomain.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8ba47079-8c47-4bfe-b2ce-13f28ef37247"; Type = "Scope"},
        @{PermissionID = "17b78cfd-eeff-447d-8bab-2795af00055a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SubjectRightsRequest.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9c3af74c-fd0f-4db4-b17a-71939e2a9d77"; Type = "Scope"},
        @{PermissionID = "ee1460f0-368b-4153-870a-4e1ca7e72c42"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SubjectRightsRequest.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2b8fcc74-bce1-4ae3-a0e8-60c53739299d"; Type = "Scope"},
        @{PermissionID = "8387eaa4-1a3c-41f5-b261-f888138e6041"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Subscription.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5f88184c-80bb-4d52-9ff2-757288b2e9b7"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Synchronization.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7aa02aeb-824f-4fbe-a3f7-611f751f5b55"; Type = "Scope"},
        @{PermissionID = "5ba43d2f-fa88-4db2-bd1c-a67c5f0fb1ce"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Synchronization.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7bb27fa3-ea8f-4d67-a916-87715b6188bd"; Type = "Scope"},
        @{PermissionID = "9b50c33d-700f-43b1-b2eb-87e89b703581"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/SynchronizationData-User.Upload"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1a2e7420-4e92-4d2b-94cb-fb2952e9ddf7"; Type = "Scope"},
        @{PermissionID = "db31e92a-b9ea-4d87-bf6a-75a37a9ca35a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Tasks.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f45671fb-e0fe-4b4b-be20-3d3ce43f1bcb"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Tasks.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f10e1f91-74ed-437f-a6fd-d6ae88e26c1f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Tasks.Read.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "88d21fd4-8e5a-4c32-b5e2-4a1c95f34f72"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Tasks.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2219042f-cab5-40cc-b0d2-16b1540b4c5f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Tasks.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "44e666d1-d276-445b-a5fc-8815eeb81d55"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Tasks.ReadWrite.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c5ddf11b-c114-4886-8558-8a4e557cd52b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Team.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7825d5d6-6049-4ce7-bdf6-3b8d53f4bcd0"; Type = "Scope"},
        @{PermissionID = "23fc2474-f741-46ce-8465-674744c5c361"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Team.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "485be79e-c497-4b35-9400-0e3fa7f2a5d4"; Type = "Scope"},
        @{PermissionID = "2280dda6-0bfd-44ee-a2f4-cb867cfc4c1e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamMember.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2497278c-d82d-46a2-b1ce-39d4cdde5570"; Type = "Scope"},
        @{PermissionID = "660b7406-55f1-41ca-a0ed-0b035e182f3e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamMember.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4a06efd2-f825-4e34-813e-82a57b03d1ee"; Type = "Scope"},
        @{PermissionID = "0121dc95-1b9f-4aed-8bac-58c5ac466691"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamMember.ReadWriteNonOwnerRole.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2104a4db-3a2f-4ea0-9dba-143d457dc666"; Type = "Scope"},
        @{PermissionID = "4437522e-9a86-4a41-a7da-e380edd4a97d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsActivity.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0e755559-83fb-4b44-91d0-4cc721b9323e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsActivity.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "70dec828-f620-4914-aa83-a29117306807"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsActivity.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7ab1d787-bae7-4d5d-8db6-37ea32df9186"; Type = "Scope"},
        @{PermissionID = "a267235f-af13-44dc-8385-c1dc93023186"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bf3fbf03-f35f-4e93-963e-47e4d874c37a"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "cc7e7635-2586-41d6-adaa-a8d3bcad5ee5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5248dcb1-f83b-4ec3-9f4d-a4428a961a72"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1f615aea-6bf9-4b05-84bd-46388e138537"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c395395c-ff9a-4dba-bc1f-8372ba9dca84"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9ce09611-f4f7-4abd-a629-a05450422a97"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e1408a66-8f82-451b-a2f3-3c3e38f7413f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6e74eff9-4a21-45d6-bc03-3a20f61f8281"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "946349d5-2a9d-4535-abc0-7beeacaedd1d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b0c13be0-8e20-4bc5-8c55-963c23a39ce9"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2da62c49-dfbd-40df-ba16-fef3529d391c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "32ca478f-f89e-41d0-aaf8-101deb7da510"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a0e0e18b-8fb2-458f-8130-da2d7cab9c75"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "ba1ba90b-2d8f-487e-9f16-80728d85bb5c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4a6bbf29-a0e1-4a4d-a7d1-cef17f772975"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1e4be56c-312e-42b8-a2c9-009600d732c0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7a349935-c54d-44ab-ab66-1b460d315be7"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a87076cf-6abd-4e56-8559-4dbdf41bef96"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "aa85bf13-d771-4d5d-a9e6-bca04ce44edf"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9e19bae1-2623-4c4f-ab6e-2664615ff9a0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2e25a044-2580-450d-8859-42eeb6e996c0"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "5dad17ba-f6cc-4954-a5a2-a0dcc95154f0"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "093f8818-d05f-49b8-95bc-9d2a73e9a43c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "74ef0291-ca83-4d02-8c7e-d2391e6a444f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0ce33576-30e8-43b7-99e5-62f8569a4002"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "73a45059-f39c-4baf-9182-4954ac0e55cf"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0f4595f7-64b1-4e13-81bc-11a249df07a9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9f67436c-5415-4e7f-8ac1-3014a7132630"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "207e0cb1-3ce7-4922-b991-5a760c346ebc"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "908de74d-f8b2-4d6b-a9ed-2a17b3b78179"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "48638b3c-ad68-4383-8ac4-e6880ee6ca57"; Type = "Scope"},
        @{PermissionID = "242607bd-1d2c-432c-82eb-bdb27baa23ab"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "39d65650-9d3e-4223-80db-a335590d027e"; Type = "Scope"},
        @{PermissionID = "bdd80a03-d9bc-451d-b7c4-ce7c63fe3c8f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a9ff19c2-f369-4a95-9a25-ba9d460efc8e"; Type = "Scope"},
        @{PermissionID = "49981c42-fd7b-4530-be03-e77b21aed25e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "59dacb05-e88d-4c13-a684-59f1afc8cc98"; Type = "Scope"},
        @{PermissionID = "46890524-499a-4bb2-ad64-1476b4f3e1cf"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b98bfd41-87c6-45cc-b104-e2de4f0dafb9"; Type = "Scope"},
        @{PermissionID = "a96d855f-016b-47d7-b51c-1218a98d791c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ee928332-e9c2-4747-b4a0-f8c164b68de6"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "fd9ce730-a250-40dc-bd44-8dc8d20f39ea"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c975dd04-a06e-4fbb-9704-62daad77bb49"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6163d4f4-fbf8-43da-a7b4-060fe85ed148"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c37c9b61-7762-4bff-a156-afc0005847a0"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "425b4b59-d5af-45c8-832f-bb0b7402348a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0c219d04-3abf-47f7-912d-5cca239e90e6"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9f62e4a2-a2d6-4350-b28b-d244728c4f86"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f266662f-120a-4314-b26a-99b08617c7ef"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "91c32b81-0ef0-453f-a5c7-4ce2e562f449"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "395dfec1-a0b9-465f-a783-8250a430cb8c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "3c42dec6-49e8-4a0a-b469-36cff0d9da93"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamTemplates.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cd87405c-5792-4f15-92f7-debc0db6d1d6"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamTemplates.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6323133e-1f6e-46d4-9372-ac33a0870636"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Teamwork.Migrate.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "dfb0dd15-61de-45b2-be36-d6a69fba3c79"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Teamwork.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "594f4bb6-c083-4cf9-8aa8-213823bdf351"; Type = "Scope"},
        @{PermissionID = "75bcfbce-a647-4fba-ad51-b63d73b210f4"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamworkAppSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "44e060c4-bbdc-4256-a0b9-dcc0396db368"; Type = "Scope"},
        @{PermissionID = "475ebe88-f071-4bd7-af2b-642952bd4986"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamworkAppSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "87c556f0-2bd9-4eed-bd74-5dd8af6eaf7e"; Type = "Scope"},
        @{PermissionID = "ab5b445e-8f10-45f4-9c79-dd3f8062cc4e"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamworkDevice.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b659488b-9d28-4208-b2be-1c6652b3c970"; Type = "Scope"},
        @{PermissionID = "0591bafd-7c1c-4c30-a2a5-2b9aacb1dfe8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamworkDevice.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ddd97ecb-5c31-43db-a235-0ee20e635c40"; Type = "Scope"},
        @{PermissionID = "79c02f5b-bd4f-4713-bc2c-a8a4a66e127b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamworkTag.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "57587d0b-8399-45be-b207-8050cec54575"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamworkTag.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b74fd6c4-4bde-488e-9695-eeb100e4907f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamworkTag.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "539dabd7-b5b6-4117-b164-d60cd15a8671"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamworkTag.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a3371ca5-911d-46d6-901c-42c8c7a937d8"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TeamworkUserInteraction.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b4d26916-07e0-4daf-9096-9f6d9174aa96"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TermStore.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "297f747b-0005-475b-8fef-c890f5152b38"; Type = "Scope"},
        @{PermissionID = "ea047cc2-df29-4f3e-83a3-205de61501ca"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TermStore.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6c37c71d-f50f-4bff-8fd3-8a41da390140"; Type = "Scope"},
        @{PermissionID = "f12eb8d6-28e3-46e6-b2c0-b7e4dc69fc95"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatAssessment.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f8f035bb-2cce-47fb-8bf5-7baf3ecbee48"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatAssessment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cac97e40-6730-457d-ad8d-4852fddab7ad"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatHunting.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b152eca8-ea73-4a48-8c98-1a6742673d99"; Type = "Scope"},
        @{PermissionID = "dd98c7f5-2d42-42d3-a0e4-633161547251"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatIndicators.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9cc427b4-2004-41c5-aa22-757b755e9796"; Type = "Scope"},
        @{PermissionID = "197ee4e9-b993-4066-898f-d6aecc55125b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatIndicators.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "91e7d36d-022a-490f-a748-f8e011357b42"; Type = "Scope"},
        @{PermissionID = "21792b6c-c986-4ffc-85de-df9da54b52fa"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatIntelligence.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f266d9c0-ccb9-4fb8-a228-01ac0d8d6627"; Type = "Scope"},
        @{PermissionID = "e0b77adb-e790-44a3-b0a0-257d06303687"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatSubmission.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "fd5353c6-26dd-449f-a565-c4e16b9fce78"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatSubmission.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7083913a-4966-44b6-9886-c5822a5fd910"; Type = "Scope"},
        @{PermissionID = "86632667-cd15-4845-ad89-48a88e8412e1"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatSubmission.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "68a3156e-46c9-443c-b85c-921397f082b5"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatSubmission.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8458e264-4eb9-4922-abe9-768d58f13c7f"; Type = "Scope"},
        @{PermissionID = "d72bdbf4-a59b-405c-8b04-5995895819ac"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/ThreatSubmissionPolicy.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "059e5840-5353-4c68-b1da-666a033fc5e8"; Type = "Scope"},
        @{PermissionID = "926a6798-b100-4a20-a22f-a4918f13951d"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/Topic.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "79c4c76f-409a-4f98-884d-e2c09291ec26"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TrustFrameworkKeySet.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7ad34336-f5b1-44ce-8682-31d7dfcd9ab9"; Type = "Scope"},
        @{PermissionID = "fff194f1-7dce-4428-8301-1badb5518201"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/TrustFrameworkKeySet.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "39244520-1e7d-4b4a-aee0-57c65826e427"; Type = "Scope"},
        @{PermissionID = "4a771c9a-1cf2-4609-b88e-3d3e02d539cd"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UnifiedGroupMember.Read.AsGuest"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "73e75199-7c3e-41bb-9357-167164dbb415"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User.EnableDisableAccount.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f92e74e7-2563-467f-9dd0-902688cb5863"; Type = "Scope"},
        @{PermissionID = "3011c876-62b7-4ada-afa2-506cbbecc68c"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User.Export.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "405a51b5-8d8d-430b-9842-8be4b0e9f324"; Type = "Scope"},
        @{PermissionID = "405a51b5-8d8d-430b-9842-8be4b0e9f324"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User.Invite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "63dd7cd9-b489-4adf-a28c-ac38b9a0f962"; Type = "Scope"},
        @{PermissionID = "09850681-111b-4a89-9bed-3f2cae46d706"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User.ManageIdentities.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "637d7bec-b31e-4deb-acc9-24275642a2c9"; Type = "Scope"},
        @{PermissionID = "c529cfca-c91b-489c-af2b-d92990b66ce6"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a154be20-db9c-4678-8ab7-66f6cc099a59"; Type = "Scope"},
        @{PermissionID = "df021288-bdef-4463-88db-98f22de89214"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b340eb25-3456-403f-be2f-af7a0d370277"; Type = "Scope"},
        @{PermissionID = "97235f07-e226-4f63-ace3-39588e11d3a1"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b4e74841-8e56-480b-be8b-910348b18b4c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "204e0828-b5ca-4ad8-b9f3-f32a958e7cc4"; Type = "Scope"},
        @{PermissionID = "741f803b-c850-494e-b5df-cde7c675a1ca"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserActivity.ReadWrite.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "47607519-5fb1-47d9-99c7-da4b48f369b1"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserAuthenticationMethod.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1f6b61c5-2f65-4135-9c9f-31c0f8d32b52"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserAuthenticationMethod.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "aec28ec7-4d02-4e8c-b864-50163aea77eb"; Type = "Scope"},
        @{PermissionID = "38d9df27-64da-44fd-b7c5-a6fbac20248f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserAuthenticationMethod.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "48971fc1-70d7-4245-af77-0beb29b53ee2"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserAuthenticationMethod.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b7887744-6746-4312-813d-72daeaee7e2d"; Type = "Scope"},
        @{PermissionID = "50483e42-d915-4231-9639-7fdb7fd190e5"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User-ConvertToInternal.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "550e695c-7511-40f4-ac79-e8fb9c82552d"; Type = "Scope"},
        @{PermissionID = "9d952b72-f741-4b40-9185-8c53076c2339"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User-LifeCycleInfo.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ed8d2a04-0374-41f1-aefe-da8ac87ccc87"; Type = "Scope"},
        @{PermissionID = "8556a004-db57-4d7a-8b82-97a13428e96f"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/User-LifeCycleInfo.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7ee7473e-bd4b-4c9f-987c-bd58481f5fa2"; Type = "Scope"},
        @{PermissionID = "925f1248-0f97-47b9-8ec8-538c54e01325"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserNotification.ReadWrite.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "26e2f3e8-b2a1-47fc-9620-89bb5b042024"; Type = "Scope"},
        @{PermissionID = "4e774092-a092-48d1-90bd-baad67c7eb47"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserShiftPreferences.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "de023814-96df-4f53-9376-1e2891ef5a18"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserShiftPreferences.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "d1eec298-80f3-49b0-9efb-d90e224798ac"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserTeamwork.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "834bcc1c-762f-41b0-bb91-1cdc323ee4bf"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserTeamwork.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "fbcd7ef1-df0d-4e05-bb28-93424a89c6df"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/UserTimelineActivity.Write.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "367492fc-594d-4972-a9b5-0d58c622c91c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/VirtualAppointment.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "27470298-d3b8-4b9c-aad4-6334312a3eac"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/VirtualAppointment.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "d4f67ec2-59b5-4bdc-b4af-d78f6f9c1954"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/VirtualAppointment.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2ccc2926-a528-4b17-b8bb-860eed29d64c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/VirtualAppointment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "bf46a256-f47d-448f-ab78-f226fff08d40"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/VirtualAppointmentNotification.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "20d02fff-a0ef-49e7-a46e-019d4a6523b7"; Type = "Scope"},
        @{PermissionID = "97e45b36-1250-48e4-bd70-2df6dab7e94a"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/VirtualEvent.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6b616635-ae58-433a-a918-8c45e4f304dc"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/VirtualEvent.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1dccb351-c4e4-4e09-a8d1-7a9ecbf027cc"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/VirtualEvent.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d38d189c-e29b-4344-8b3b-829bfa81380b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/VirtualEventRegistration-Anon.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "23211fc1-f9d1-4e8e-8e9e-08a5d0a109bb"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/WindowsUpdates.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "11776c0c-6138-4db3-a668-ee621bea2555"; Type = "Scope"},
        @{PermissionID = "7dd1be58-6e76-4401-bf8d-31d1e8180d5b"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/WorkforceIntegration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f1ccd5a7-6383-466a-8db8-1a656f7d06fa"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/WorkforceIntegration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "08c4b377-0d23-4a8b-be2a-23c1c1d88545"; Type = "Scope"},
        @{PermissionID = "202bf709-e8e6-478e-bcfd-5d63c50b68e3"; Type = "Role"}
        )
    }
   $APIDefs += @{
    Name = "https://graph.microsoft.com/In this article"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "08c4b377-0d23-4a8b-be2a-23c1c1d88545"; Type = "Scope"},
        @{PermissionID = "202bf709-e8e6-478e-bcfd-5d63c50b68e3"; Type = "Role"}
        )
    }
    #>

    
$APIDefs = @(
   @{
    Name = "https://graph.microsoft.com/AccessReview.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ebfcd32b-babb-40f4-a14b-42706e83bd28"; Type = "Scope"},
        @{PermissionID = "d07a8cc0-3d51-4b77-b3b0-32704d1f69fa"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AccessReview.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e4aa47b9-9a69-4109-82ed-36ec70d85ff1"; Type = "Scope"},
        @{PermissionID = "ef5f7d5c-338f-44b0-86c3-351f46c8bb5f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AccessReview.ReadWrite.Membership"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5af8c3f5-baca-439a-97b0-ea58a435e269"; Type = "Scope"},
        @{PermissionID = "18228521-a591-40f1-b215-5fad4488c117"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Acronym.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9084c10f-a2d6-4713-8732-348def50fe02"; Type = "Scope"},
        @{PermissionID = "8c0aed2c-0c61-433d-b63c-6370ddc73248"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AdministrativeUnit.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3361d15d-be43-4de6-b441-3c746d05163d"; Type = "Scope"},
        @{PermissionID = "134fd756-38ce-4afd-ba33-e9623dbe66c2"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AdministrativeUnit.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7b8a2d34-6b3f-4542-a343-54651608ad81"; Type = "Scope"},
        @{PermissionID = "5eb59dd3-1da2-4329-8733-9dabdc435916"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Agreement.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "af2819c9-df71-4dd3-ade7-4d7c9dc653b7"; Type = "Scope"},
        @{PermissionID = "2f3e6f8c-093b-4c57-a58b-ba5ce494a169"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Agreement.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ef4b5d93-3104-4664-9053-a5c49ab44218"; Type = "Scope"},
        @{PermissionID = "c9090d00-6101-42f0-a729-c41074260d47"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AgreementAcceptance.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0b7643bb-5336-476f-80b5-18fbfbc91806"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AgreementAcceptance.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a66a5341-e66e-4897-9d52-c2df58c2bfb9"; Type = "Scope"},
        @{PermissionID = "d8e4ec18-f6c0-4620-8122-c8b1f2bf400e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Analytics.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e03cf23f-8056-446a-8994-7d93dfc8b50e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/APIConnectors.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1b6ff35f-31df-4332-8571-d31ea5a4893f"; Type = "Scope"},
        @{PermissionID = "b86848a7-d5b1-41eb-a9b4-54a4e6306e97"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/APIConnectors.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c67b52c5-7c69-48b6-9d48-7b3af3ded914"; Type = "Scope"},
        @{PermissionID = "1dfe531a-24a6-4f1b-80f4-7a0dc5a0a171"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AppCatalog.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "88e58d74-d3df-44f3-ad47-e89edf4472e4"; Type = "Scope"},
        @{PermissionID = "e12dae10-5a57-4817-b79d-dfbec5348930"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AppCatalog.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1ca167d5-1655-44a1-8adf-1414072e1ef9"; Type = "Scope"},
        @{PermissionID = "dc149144-f292-421e-b185-5953f2e98d7f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AppCatalog.Submit"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3db89e36-7fa6-4012-b281-85f3d9d9fd2e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AppCertTrustConfiguration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "af281d3a-030d-4122-886e-146fb30a0413"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AppCertTrustConfiguration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4bae2ed4-473e-4841-a493-9829cfd51d48"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Application.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c79f8feb-a9db-4090-85f9-90d820caa0eb"; Type = "Scope"},
        @{PermissionID = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Application.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bdfbf15f-ee85-4955-8675-146e8e5296b5"; Type = "Scope"},
        @{PermissionID = "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Application.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "18a4783c-866b-4cc7-a460-3d5e5662c884"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Application-RemoteDesktopConfig.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ffa91d43-2ad8-45cc-b592-09caddeb24bb"; Type = "Scope"},
        @{PermissionID = "3be0012a-cc4e-426b-895b-f9c836bf6381"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AppRoleAssignment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "84bccea3-f856-4a8a-967b-dbe0a3d53a64"; Type = "Scope"},
        @{PermissionID = "06b708a9-e830-4db3-a914-8e69da51d44f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AttackSimulation.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "104a7a4b-ca76-4677-b7e7-2f4bc482f381"; Type = "Scope"},
        @{PermissionID = "93283d0a-6322-4fa8-966b-8c121624760d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AttackSimulation.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "27608d7c-2c66-4cad-a657-951d575f5a60"; Type = "Scope"},
        @{PermissionID = "e125258e-8c8a-42a8-8f55-ab502afa52f3"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuditLog.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e4c9e354-4dc5-45b8-9e7c-e1393b0b1a20"; Type = "Scope"},
        @{PermissionID = "b0afded3-3588-46d8-8b3d-9842eff778da"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuditLogsQuery.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1d9e7ac3-0eca-442c-82f9-e92625af6e6d"; Type = "Scope"},
        @{PermissionID = "5e1e9171-754d-478c-812c-f1755a9a4c2d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuditLogsQuery-CRM.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba78b16f-1e01-41b6-89ca-73e0a32b304c"; Type = "Scope"},
        @{PermissionID = "20e6f8e4-ffac-4cf7-82f7-70ddb7564318"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuditLogsQuery-Endpoint.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ee3409fe-617f-43cf-bd1e-fc8b38049e69"; Type = "Scope"},
        @{PermissionID = "0bc85aed-7b0b-437a-bac8-3b29a1b84c99"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuditLogsQuery-Entra.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5ff2f415-e0f1-4d11-bfd0-6d87c0f667fd"; Type = "Scope"},
        @{PermissionID = "7276d950-48fc-4269-8348-f22f2bb296d0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuditLogsQuery-Exchange.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6c8c71d2-c7e1-45b0-ac6d-1d2724fba6ae"; Type = "Scope"},
        @{PermissionID = "6b0d2622-d34e-4470-935b-b96550e5ca8d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuditLogsQuery-OneDrive.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4a72c235-a50d-4870-b598-fd88fd1fa074"; Type = "Scope"},
        @{PermissionID = "8a169a81-841c-45fd-ad43-96aede8801a0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuditLogsQuery-SharePoint.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "30630b65-ed12-4a81-9130-e3a964109fae"; Type = "Scope"},
        @{PermissionID = "91c64a47-a524-4fce-9bf3-3d569a344ecf"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuthenticationContext.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "57b030f1-8c35-469c-b0d9-e4a077debe70"; Type = "Scope"},
        @{PermissionID = "381f742f-e1f8-4309-b4ab-e3d91ae4c5c1"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/AuthenticationContext.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba6d575a-1344-4516-b777-1404f5593057"; Type = "Scope"},
        @{PermissionID = "a88eef72-fed0-4bf7-a2a9-f19df33f8b83"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BillingConfiguration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2bf6d319-dfca-4c22-9879-f88dcfaee6be"; Type = "Scope"},
        @{PermissionID = "9e8be751-7eee-4c09-bcfd-d64f6b087fd8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BitlockerKey.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b27a61ec-b99c-4d6a-b126-c4375d08ae30"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BitlockerKey.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5a107bfc-4f00-4e1a-b67e-66451267bc68"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Bookings.Manage.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7f36b48e-542f-4d3b-9bcb-8406f0ab9fdb"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Bookings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "33b1df99-4b29-4548-9339-7a7b83eaeebc"; Type = "Scope"},
        @{PermissionID = "6e98f277-b046-4193-a4f2-6bf6a78cd491"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Bookings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "948eb538-f19d-4ec5-9ccc-f059e1ea4c72"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BookingsAppointment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "02a5a114-36a6-46ff-a102-954d89d9ab02"; Type = "Scope"},
        @{PermissionID = "9769393e-5a9f-4302-9e3d-7e018ecb64a7"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Bookmark.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "98b17b35-f3b1-4849-a85f-9f13733002f0"; Type = "Scope"},
        @{PermissionID = "be95e614-8ef3-49eb-8464-1c9503433b86"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BrowserSiteLists.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "fb9be2b7-a7fc-4182-aec1-eda4597c43d5"; Type = "Scope"},
        @{PermissionID = "c5ee1f21-fc7f-4937-9af0-c91648ff9597"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BrowserSiteLists.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "83b34c85-95bf-497b-a04e-b58eca9d49d0"; Type = "Scope"},
        @{PermissionID = "8349ca94-3061-44d5-9bfb-33774ea5e4f9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BusinessScenarioConfig.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d16480b2-e469-4118-846b-d3d177327bee"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BusinessScenarioConfig.Read.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c47e7b6e-d6f1-4be9-9ffd-1e00f3e32892"; Type = "Scope"},
        @{PermissionID = "acc0fc4d-2cd6-4194-8700-1768d8423d86"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BusinessScenarioConfig.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "755e785b-b658-446f-bb22-5a46abd029ea"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BusinessScenarioConfig.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b3b7fcff-b4d4-4230-bf6f-90bd91285395"; Type = "Scope"},
        @{PermissionID = "bbea195a-4c47-4a4f-bff2-cba399e11698"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BusinessScenarioData.Read.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "25b265c4-5d34-4e44-952d-b567f6d3b96d"; Type = "Scope"},
        @{PermissionID = "6c0257fd-cffe-415b-8239-2d0d70fdaa9c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/BusinessScenarioData.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "19932d57-2952-4c60-8634-3655c79fc527"; Type = "Scope"},
        @{PermissionID = "f2d21f22-5d80-499e-91cc-0a8a4ce16f54"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calendars.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "465a38f9-76ea-45b9-9f34-9e8b0d4b0b42"; Type = "Scope"},
        @{PermissionID = "798ee544-9d2d-430c-a058-570e29e34338"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calendars.Read.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2b9c4092-424d-4249-948d-b43879977640"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calendars.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "662d75ba-a364-42ad-adee-f5f880ea4878"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calendars.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "8ba4a692-bc31-4128-9094-475872af8a53"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calendars.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1ec239c2-d7c9-4623-a91a-a9775856bb36"; Type = "Scope"},
        @{PermissionID = "ef54d2bf-783f-4e0f-bca1-3210c0444d99"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calendars.ReadWrite.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "12466101-c9b8-439a-8589-dd09ee67e8e9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CallEvents.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "43431c03-960e-400f-87c6-8f910321dca3"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CallEvents.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1abb026f-7572-49f6-9ddd-ad61cbba181e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CallRecord-PstnCalls.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a2611786-80b3-417e-adaa-707d4261a5f0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CallRecords.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "45bbb07e-7321-4fd7-a8f6-3ff27e6a81c8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calls.AccessMedia.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a7a681dc-756e-4909-b988-f160edc6655f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calls.Initiate.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "284383ee-7f6e-4e40-a2a8-e85dcb029101"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calls.InitiateGroupCall.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "4c277553-8a09-487b-8023-29ee378d8324"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calls.JoinGroupCall.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f6b49018-60ab-4f81-83bd-22caeabfed2d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Calls.JoinGroupCallAsGuest.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "fd7ccf6b-3d28-418b-9701-cd10f5cd2fd4"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Channel.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "101147cf-4178-4455-9d58-02b5c164e759"; Type = "Scope"},
        @{PermissionID = "f3a65bd4-b703-46df-8f7e-0174fea562aa"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Channel.Delete.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cc83893a-e232-4723-b5af-bd0b01bcfe65"; Type = "Scope"},
        @{PermissionID = "6a118a39-1227-45d4-af0c-ea7b40d210bc"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Channel.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9d8982ae-4365-4f57-95e9-d6032a4c0b87"; Type = "Scope"},
        @{PermissionID = "59a6b24b-4225-4393-8165-ebaec5f55d7a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChannelMember.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2eadaff8-0bce-4198-a6b9-2cfc35a30075"; Type = "Scope"},
        @{PermissionID = "3b55498e-47ec-484f-8136-9013221c06a9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChannelMember.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0c3e411a-ce45-4cd1-8f30-f99a3efa7b11"; Type = "Scope"},
        @{PermissionID = "35930dcf-aceb-4bd1-b99a-8ffed403c974"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChannelMessage.Edit"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2b61aa8a-6d36-4b2f-ac7b-f29867937c53"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChannelMessage.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "767156cb-16ae-4d10-8f8b-41b657c8c8c8"; Type = "Scope"},
        @{PermissionID = "7b2449af-6ccd-4f4d-9f78-e550c193f0d1"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChannelMessage.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5922d31f-46c8-4404-9eaf-2117e390a8a4"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChannelMessage.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ebf0f66e-9fb1-49e4-a278-222f76911cf4"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChannelMessage.UpdatePolicyViolation.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "4d02b0cc-d90b-441f-8d82-4fb55c34d6bb"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChannelSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "233e0cf1-dd62-48bc-b65b-b38fe87fcf8e"; Type = "Scope"},
        @{PermissionID = "c97b873f-f59f-49aa-8a0e-52b32d762124"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChannelSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d649fb7c-72b4-4eec-b2b4-b15acf79e378"; Type = "Scope"},
        @{PermissionID = "243cded2-bd16-4fd6-a953-ff8177894c3d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "38826093-1258-4dea-98f0-00003be2b8d0"; Type = "Scope"},
        @{PermissionID = "d9c48af6-9ad9-47ad-82c3-63757137b9af"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.ManageDeletion.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bb64e6fc-6b6d-4752-aea0-dd922dbba588"; Type = "Scope"},
        @{PermissionID = "9c7abde0-eacd-4319-bf9e-35994b1a1717"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f501c180-9344-439a-bca0-6cbf209fd270"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6b7d71aa-70aa-4810-a8d9-5d9fb2830017"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.Read.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1c1b4c8e-3cc7-4c58-8470-9b92c9d5848b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9547fcb5-d03f-419d-9948-5928bbf71b0f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b2e060da-3baf-4687-9611-f4ebc0f0cbde"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.ReadBasic.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "818ba5bd-5b3e-4fe0-bbe6-aa4686669073"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9ff7295e-131b-4d94-90e1-69fde507ac11"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7e9a077b-3711-42b9-b7cb-5fa5f3f7fea7"; Type = "Scope"},
        @{PermissionID = "294ce7c9-31ba-490a-ad7d-97a7d075e4ed"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.ReadWrite.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "ad73ce80-f3cd-40ce-b325-df12c33df713"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Chat.UpdatePolicyViolation.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "7e847308-e030-4183-9899-5235d7270f58"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChatMember.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c5a9e2b1-faf6-41d4-8875-d381aa549b24"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChatMember.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a3410be2-8e48-4f32-8454-c29a7465209d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChatMember.Read.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "93e7c9e4-54c5-4a41-b796-f2a5adaacda7"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChatMember.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dea13482-7ea6-488f-8b98-eb5bbecf033d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChatMember.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "57257249-34ce-4810-a8a2-a03adf0c5693"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChatMember.ReadWrite.WhereInstalled"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "e32c2cd9-0124-4e44-88fc-772cd98afbdb"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChatMessage.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cdcdac3a-fd45-410d-83ef-554db620e5c7"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChatMessage.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b9bb2381-47a4-46cd-aafb-00cb12f68504"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ChatMessage.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "116b7235-7cc6-461e-b163-8e55691d839e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CloudApp-Discovery.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ad46d60e-1027-4b75-af88-7c14ccf43a19"; Type = "Scope"},
        @{PermissionID = "64a59178-dad3-4673-89db-84fdcd622fec"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CloudPC.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5252ec4e-fd40-4d92-8c68-89dd1d3c6110"; Type = "Scope"},
        @{PermissionID = "a9e09520-8ed4-4cde-838e-4fdea192c227"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CloudPC.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9d77138f-f0e2-47ba-ab33-cd246c8b79d1"; Type = "Scope"},
        @{PermissionID = "3b4349e1-8cf5-45a3-95b7-69d1751d3e6a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Community.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "12ae2e92-14b5-47b2-babb-4e890bbedc0a"; Type = "Scope"},
        @{PermissionID = "407f0cce-3212-441f-9f55-3bc91342cf86"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Community.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9e69467d-e0e2-402b-a926-3d796990197f"; Type = "Scope"},
        @{PermissionID = "35d59e32-eab5-4553-9345-abb62b4c703c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ConsentRequest.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f2143d35-9b4b-480d-951c-d083e69eeb2c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ConsentRequest.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5942b2f6-5a7b-40af-aa37-4b6ea5447506"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ConsentRequest.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f3bfad56-966e-4590-a536-82ecf548ac1e"; Type = "Scope"},
        @{PermissionID = "1260ad83-98fb-4785-abbb-d6cc1806fd41"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ConsentRequest.ReadApprove.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e694a3a1-7878-46d8-8c29-3d195f6589f4"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ConsentRequest.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "497d9dfa-3bd1-481a-baab-90895e54568c"; Type = "Scope"},
        @{PermissionID = "9f1b81a7-0223-4428-bfa4-0bcb5535f27d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Contacts.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ff74d97f-43af-4b68-9f2a-b77ee6968c5d"; Type = "Scope"},
        @{PermissionID = "089fe4d0-434a-44c5-8827-41ba8a0b17f5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Contacts.Read.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "242b9d9e-ed24-4d09-9a52-f43769beb9d4"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Contacts.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d56682ec-c09e-4743-aaf4-1a3aac4caa21"; Type = "Scope"},
        @{PermissionID = "6918b873-d17a-4dc1-b314-35f528134491"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Contacts.ReadWrite.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "afb6c84b-06be-49af-80bb-8f3f77004eab"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CrossTenantInformation.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "81594d25-e88e-49cf-ac8c-fecbff49f994"; Type = "Scope"},
        @{PermissionID = "cac88765-0581-4025-9725-5ebc13f729ee"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CrossTenantUserProfileSharing.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cb1ba48f-d22b-4325-a07f-74135a62ee41"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CrossTenantUserProfileSharing.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "759dcd16-3c90-463c-937e-abf89f991c18"; Type = "Scope"},
        @{PermissionID = "8b919d44-6192-4f3d-8a3b-f86f8069ae3c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CrossTenantUserProfileSharing.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "eed0129d-dc60-4f30-8641-daf337a39ffd"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CrossTenantUserProfileSharing.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "64dfa325-cbf8-48e3-938d-51224a0cac01"; Type = "Scope"},
        @{PermissionID = "306785c5-c09b-4ba0-a4ee-023f3da165cb"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomAuthenticationExtension.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b2052569-c98c-4f36-a5fb-43e5c111e6d0"; Type = "Scope"},
        @{PermissionID = "88bb2658-5d9e-454f-aacd-a3933e079526"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomAuthenticationExtension.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8dfcf82f-15d0-43b3-bc78-a958a13a5792"; Type = "Scope"},
        @{PermissionID = "c2667967-7050-4e7e-b059-4cbbb3811d03"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomAuthenticationExtension.Receive.Payload"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "214e810f-fda8-4fd7-a475-29461495eb00"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomDetection.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b13ff42e-f321-4d7d-a462-141c46a1b832"; Type = "Scope"},
        @{PermissionID = "673a007a-9e0f-4c97-b066-3c0164486909"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomDetection.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c34088fb-0649-4714-af0b-bcbfec155897"; Type = "Scope"},
        @{PermissionID = "e0fd9c8d-a12e-4cc9-9827-20c8c3cd6fb8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomSecAttributeAssignment.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b46ffa80-fe3d-4822-9a1a-c200932d54d0"; Type = "Scope"},
        @{PermissionID = "3b37c5a4-1226-493d-bec3-5d6c6b866f3f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomSecAttributeAssignment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ca46335e-8453-47cd-a001-8459884efeae"; Type = "Scope"},
        @{PermissionID = "de89b5e4-5b8f-48eb-8925-29c2b33bd8bd"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomSecAttributeAuditLogs.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1fcdeaab-b519-44dd-bffc-ed1fd15a24e0"; Type = "Scope"},
        @{PermissionID = "2a4f026d-e829-4e84-bdbf-d981a2703059"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomSecAttributeDefinition.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ce026878-a0ff-4745-a728-d4fedd086c07"; Type = "Scope"},
        @{PermissionID = "b185aa14-d8d2-42c1-a685-0f5596613624"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomSecAttributeDefinition.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8b0160d4-5743-482b-bb27-efc0a485ca4a"; Type = "Scope"},
        @{PermissionID = "12338004-21f4-4896-bf5e-b75dfaf1016d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomTags.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "de6ea87d-10bd-467c-8682-d525a0c61b89"; Type = "Scope"},
        @{PermissionID = "ab8a5872-7c88-47a6-8141-7becce939190"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/CustomTags.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2f1bbe0a-f34b-4efb-9edb-8db8dcb50eca"; Type = "Scope"},
        @{PermissionID = "2f503208-e509-4e39-974c-8cc16e5785c9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DelegatedAdminRelationship.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0c0064ea-477b-4130-82a5-4c2cc4ff68aa"; Type = "Scope"},
        @{PermissionID = "f6e9e124-4586-492f-adc0-c6f96e4823fd"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DelegatedAdminRelationship.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "885f682f-a990-4bad-a642-36736a74b0c7"; Type = "Scope"},
        @{PermissionID = "cc13eba4-8cd8-44c6-b4d4-f93237adce58"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DelegatedPermissionGrant.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a197cdc4-a8e8-4d49-9d35-4ca7c83887b4"; Type = "Scope"},
        @{PermissionID = "81b4724a-58aa-41c1-8a55-84ef97466587"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DelegatedPermissionGrant.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "41ce6ca6-6826-4807-84f1-1c82854f7ee5"; Type = "Scope"},
        @{PermissionID = "8e8e4742-1d95-4f68-9d56-6ee75648c72a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Device.Command"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bac3b9c2-b516-4ef4-bd3b-c2ef73d8d804"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Device.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "11d4cd79-5ba5-460f-803f-e22c8ab85ccd"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Device.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "951183d1-1a61-466f-a6d1-1fde911bfd95"; Type = "Scope"},
        @{PermissionID = "7438b122-aefc-4978-80ed-43db9fcc7715"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Device.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1138cb37-bd11-4084-a2b7-9f71582aeddb"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceLocalCredential.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "280b3b69-0437-44b1-bc20-3b2fca1ee3e9"; Type = "Scope"},
        @{PermissionID = "884b599e-4d48-43a5-ba94-15c414d00588"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceLocalCredential.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9917900e-410b-4d15-846e-42a357488545"; Type = "Scope"},
        @{PermissionID = "db51be59-e728-414b-b800-e0f010df1a79"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementApps.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4edf5f54-4666-44af-9de9-0144fb4b6e8c"; Type = "Scope"},
        @{PermissionID = "7a6ee1e7-141e-4cec-ae74-d9db155731ff"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementApps.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7b3f05d5-f68c-4b8d-8c59-a2ecd12f24af"; Type = "Scope"},
        @{PermissionID = "78145de6-330d-4800-a6ce-494ff2d33d07"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementConfiguration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f1493658-876a-4c87-8fa7-edb559b3476a"; Type = "Scope"},
        @{PermissionID = "dc377aa6-52d8-4e23-b271-2a7ae04cedf3"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementConfiguration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0883f392-0a7a-443d-8c76-16a6d39c7b63"; Type = "Scope"},
        @{PermissionID = "9241abd9-d0e6-425a-bd4f-47ba86e767a4"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementManagedDevices.PrivilegedOperations.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3404d2bf-2b13-457e-a330-c24615765193"; Type = "Scope"},
        @{PermissionID = "5b07b0dd-2377-4e44-a38d-703f09a0dc3c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementManagedDevices.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "314874da-47d6-4978-88dc-cf0d37f0bb82"; Type = "Scope"},
        @{PermissionID = "2f51be20-0bb4-4fed-bf7b-db946066c75e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementManagedDevices.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "44642bfe-8385-4adc-8fc6-fe3cb2c375c3"; Type = "Scope"},
        @{PermissionID = "243333ab-4d21-40cb-a475-36241daa0842"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementRBAC.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "49f0cc30-024c-4dfd-ab3e-82e137ee5431"; Type = "Scope"},
        @{PermissionID = "58ca0d9a-1575-47e1-a3cb-007ef2e4583b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementRBAC.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0c5e8a55-87a6-4556-93ab-adc52c4d862d"; Type = "Scope"},
        @{PermissionID = "e330c4f0-4170-414e-a55a-2f022ec2b57b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementServiceConfig.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8696daa5-bce5-4b2e-83f9-51b6defc4e1e"; Type = "Scope"},
        @{PermissionID = "06a5fe6d-c49d-46a7-b082-56b1b14103c7"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DeviceManagementServiceConfig.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "662ed50a-ac44-4eef-ad86-62eed9be2a29"; Type = "Scope"},
        @{PermissionID = "5ac13192-7ace-4fcf-b828-1a26f28068ee"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Directory.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0e263e50-5827-48a4-b97c-d940288653c7"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Directory.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "06da0dbc-49e2-44d2-8312-53f166ab848a"; Type = "Scope"},
        @{PermissionID = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Directory.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c5366453-9fb0-48a5-a156-24f0c49a4b84"; Type = "Scope"},
        @{PermissionID = "19dbc75e-c2e2-444c-a770-ec69d8559fc7"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Directory.Write.Restricted"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cba5390f-ed6a-4b7f-b657-0efc2210ed20"; Type = "Scope"},
        @{PermissionID = "f20584af-9290-4153-9280-ff8bb2c0ea7f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DirectoryRecommendations.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "34d3bd24-f6a6-468c-b67c-0c365c1d6410"; Type = "Scope"},
        @{PermissionID = "ae73097b-cb2a-4447-b064-5d80f6093921"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/DirectoryRecommendations.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f37235e8-90a0-4189-93e2-e55b53867ccd"; Type = "Scope"},
        @{PermissionID = "0e9eea12-4f01-45f6-9b8d-3ea4c8144158"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Domain.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2f9ee017-59c1-4f1d-9472-bd5529a7b311"; Type = "Scope"},
        @{PermissionID = "dbb9058a-0e50-45d7-ae91-66909b5d4664"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Domain.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0b5d694c-a244-4bde-86e6-eb5cd07730fe"; Type = "Scope"},
        @{PermissionID = "7e05723c-0bb0-42da-be95-ae9f08a6e53c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EAS.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ff91d191-45a0-43fd-b837-bd682c4a0b0f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/eDiscovery.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "99201db3-7652-4d5a-809a-bdb94f85fe3c"; Type = "Scope"},
        @{PermissionID = "50180013-6191-4d1e-a373-e590ff4e66af"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/eDiscovery.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "acb8f680-0834-4146-b69e-4ab1b39745ad"; Type = "Scope"},
        @{PermissionID = "b2620db1-3bf7-4c5b-9cb9-576d29eac736"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAdministration.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8523895c-6081-45bf-8a5d-f062a2f12c9f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAdministration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "7c9db06a-ec2d-4e7b-a592-5a1e30992566"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAdministration.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "63589852-04e3-46b4-bae9-15d5b1050748"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAdministration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9bc431c3-b8bc-4a8d-a219-40f10f92eff6"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAssignments.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "091460c9-9c4a-49b2-81ef-1f3d852acce2"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAssignments.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "4c37e1b6-35a1-43bf-926a-6f30f2cdf585"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAssignments.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c0b0103b-c053-4b2e-9973-9f3a544ec9b8"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAssignments.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6e0a958b-b7fc-4348-b7c4-a6ab9fd3dd0e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAssignments.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2f233e90-164b-4501-8bce-31af2559a2d3"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAssignments.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "0d22204b-6cad-4dd0-8362-3e3f2ae699d9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAssignments.ReadWriteBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2ef770a1-622a-47c4-93ee-28d6adbed3a0"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduAssignments.ReadWriteBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f431cc63-a2de-48c4-8054-a34bc093af84"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduCurricula.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "484859e8-b9e2-4e92-b910-84db35dadd29"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduCurricula.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6cdb464c-3a03-40f8-900b-4cb7ea1da9c0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduCurricula.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4793c53b-df34-44fd-8d26-d15c517732f5"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduCurricula.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6a0c2318-d59d-4c7d-bf2e-5f3902dc2593"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduReports-Reading.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "ad248c30-1919-40c8-b3d2-304481894e88"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduReports-Reading.ReadAnonymous.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "040330d7-be7e-4130-b349-a6eb3a56e2f8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduReports-Reflect.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "c5debf73-bdc8-473d-bf07-f4074ad05f71"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduReports-Reflect.ReadAnonymous.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f5d05dba-7ef0-46fc-b62c-a7282555f428"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduRoster.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a4389601-22d9-4096-ac18-36a927199112"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduRoster.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "e0ac9e1b-cb65-4fc5-87c5-1a8bc181f648"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduRoster.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5d186531-d1bf-4f07-8cea-7c42119e1bd9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduRoster.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "0d412a8c-a06c-439f-b3ec-8abcf54d2f96"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduRoster.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "359e19a6-e3fa-4d7f-bcab-d28ec592b51e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EduRoster.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "d1808e82-ce13-47af-ae0d-f9b254e6d58a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/email"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EntitlementManagement.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5449aa12-1393-4ea2-a7c7-d0e06c1a56b2"; Type = "Scope"},
        @{PermissionID = "c74fd47d-ed3c-45c3-9a9e-b8676de685d2"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EntitlementManagement.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ae7a573d-81d7-432b-ad44-4ed5c9d89038"; Type = "Scope"},
        @{PermissionID = "9acd699f-1e81-4958-b001-93b1d2506e19"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EntitlementMgmt-SubjectAccess.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e9fdcbbb-8807-410f-b9ec-8d5468c7c2ac"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EventListener.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f7dd3bed-5eec-48da-bc73-1c0ef50bc9a1"; Type = "Scope"},
        @{PermissionID = "b7f6385c-6ce6-4639-a480-e23c42ed9784"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EventListener.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d11625a6-fe21-4fc6-8d3d-063eba5525ad"; Type = "Scope"},
        @{PermissionID = "0edf5e9e-4ce8-468a-8432-d08631d18c43"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/EWS.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9769c687-087d-48ac-9cb3-c37dde652038"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ExternalConnection.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a38267a5-26b6-4d76-9493-935b7599116b"; Type = "Scope"},
        @{PermissionID = "1914711b-a1cb-4793-b019-c2ce0ed21b8c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ExternalConnection.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bbbbd9b3-3566-4931-ac37-2b2180d9e334"; Type = "Scope"},
        @{PermissionID = "34c37bc0-2b40-4d5e-85e1-2365cd256d79"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ExternalConnection.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4082ad95-c812-4f02-be92-780c4c4f1830"; Type = "Scope"},
        @{PermissionID = "f431331c-49a6-499f-be1c-62af19c34a9d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ExternalItem.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "922f9392-b1b7-483c-a4be-0089be7704fb"; Type = "Scope"},
        @{PermissionID = "7a7cffad-37d2-4f48-afa4-c6ab129adcc2"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ExternalItem.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b02c54f8-eb48-4c50-a9f0-a149e5a2012f"; Type = "Scope"},
        @{PermissionID = "38c3d6ee-69ee-422f-b954-e17819665354"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ExternalItem.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4367b9d7-cee7-4995-853c-a0bdfe95c1f9"; Type = "Scope"},
        @{PermissionID = "8116ae0f-55c2-452d-9944-d18420f5b2c8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ExternalUserProfile.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "47167bec-55a7-4caf-9ecc-8d4566e3cfb1"; Type = "Scope"},
        @{PermissionID = "1987d7a0-d602-4262-ab90-cfdd43b37545"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ExternalUserProfile.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c6068dc7-a791-46a4-a811-b8228e6649ab"; Type = "Scope"},
        @{PermissionID = "761327c9-d819-4c08-9a5f-874cd2826608"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Family.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3a1e4806-a744-4c70-80fc-223bf8582c46"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Files.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "10465720-29dd-4523-a11a-6a75c743c9d9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Files.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "df85f4d6-205c-4ac5-a5ea-6bf408dba283"; Type = "Scope"},
        @{PermissionID = "01d4889c-1287-42c6-ac1f-5d1e02578ef6"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Files.Read.Selected"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5447fe39-cb82-4c1a-b977-520e67e724eb"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Files.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5c28f0bf-8a70-41f1-8ab2-9032436ddb65"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Files.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "863451e7-0667-486c-a5d6-d135439485f0"; Type = "Scope"},
        @{PermissionID = "75359482-378d-4052-8f01-80520e7db3cd"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Files.ReadWrite.AppFolder"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8019c312-3263-48e6-825e-2b833497195b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Files.ReadWrite.Selected"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "17dde5bd-8c17-420f-a486-969730c1b827"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/FileStorageContainer.Selected"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "085ca537-6565-41c2-aca7-db852babc212"; Type = "Scope"},
        @{PermissionID = "40dc41bc-0f7e-42ff-89bd-d9516947e474"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Financials.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f534bf13-55d4-45a9-8f3c-c92fe64d6131"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Goals-Export.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "092211d9-ca1a-427b-813e-b79c7653fe71"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Goals-Export.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2edeb9fd-4228-480c-a26d-2ed52011cf3d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Group.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "bf7b1a76-6e77-406b-b258-bf5c7720e98f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Group.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5f8c59db-677d-491f-a6b8-5f174b11ec1d"; Type = "Scope"},
        @{PermissionID = "5b567255-7703-4780-807c-7be8301ae99b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Group.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4e46008b-f24c-477d-8fff-7bb4ec7aafe0"; Type = "Scope"},
        @{PermissionID = "62a82d76-70ea-41e2-9197-370581804d09"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/GroupMember.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bc024368-1153-4739-b217-4326f2e966d0"; Type = "Scope"},
        @{PermissionID = "98830695-27a2-44f7-8c18-0c3ebc9698f6"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/GroupMember.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f81125ac-d3b7-4573-a3b2-7099cc39df9e"; Type = "Scope"},
        @{PermissionID = "dbaae8cf-10b5-4b86-a4a1-f871c94c6695"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityProvider.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "43781733-b5a7-4d1b-98f4-e8edff23e1a9"; Type = "Scope"},
        @{PermissionID = "e321f0bb-e7f7-481e-bb28-e3b0b32d4bd0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityProvider.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f13ce604-1677-429f-90bd-8a10b9f01325"; Type = "Scope"},
        @{PermissionID = "90db2b9a-d928-4d33-a4dd-8442ae3d41e4"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityRiskEvent.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8f6a01e7-0391-4ee5-aa22-a3af122cef27"; Type = "Scope"},
        @{PermissionID = "6e472fd1-ad78-48da-a0f0-97ab2c6b769e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityRiskEvent.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9e4862a5-b68f-479e-848a-4e07e25c9916"; Type = "Scope"},
        @{PermissionID = "db06fb33-1953-4b7b-a2ac-f1e2c854f7ae"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityRiskyServicePrincipal.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ea5c4ab0-5a73-4f35-8272-5d5337884e5d"; Type = "Scope"},
        @{PermissionID = "607c7344-0eed-41e5-823a-9695ebe1b7b0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityRiskyServicePrincipal.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bb6f654c-d7fd-4ae3-85c3-fc380934f515"; Type = "Scope"},
        @{PermissionID = "cb8d6980-6bcb-4507-afec-ed6de3a2d798"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityRiskyUser.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d04bb851-cb7c-4146-97c7-ca3e71baf56c"; Type = "Scope"},
        @{PermissionID = "dc5007c0-2d7d-4c42-879c-2dab87571379"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityRiskyUser.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e0a7cdbb-08b0-4697-8264-0069786e9674"; Type = "Scope"},
        @{PermissionID = "656f6061-f9fe-4807-9708-6a2e0934df76"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityUserFlow.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2903d63d-4611-4d43-99ce-a33f3f52e343"; Type = "Scope"},
        @{PermissionID = "1b0c317f-dd31-4305-9932-259a8b6e8099"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IdentityUserFlow.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "281892cc-4dbf-4e3a-b6cc-b21029bb4e82"; Type = "Scope"},
        @{PermissionID = "65319a09-a2be-469d-8782-f6b07debf789"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IMAP.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "652390e4-393a-48de-9484-05f9b1212954"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "60382b96-1f5e-46ea-a544-0407e489e588"; Type = "Scope"},
        @{PermissionID = "4f5ac95f-62fd-472c-b60f-125d24ca0bc5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-DataConnector.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d19c0de5-7ecb-4aba-b090-da35ebcd5425"; Type = "Scope"},
        @{PermissionID = "7ab52c2f-a2ee-4d98-9ebc-725e3934aae2"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-DataConnector.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5ce933ac-3997-4280-aed0-cc072e5c062a"; Type = "Scope"},
        @{PermissionID = "eda0971c-482e-4345-b28f-69c309cb8a34"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-DataConnector.Upload"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "fc47391d-ab2c-410f-9059-5600f7af660d"; Type = "Scope"},
        @{PermissionID = "9334c44b-a7c6-4350-8036-6bf8e02b4c1f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-InboundFlow.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cb0774da-a605-42af-959c-32f438fb38f4"; Type = "Scope"},
        @{PermissionID = "305f6ba2-049a-4b1b-88bb-fe7e08758a00"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-InboundFlow.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "97044676-2cec-40ee-bd70-38df444c9e70"; Type = "Scope"},
        @{PermissionID = "e688c61f-d4c6-4d64-a197-3bcf6ba1d6ad"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-OutboundFlow.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4741a003-8952-4be4-9217-33a0ac327122"; Type = "Scope"},
        @{PermissionID = "61d0354c-5d88-483c-b974-a37ec3395a2c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-OutboundFlow.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "aeb68e0b-e562-4a1f-b6dd-3484ad0cbb4b"; Type = "Scope"},
        @{PermissionID = "24a65b4a-e501-47e2-8849-d679517887f0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-ReferenceDefinition.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a3f96ffe-cb84-40a8-ac85-582d7ef97c2a"; Type = "Scope"},
        @{PermissionID = "6ee891c3-74a4-4148-8463-0c834375dfaf"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-Run.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "92685235-50c4-4702-b2c8-36043db6fa79"; Type = "Scope"},
        @{PermissionID = "f6f5d10b-3024-4d1d-b674-aae4df4a1a73"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-SourceSystem.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "49b7016c-89ae-41e7-bd6f-b7170c5490bf"; Type = "Scope"},
        @{PermissionID = "bc167a60-39fe-4865-8b44-78400fc6ed03"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-SourceSystem.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9599f005-05d6-4ea7-b1b1-4929768af5d0"; Type = "Scope"},
        @{PermissionID = "7d866958-e06e-4dd6-91c6-a086b3f5cfeb"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-TimePeriod.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c9d51f28-8ccd-42b2-a836-fd8fe9ebf2ae"; Type = "Scope"},
        @{PermissionID = "7c55c952-b095-4c23-a522-022bce4cc1e3"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/IndustryData-TimePeriod.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b6d56528-3032-4f9d-830f-5a24a25e6661"; Type = "Scope"},
        @{PermissionID = "7afa7744-a782-4a32-b8c2-e3db637e8de7"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/InformationProtectionConfig.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "12f4bffb-b598-413c-984b-db99728f8b54"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/InformationProtectionConfig.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "14f49b9f-4bf2-4d24-b80e-b27ec58409bd"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/InformationProtectionContent.Sign.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "cbe6c7e4-09aa-4b8d-b3c3-2dbb59af4b54"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/InformationProtectionContent.Write.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "287bd98c-e865-4e8c-bade-1a85523195b9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/InformationProtectionPolicy.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4ad84827-5578-4e18-ad7a-86530b12f884"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/InformationProtectionPolicy.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "19da66cb-0fb0-4390-b071-ebc76a349482"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Insights-UserMetric.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7d249730-51a3-4180-8ec1-214f144f1bff"; Type = "Scope"},
        @{PermissionID = "34cbd96c-d824-4755-90d3-1008ef47efc1"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningAssignedCourse.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ac08cdae-e845-41db-adf9-5899a0ec9ef6"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningAssignedCourse.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "535e6066-2894-49ef-ab33-e2c6d064bb81"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningAssignedCourse.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "236c1cbd-1187-427f-b0f5-b1852454973b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningContent.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ea4c1fd9-6a9f-4432-8e5d-86e06cc0da77"; Type = "Scope"},
        @{PermissionID = "8740813e-d8aa-4204-860e-2a0f8f84dbc8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningContent.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "53cec1c4-a65f-4981-9dc1-ad75dbf1c077"; Type = "Scope"},
        @{PermissionID = "444d6fcb-b738-41e5-b103-ac4f2a2628a3"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningProvider.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dd8ce36f-9245-45ea-a99e-8ac398c22861"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningProvider.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "40c2eb57-abaf-49f5-9331-e90fd01f7130"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningSelfInitiatedCourse.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f6403ef7-4a96-47be-a190-69ba274c3f11"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningSelfInitiatedCourse.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "467524fc-ed22-4356-a910-af61191e3503"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LearningSelfInitiatedCourse.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "7654ed61-8965-4025-846a-0856ec02b5b0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LicenseAssignment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f55016cc-149c-447e-8f21-7cf3ec1d6350"; Type = "Scope"},
        @{PermissionID = "5facf0c1-8979-4e95-abcf-ff3d079771c0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LifecycleWorkflows.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9bcb9916-765a-42af-bf77-02282e26b01a"; Type = "Scope"},
        @{PermissionID = "7c67316a-232a-4b84-be22-cea2c0906404"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/LifecycleWorkflows.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "84b9d731-7db8-4454-8c90-fd9e95350179"; Type = "Scope"},
        @{PermissionID = "5c505cf4-8424-4b8e-aa14-ee06e3bb23e3"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Mail.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "570282fd-fa5c-430d-a7fd-fc8dc98a9dca"; Type = "Scope"},
        @{PermissionID = "810c84a8-4a9e-49e6-bf7d-12d183f40d01"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Mail.Read.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7b9103a5-4610-446b-9670-80643382c1fa"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Mail.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a4b8392a-d8d1-4954-a029-8e668a39a170"; Type = "Scope"},
        @{PermissionID = "6be147d2-ea4f-4b5a-a3fa-3eab6f3c140a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Mail.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "693c5e45-0940-467d-9b8a-1022fb9d42ef"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Mail.ReadBasic.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b11fa0e7-fdb7-4dc9-b1f1-59facd463480"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Mail.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "024d486e-b451-40bb-833d-3e66d98c5c73"; Type = "Scope"},
        @{PermissionID = "e2a3a72e-5f79-4c64-b1b1-878b674786c9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Mail.ReadWrite.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5df07973-7d5d-46ed-9847-1271055cbd51"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Mail.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e383f46e-2787-4529-855e-0e479a3ffac0"; Type = "Scope"},
        @{PermissionID = "b633e1c5-b582-4048-a93e-9f11b44c7e96"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Mail.Send.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a367ab51-6b49-43bf-a716-a1fb06d2a174"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/MailboxSettings.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "87f447af-9fa4-4c32-9dfa-4a57a73d18ce"; Type = "Scope"},
        @{PermissionID = "40f97065-369a-49f4-947c-6a255697ae91"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/MailboxSettings.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "818c620a-27a9-40bd-a6a5-d96f7d610b4b"; Type = "Scope"},
        @{PermissionID = "6931bccd-447a-43d1-b442-00a195474933"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ManagedTenants.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dc34164e-6c4a-41a0-be89-3ae2fbad7cd3"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ManagedTenants.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b31fa710-c9b3-4d9e-8f5e-8036eecddab9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Member.Read.Hidden"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f6a3db3e-f7e8-4ed2-a414-557c8c9830be"; Type = "Scope"},
        @{PermissionID = "658aa5d8-239f-45c4-aa12-864f4fc7e490"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/MultiTenantOrganization.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "526aa72a-5878-49fe-bf4e-357973af9b06"; Type = "Scope"},
        @{PermissionID = "4f994bc0-31bb-44bb-b480-7a7c1be8c02e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/MultiTenantOrganization.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "225db56b-15b2-4daa-acb3-0eec2bbe4849"; Type = "Scope"},
        @{PermissionID = "f9c2b2a7-3895-4b2e-80f6-c924b456e50b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/MultiTenantOrganization.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "77af1528-84f3-4023-8d90-d219cd433108"; Type = "Scope"},
        @{PermissionID = "920def01-ca61-4d2d-b3df-105b46046a70"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/NetworkAccess.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2f7013e0-ab4e-447f-a5e1-5d419950692d"; Type = "Scope"},
        @{PermissionID = "e30060de-caa5-4331-99d3-6ac6c966a9a4"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/NetworkAccess.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ae2df9c5-f18d-4ec4-a51b-bdeb807f177b"; Type = "Scope"},
        @{PermissionID = "b10642fc-a6cf-4c46-87f9-e1f96c2a18aa"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/NetworkAccessBranch.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4051c7fc-b429-4804-8d80-8f1f8c24a6f7"; Type = "Scope"},
        @{PermissionID = "39ae4a24-1ef0-49e8-9d63-2a66f5c39edd"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/NetworkAccessBranch.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b8a36cc2-b810-461a-baa4-a7281e50bd5c"; Type = "Scope"},
        @{PermissionID = "8137102d-ec16-4191-aaf8-7aeda8026183"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/NetworkAccessPolicy.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba22922b-752c-446f-89d7-a2d92398fceb"; Type = "Scope"},
        @{PermissionID = "8a3d36bf-cb46-4bcc-bec9-8d92829dab84"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/NetworkAccessPolicy.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b1fbad0f-ef6e-42ed-8676-bca7fa3e7291"; Type = "Scope"},
        @{PermissionID = "f0c341be-8348-4989-8e43-660324294538"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/NetworkAccess-Reports.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b0c61509-cfc3-42bd-9bd4-66d81785fee4"; Type = "Scope"},
        @{PermissionID = "40049381-3cc1-42af-94ec-5ce755db4b0d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Notes.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9d822255-d64d-4b7a-afdb-833b9a97ed02"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Notes.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "371361e4-b9e2-4a3f-8315-2a301a3b0a3d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Notes.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dfabfca6-ee36-4db2-8208-7a28381419b3"; Type = "Scope"},
        @{PermissionID = "3aeca27b-ee3a-4c2b-8ded-80376e2134a4"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Notes.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "615e26af-c38a-4150-ae3e-c3b0d4cb1d6a"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Notes.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "64ac0503-b4fa-45d9-b544-71a463f05da0"; Type = "Scope"},
        @{PermissionID = "0c458cef-11f3-48c2-a568-c66751c238c0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Notes.ReadWrite.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ed68249d-017c-4df5-9113-e684c7f8760b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Notifications.ReadWrite.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "89497502-6e42-46a2-8cb2-427fd3df970a"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/offline_access"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnlineMeetingArtifact.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "110e5abb-a10c-4b59-8b55-9b4daa4ef743"; Type = "Scope"},
        @{PermissionID = "df01ed3b-eb61-4eca-9965-6b3d789751b2"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnlineMeetingRecording.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "190c2bb6-1fdd-4fec-9aa2-7d571b5e1fe3"; Type = "Scope"},
        @{PermissionID = "a4a08342-c95d-476b-b943-97e100569c8d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnlineMeetings.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9be106e1-f4e3-4df5-bdff-e4bc531cbe43"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnlineMeetings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "c1684f21-1984-47fa-9d61-2dc8c296bb70"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnlineMeetings.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a65f2972-a4f8-4f5e-afd7-69ccb046d5dc"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnlineMeetings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b8bb2037-6e08-44ac-a4ea-4674e010e2a4"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnlineMeetingTranscript.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "30b87d18-ebb1-45db-97f8-82ccb1f0190c"; Type = "Scope"},
        @{PermissionID = "a4a80d8d-d283-4bd8-8504-555ec3870630"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnPremDirectorySynchronization.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f6609722-4100-44eb-b747-e6ca0536989d"; Type = "Scope"},
        @{PermissionID = "bb70e231-92dc-4729-aff5-697b3f04be95"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnPremDirectorySynchronization.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c2d95988-7604-4ba1-aaed-38a5f82a51c7"; Type = "Scope"},
        @{PermissionID = "c22a92cc-79bf-4bb1-8b6c-e0a05d3d80ce"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OnPremisesPublishingProfiles.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8c4d5184-71c2-4bf8-bb9d-bc3378c9ad42"; Type = "Scope"},
        @{PermissionID = "0b57845e-aa49-4e6f-8109-ce654fffa618"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/openid"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "37f7f235-527c-4136-accd-4a02d197296e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Organization.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4908d5b9-3fb2-4b1e-9336-1888b7937185"; Type = "Scope"},
        @{PermissionID = "498476ce-e0fe-48b0-b801-37ba7e2685c6"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Organization.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "46ca0847-7e6b-426e-9775-ea810a948356"; Type = "Scope"},
        @{PermissionID = "292d869f-3427-49a8-9dab-8c70152b74e9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrganizationalBranding.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9082f138-6f02-4f3a-9f4d-5f3c2ce5c688"; Type = "Scope"},
        @{PermissionID = "eb76ac34-0d62-4454-b97c-185e4250dc20"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrganizationalBranding.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "15ce63de-b141-4c9a-a9a5-241bf27c6aaf"; Type = "Scope"},
        @{PermissionID = "d2ebfbc1-a5f8-424b-83a6-56ab5927a73c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgContact.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "08432d1b-5911-483c-86df-7980af5cdee0"; Type = "Scope"},
        @{PermissionID = "e1a88a34-94c4-4418-be12-c87b00e26bea"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-AppsAndServices.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1e9b7a7e-4d64-44ff-acf5-2e9651c1519f"; Type = "Scope"},
        @{PermissionID = "56c84fa9-ea1f-4a15-90f2-90ef41ece2c9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-AppsAndServices.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c167b0e7-47c0-48e8-9eee-9892f58018fa"; Type = "Scope"},
        @{PermissionID = "4a8e4191-c1c8-45f8-b801-f9a1a5ee6ad3"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-DynamicsVoice.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9862d930-5aec-4a98-8d4f-7277a8db9bcb"; Type = "Scope"},
        @{PermissionID = "c18ae2dc-d9f3-4495-a93f-18980a0e159f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-DynamicsVoice.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4cea26fb-6967-4234-82c4-c044414743f8"; Type = "Scope"},
        @{PermissionID = "c3f1cc32-8bbd-4ab6-bd33-f270e0d9e041"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-Forms.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "210051a0-1ffc-435c-ae76-02d226d05752"; Type = "Scope"},
        @{PermissionID = "434d7c66-07c6-4b1f-ab21-417cf2cdaaca"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-Forms.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "346c19ff-3fb2-4e81-87a0-bac9e33990c1"; Type = "Scope"},
        @{PermissionID = "2cb92fee-97a3-4034-8702-24a6f5d0d1e9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-Microsoft365Install.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8cbdb9f6-9c2e-451a-814d-ec606e5d0212"; Type = "Scope"},
        @{PermissionID = "6cdf1fb1-b46f-424f-9493-07247caa22e2"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-Microsoft365Install.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1ff35e91-19eb-42d8-aa2d-cc9891127ae5"; Type = "Scope"},
        @{PermissionID = "83f7232f-763c-47b2-a097-e35d2cbe1da5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-Todo.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7ff96f41-f022-45ba-acd8-ef3f03063d6b"; Type = "Scope"},
        @{PermissionID = "e4d9cd09-d858-4363-9410-abb96737f0cf"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/OrgSettings-Todo.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "087502c2-5263-433e-abe3-8f77231a0627"; Type = "Scope"},
        @{PermissionID = "5febc9da-e0d0-4576-bd13-ae70b2179a39"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PartnerBilling.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8804798e-5934-4e30-8ce3-ef88257cecd4"; Type = "Scope"},
        @{PermissionID = "7c3e1994-38ff-4412-a99b-9369f6bb7706"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PendingExternalUserProfile.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d88fd3fb-53d3-4c1c-8c39-787fcac2ed7a"; Type = "Scope"},
        @{PermissionID = "bdfb26d9-bb36-49be-9b4c-b8cbf4b05808"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PendingExternalUserProfile.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "93a1fb28-c908-4826-904e-0c74ad352b73"; Type = "Scope"},
        @{PermissionID = "8363c2b8-6ff7-420b-9966-c5884c2d48bc"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/People.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba47897c-39ec-4d83-8086-ee8256fa737d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/People.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b89f9189-71a5-4e70-b041-9887f0bc7e4a"; Type = "Scope"},
        @{PermissionID = "b528084d-ad10-4598-8b93-929746b4d7d6"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PeopleSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ec762c5f-388b-4b16-8693-ac1efbc611bc"; Type = "Scope"},
        @{PermissionID = "ef02f2e7-e22d-4c77-8614-8f765683b86e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PeopleSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e67e6727-c080-415e-b521-e3f35d5248e9"; Type = "Scope"},
        @{PermissionID = "b6890674-9dd5-4e42-bb15-5af07f541ae1"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Place.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cb8f45a0-5c2e-4ea1-b803-84b870a7d7ec"; Type = "Scope"},
        @{PermissionID = "913b9306-0ce1-42b8-9137-6a7df690a760"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Place.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4c06a06a-098a-4063-868e-5dfee3827264"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PlaceDevice.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4c7f93d2-6b0b-4e05-91aa-87842f0a2142"; Type = "Scope"},
        @{PermissionID = "8b724a84-ceac-4fd9-897e-e31ba8f2d7a3"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PlaceDevice.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "eafd6a71-e95a-4f8a-bb6e-fb84ab7fbd9e"; Type = "Scope"},
        @{PermissionID = "2d510721-5c4e-43cd-bfdb-ac0f8819fb92"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PlaceDeviceTelemetry.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "27fc435f-44e2-4b30-bf3c-e0ce74aed618"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "572fea84-0151-49b2-9301-11cb16974376"; Type = "Scope"},
        @{PermissionID = "246dd0d5-5bd0-4def-940b-0421030a5b68"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.Read.ConditionalAccess"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "633e0fce-8c58-4cfb-9495-12bbd5a24f7c"; Type = "Scope"},
        @{PermissionID = "37730810-e9ba-4e46-b07e-8ca78d182097"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.Read.IdentityProtection"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d146432f-b803-4ed4-8d42-ba74193a6ede"; Type = "Scope"},
        @{PermissionID = "b21b72f6-4e6a-4533-9112-47eea9f97b28"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.Read.PermissionGrant"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "414de6ea-2d92-462f-b120-6e2a809a6d01"; Type = "Scope"},
        @{PermissionID = "9e640839-a198-48fb-8b9a-013fd6f6cbcd"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.AccessReview"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4f5bc9c8-ea54-4772-973a-9ca119cb0409"; Type = "Scope"},
        @{PermissionID = "77c863fd-06c0-47ce-a7eb-49773e89d319"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.ApplicationConfiguration"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b27add92-efb2-4f16-84f5-8108ba77985c"; Type = "Scope"},
        @{PermissionID = "be74164b-cff1-491c-8741-e671cb536e13"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.AuthenticationFlows"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "edb72de9-4252-4d03-a925-451deef99db7"; Type = "Scope"},
        @{PermissionID = "25f85f3c-f66c-4205-8cd5-de92dd7f0cec"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.AuthenticationMethod"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7e823077-d88e-468f-a337-e18f1f0e6c7c"; Type = "Scope"},
        @{PermissionID = "29c18626-4985-4dcd-85c0-193eef327366"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.Authorization"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "edd3c878-b384-41fd-95ad-e7407dd775be"; Type = "Scope"},
        @{PermissionID = "fb221be6-99f2-473f-bd32-01c6a0e9ca3b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.ConditionalAccess"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ad902697-1014-4ef5-81ef-2b4301988e8c"; Type = "Scope"},
        @{PermissionID = "01c0a623-fc9b-48e9-b794-0756f8e8f067"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.ConsentRequest"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4d135e65-66b8-41a8-9f8b-081452c91774"; Type = "Scope"},
        @{PermissionID = "999f8c63-0a38-4f1b-91fd-ed1947bdd1a9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.CrossTenantAccess"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "014b43d0-6ed4-4fc6-84dc-4b6f7bae7d85"; Type = "Scope"},
        @{PermissionID = "338163d7-f101-4c92-94ba-ca46fe52447c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.DeviceConfiguration"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "40b534c3-9552-4550-901b-23879c90bcf9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.ExternalIdentities"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b5219784-1215-45b5-b3f1-88fe1081f9c0"; Type = "Scope"},
        @{PermissionID = "03cc4f92-788e-4ede-b93f-199424d144a5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.FeatureRollout"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "92a38652-f13b-4875-bc77-6e1dbb63e1b2"; Type = "Scope"},
        @{PermissionID = "2044e4f1-e56c-435b-925c-44cd8f6ba89a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.FedTokenValidation"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "be1be369-4540-4ac9-8928-79de99f70d8f"; Type = "Scope"},
        @{PermissionID = "90bbca0b-227c-4cdc-8083-1c6cfb95bac6"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.IdentityProtection"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7256e131-3efb-4323-9854-cf41c6021770"; Type = "Scope"},
        @{PermissionID = "2dcf8603-09eb-4078-b1ec-d30a1a76b873"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.MobilityManagement"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a8ead177-1889-4546-9387-f25e658e2a79"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.PermissionGrant"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2672f8bb-fd5e-42e0-85e1-ec764dd2614e"; Type = "Scope"},
        @{PermissionID = "a402ca1c-2696-4531-972d-6e5ee4aa11ea"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.SecurityDefaults"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0b2a744c-2abf-4f1e-ad7e-17a087e2be99"; Type = "Scope"},
        @{PermissionID = "1c6e93a6-28e2-4cbb-9f64-1a46a821124d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Policy.ReadWrite.TrustFramework"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cefba324-1a70-4a6e-9c1d-fd670b7ae392"; Type = "Scope"},
        @{PermissionID = "79a677f7-b79d-40d0-a36a-3e6f8688dd7a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/POP.AccessAsUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d7b7f2d9-0f45-4ea1-9d42-e50810c06991"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Presence.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "76bc735e-aecd-4a1d-8b4c-2b915deabb79"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Presence.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9c7a330d-35b3-4aa1-963d-cb2b9f927841"; Type = "Scope"},
        @{PermissionID = "a70e0c2d-e793-494c-94c4-118fa0a67f42"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Presence.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8d3c54a7-cf58-4773-bf81-c0cd6ad522bb"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Presence.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "83cded22-8297-4ff6-a7fa-e97e9545a259"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintConnector.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d69c2d6d-4f72-4f99-a6b9-663e32f8cf68"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintConnector.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "79ef9967-7d59-4213-9c64-4b10687637d8"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Printer.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "90c30bed-6fd1-4279-bf39-714069619721"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Printer.FullControl.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "93dae4bd-43a1-4a23-9a1a-92957e1d9121"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Printer.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3a736c8a-018e-460a-b60c-863b2683e8bf"; Type = "Scope"},
        @{PermissionID = "9709bb33-4549-49d4-8ed9-a8f65e45bb0f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Printer.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "89f66824-725f-4b8f-928e-e1c5258dc565"; Type = "Scope"},
        @{PermissionID = "f5b3f73d-6247-44df-a74c-866173fddab0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrinterShare.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ed11134d-2f3f-440d-a2e1-411efada2502"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrinterShare.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5fa075e9-b951-4165-947b-c63396ff0a37"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrinterShare.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "06ceea37-85e2-40d7-bec3-91337a46038f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "21f0d9c0-9f13-48b3-94e0-b6b231c7d320"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.Manage.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "58a52f47-9e36-4b17-9ebe-ce4ef7f3e6c8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "248f5528-65c0-4c88-8326-876c7236df5e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "afdd6933-a0d8-40f7-bd1a-b5d778e8624b"; Type = "Scope"},
        @{PermissionID = "ac6f956c-edea-44e4-bd06-64b1b4b9aec9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.ReadBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6a71a747-280f-4670-9ca0-a9cbf882b274"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "04ce8d60-72ce-4867-85cf-6d82f36922f3"; Type = "Scope"},
        @{PermissionID = "fbf67eee-e074-4ef7-b965-ab5ce1c1f689"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b81dd597-8abb-4b3f-a07a-820b0316ed04"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "036b9544-e8c5-46ef-900a-0646cc42b271"; Type = "Scope"},
        @{PermissionID = "5114b07b-2898-4de7-a541-53b0004e2e13"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.ReadWriteBasic"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6f2d22f2-1cb6-412c-a17c-3336817eaa82"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintJob.ReadWriteBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3a0db2f6-0d2a-4c19-971b-49109b19ad3d"; Type = "Scope"},
        @{PermissionID = "57878358-37f4-4d3a-8c20-4816e0d457b1"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "490f32fd-d90f-4dd7-a601-ff6cdc1a3f6c"; Type = "Scope"},
        @{PermissionID = "b5991872-94cf-4652-9765-29535087c6d8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9ccc526a-c51c-4e5c-a1fd-74726ef50b8f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrintTaskDefinition.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "456b71a7-0ee0-4588-9842-c123fcc8f664"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedAccess.Read.AzureAD"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b3a539c9-59cb-4ad5-825a-041ddbdc2bdb"; Type = "Scope"},
        @{PermissionID = "4cdc2547-9148-4295-8d11-be0db1391d6b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedAccess.Read.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d329c81c-20ad-4772-abf9-3f6fdb7e5988"; Type = "Scope"},
        @{PermissionID = "01e37dc9-c035-40bd-b438-b2879c4870a6"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedAccess.Read.AzureResources"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1d89d70c-dcac-4248-b214-903c457af83a"; Type = "Scope"},
        @{PermissionID = "5df6fe86-1be0-44eb-b916-7bd443a71236"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedAccess.ReadWrite.AzureAD"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3c3c74f5-cdaa-4a97-b7e0-4e788bfcfb37"; Type = "Scope"},
        @{PermissionID = "854d9ab1-6657-4ec8-be45-823027bcd009"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedAccess.ReadWrite.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "32531c59-1f32-461f-b8df-6f8a3b89f73b"; Type = "Scope"},
        @{PermissionID = "2f6817f8-7b12-4f0f-bc18-eeaf60705a9e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedAccess.ReadWrite.AzureResources"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a84a9652-ffd3-496e-a991-22ba5529156a"; Type = "Scope"},
        @{PermissionID = "6f9d5abc-2db6-400b-a267-7de22a40fb87"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedAssignmentSchedule.Read.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "02a32cc4-7ab5-4b58-879a-0586e0f7c495"; Type = "Scope"},
        @{PermissionID = "cd4161cb-f098-48f8-a884-1eda9a42434c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedAssignmentSchedule.ReadWrite.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "06dbc45d-6708-4ef0-a797-f797ee68bf4b"; Type = "Scope"},
        @{PermissionID = "41202f2c-f7ab-45be-b001-85c9728b9d69"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedEligibilitySchedule.Read.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8f44f93d-ecef-46ae-a9bf-338508d44d6b"; Type = "Scope"},
        @{PermissionID = "edb419d6-7edc-42a3-9345-509bfdf5d87c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/PrivilegedEligibilitySchedule.ReadWrite.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ba974594-d163-484e-ba39-c330d5897667"; Type = "Scope"},
        @{PermissionID = "618b6020-bca8-4de6-99f6-ef445fa4d857"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/profile"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "14dad69e-099b-42c9-810b-d002981feec1"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ProgramControl.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c492a2e1-2f8f-4caa-b076-99bbf6e40fe4"; Type = "Scope"},
        @{PermissionID = "eedb7fdd-7539-4345-a38b-4839e4a84cbd"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ProgramControl.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "50fd364f-9d93-4ae1-b170-300e87cccf84"; Type = "Scope"},
        @{PermissionID = "60a901ed-09f7-4aa5-a16e-7dd3d6f9de36"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/QnA.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f73fa04f-b9a5-4df9-8843-993ce928925e"; Type = "Scope"},
        @{PermissionID = "ee49e170-1dd1-4030-b44c-61ad6e98f743"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RecordsManagement.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "07f995eb-fc67-4522-ad66-2b8ca8ea3efd"; Type = "Scope"},
        @{PermissionID = "ac3a2b8e-03a3-4da9-9ce0-cbe28bf1accd"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RecordsManagement.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f2833d75-a4e6-40ab-86d4-6dfe73c97605"; Type = "Scope"},
        @{PermissionID = "eb158f57-df43-4751-8b21-b8932adb3d34"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Reports.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "02e97553-ed7b-43d0-ab3c-f8bace0d040c"; Type = "Scope"},
        @{PermissionID = "230c1aed-a721-4c5d-9cb4-a90514e508ef"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ReportSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "84fac5f4-33a9-4100-aa38-a20c6d29e5e7"; Type = "Scope"},
        @{PermissionID = "ee353f83-55ef-4b78-82da-555bfa2b4b95"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ReportSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b955410e-7715-4a88-a940-dfd551018df3"; Type = "Scope"},
        @{PermissionID = "2a60023f-3219-47ad-baa4-40e17cd02a1d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ResourceSpecificPermissionGrant.ReadForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f1d91a8f-88e7-4774-8401-b668d5bca0c5"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ResourceSpecificPermissionGrant.ReadForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "acfca4d5-f49f-40ed-9648-84068b474c73"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleAssignmentSchedule.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "344a729c-0285-42c6-9014-f12b9b8d6129"; Type = "Scope"},
        @{PermissionID = "d5fe8ce8-684c-4c83-a52c-46e882ce4be1"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleAssignmentSchedule.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8c026be3-8e26-4774-9372-8d5d6f21daff"; Type = "Scope"},
        @{PermissionID = "dd199f4a-f148-40a4-a2ec-f0069cc799ec"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleEligibilitySchedule.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "eb0788c2-6d4e-4658-8c9e-c0fb8053f03d"; Type = "Scope"},
        @{PermissionID = "ff278e11-4a33-4d0c-83d2-d01dc58929a5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleEligibilitySchedule.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "62ade113-f8e0-4bf9-a6ba-5acb31db32fd"; Type = "Scope"},
        @{PermissionID = "fee28b28-e1f3-4841-818e-2704dc62245f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagement.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "48fec646-b2ba-4019-8681-8eb31435aded"; Type = "Scope"},
        @{PermissionID = "c7fbd983-d9aa-4fa7-84b8-17382c103bc4"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagement.Read.CloudPC"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9619b88a-8a25-48a7-9571-d23be0337a79"; Type = "Scope"},
        @{PermissionID = "031a549a-bb80-49b6-8032-2068448c6a3c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagement.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "741c54c3-0c1e-44a1-818b-3f97ab4e8c83"; Type = "Scope"},
        @{PermissionID = "483bed4a-2ad3-4361-a73b-c83ccdbdc53c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagement.Read.Exchange"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3bc15058-7858-4141-b24f-ae43b4e80b52"; Type = "Scope"},
        @{PermissionID = "c769435f-f061-4d0b-8ff1-3d39870e5f85"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagement.ReadWrite.CloudPC"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "501d06f8-07b8-4f18-b5c6-c191a4af7a82"; Type = "Scope"},
        @{PermissionID = "274d0592-d1b6-44bd-af1d-26d259bcb43a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagement.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d01b97e9-cbc0-49fe-810a-750afd5527a3"; Type = "Scope"},
        @{PermissionID = "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagement.ReadWrite.Exchange"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c1499fe0-52b1-4b22-bed2-7a244e0e879f"; Type = "Scope"},
        @{PermissionID = "025d3225-3f02-4882-b4c0-cd5b541a4e80"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagementAlert.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cce71173-f76d-446e-97ff-efb2d82e11b1"; Type = "Scope"},
        @{PermissionID = "ef31918f-2d50-4755-8943-b8638c0a077e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagementAlert.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "435644c6-a5b1-40bf-8f52-fe8e5b53e19c"; Type = "Scope"},
        @{PermissionID = "11059518-d6a6-4851-98ed-509268489c4a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagementPolicy.Read.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7e26fdff-9cb1-4e56-bede-211fe0e420e8"; Type = "Scope"},
        @{PermissionID = "69e67828-780e-47fd-b28c-7b27d14864e6"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagementPolicy.Read.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "3de2cdbe-0ff5-47d5-bdee-7f45b4749ead"; Type = "Scope"},
        @{PermissionID = "fdc4c997-9942-4479-bfcb-75a36d1138df"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagementPolicy.ReadWrite.AzureADGroup"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0da165c7-3f15-4236-b733-c0b0f6abe41d"; Type = "Scope"},
        @{PermissionID = "b38dcc4d-a239-4ed6-aa84-6c65b284f97c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/RoleManagementPolicy.ReadWrite.Directory"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1ff1be21-34eb-448c-9ac9-ce1f506b2a68"; Type = "Scope"},
        @{PermissionID = "31e08e0a-d3f7-4ca2-ac39-7343fb83e8ad"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Schedule.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "fccf6dd8-5706-49fa-811f-69e2e1b585d0"; Type = "Scope"},
        @{PermissionID = "7b2ebf90-d836-437f-b90d-7b62722c4456"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Schedule.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "63f27281-c9d9-4f29-94dd-6942f7f1feb0"; Type = "Scope"},
        @{PermissionID = "b7760610-0545-4e8a-9ec3-cce9e63db01c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SchedulePermissions.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "07919803-6073-4cd8-bc55-28077db0ee10"; Type = "Scope"},
        @{PermissionID = "7239b71d-b402-4150-b13d-78ecfe8df441"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SearchConfiguration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7d307522-aa38-4cd0-bd60-90c6f0ac50bd"; Type = "Scope"},
        @{PermissionID = "ada977a5-b8b1-493b-9a91-66c206d76ecf"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SearchConfiguration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b1a7d408-cab0-47d2-a2a5-a74a3733600d"; Type = "Scope"},
        @{PermissionID = "0e778b85-fefa-466d-9eec-750569d92122"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityActions.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1638cddf-07a4-4de2-8645-69c96cacad73"; Type = "Scope"},
        @{PermissionID = "5e0edab9-c148-49d0-b423-ac253e121825"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityActions.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "dc38509c-b87d-4da0-bd92-6bec988bac4a"; Type = "Scope"},
        @{PermissionID = "f2bf083f-0179-402a-bedb-b2784de8a49b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityAlert.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bc257fb8-46b4-4b15-8713-01e91bfbe4ea"; Type = "Scope"},
        @{PermissionID = "472e4a4d-bb4a-4026-98d1-0b0d74cb74a5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityAlert.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "471f2a7f-2a42-4d45-a2bf-594d0838070d"; Type = "Scope"},
        @{PermissionID = "ed4fca05-be46-441f-9803-1873825f8fdb"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityAnalyzedMessage.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "53e6783e-b127-4a35-ab3a-6a52d80a9077"; Type = "Scope"},
        @{PermissionID = "b48f7ac2-044d-4281-b02f-75db744d6f5f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityAnalyzedMessage.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "48eb8c83-6e58-46e7-a6d3-8805822f5940"; Type = "Scope"},
        @{PermissionID = "04c55753-2244-4c25-87fc-704ab82a4f69"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityEvents.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "64733abd-851e-478a-bffb-e47a14b18235"; Type = "Scope"},
        @{PermissionID = "bf394140-e372-4bf9-a898-299cfc7564e5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityEvents.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6aedf524-7e1c-45a7-bd76-ded8cab8d0fc"; Type = "Scope"},
        @{PermissionID = "d903a879-88e0-4c09-b0c9-82f6a1333f84"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityIdentitiesHealth.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a0d0da43-a6df-4416-b63d-99c79991aae8"; Type = "Scope"},
        @{PermissionID = "f8dcd971-5d83-4e1e-aa95-ef44611ad351"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityIdentitiesHealth.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "53e51eec-2d9b-4990-97f3-c9aa5d5652c3"; Type = "Scope"},
        @{PermissionID = "ab03ddd5-7ae4-4f2e-8af8-86654f7e0a27"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityIncident.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b9abcc4f-94fc-4457-9141-d20ce80ec952"; Type = "Scope"},
        @{PermissionID = "45cc0394-e837-488b-a098-1918f48d186c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SecurityIncident.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "128ca929-1a19-45e6-a3b8-435ec44a36ba"; Type = "Scope"},
        @{PermissionID = "34bf0e97-1971-4929-b999-9e2442d941d7"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ServiceActivity-Exchange.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1fe7aa48-9373-4a47-8df3-168335e0f4c9"; Type = "Scope"},
        @{PermissionID = "2b655018-450a-4845-81e7-d603b1ebffdb"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ServiceActivity-Microsoft365Web.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d74c75b1-d5a9-479d-902d-92f8f99182c1"; Type = "Scope"},
        @{PermissionID = "c766cb16-acc4-4663-ba09-6eedef5876c5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ServiceActivity-OneDrive.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "347e3c16-30f3-4ac7-9b52-fc3c053de9c9"; Type = "Scope"},
        @{PermissionID = "57b4f899-b8c5-47c7-bdd3-c410c55602b7"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ServiceActivity-Teams.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "404d76f0-e10e-460a-92be-ef19600c54d1"; Type = "Scope"},
        @{PermissionID = "4dfee10b-fa4a-41b5-b34d-ccf54cc0c394"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ServiceHealth.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "55896846-df78-47a7-aa94-8d3d4442ca7f"; Type = "Scope"},
        @{PermissionID = "79c261e0-fe76-4144-aad5-bdc68fbe4037"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ServiceMessage.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "eda39fa6-f8cf-4c3c-a909-432c683e4c9b"; Type = "Scope"},
        @{PermissionID = "1b620472-6534-4fe6-9df2-4680e8aa28ec"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ServiceMessageViewpoint.Write"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "636e1b0b-1cc2-4b1c-9aa9-4eeed9b9761b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ServicePrincipalEndpoint.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9f9ce928-e038-4e3b-8faf-7b59049a8ddc"; Type = "Scope"},
        @{PermissionID = "5256681e-b7f6-40c0-8447-2d9db68797a0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ServicePrincipalEndpoint.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7297d82c-9546-4aed-91df-3d4f0a9b3ff0"; Type = "Scope"},
        @{PermissionID = "89c8469c-83ad-45f7-8ff2-6e3d4285709e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SharePointTenantSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2ef70e10-5bfd-4ede-a5f6-67720500b258"; Type = "Scope"},
        @{PermissionID = "83d4163d-a2d8-4d3b-9695-4ae3ca98f888"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SharePointTenantSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "aa07f155-3612-49b8-a147-6c590df35536"; Type = "Scope"},
        @{PermissionID = "19b94e34-907c-4f43-bde9-38b1909ed408"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ShortNotes.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "50f66e47-eb56-45b7-aaa2-75057d9afe08"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ShortNotes.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "0c7d31ec-31ca-4f58-b6ec-9950b6b0de69"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ShortNotes.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "328438b7-4c01-4c07-a840-e625a749bb89"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ShortNotes.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "842c284c-763d-4a97-838d-79787d129bab"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Sites.FullControl.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5a54b8b3-347c-476d-8f8e-42d5c7424d29"; Type = "Scope"},
        @{PermissionID = "a82116e5-55eb-4c41-a434-62fe8a61c773"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Sites.Manage.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "65e50fdc-43b7-4915-933e-e8138f11f40a"; Type = "Scope"},
        @{PermissionID = "0c0bf378-bf22-4481-8f81-9e89a9b4960a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Sites.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "205e70e5-aba6-4c52-a976-6d2d46c48043"; Type = "Scope"},
        @{PermissionID = "332a536c-c7ef-4017-ab91-336970924f0d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Sites.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "89fe6a52-be36-487e-b7d8-d061c450a026"; Type = "Scope"},
        @{PermissionID = "9492366f-7969-46a4-8d15-ed1a20078fff"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Sites.Selected"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f89c84ef-20d0-4b54-87e9-02e856d66d53"; Type = "Scope"},
        @{PermissionID = "883ea226-0bf2-4a8f-9f9d-92c9162a727d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SMTP.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "258f6531-6087-4cc4-bb90-092c5fb3ed3f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SpiffeTrustDomain.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9b4aa4b1-aaf3-41b7-b743-698b27e77ff6"; Type = "Scope"},
        @{PermissionID = "dcdfc277-41fd-4d68-ad0c-c3057235bd8e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SpiffeTrustDomain.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8ba47079-8c47-4bfe-b2ce-13f28ef37247"; Type = "Scope"},
        @{PermissionID = "17b78cfd-eeff-447d-8bab-2795af00055a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SubjectRightsRequest.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9c3af74c-fd0f-4db4-b17a-71939e2a9d77"; Type = "Scope"},
        @{PermissionID = "ee1460f0-368b-4153-870a-4e1ca7e72c42"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SubjectRightsRequest.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2b8fcc74-bce1-4ae3-a0e8-60c53739299d"; Type = "Scope"},
        @{PermissionID = "8387eaa4-1a3c-41f5-b261-f888138e6041"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Subscription.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5f88184c-80bb-4d52-9ff2-757288b2e9b7"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Synchronization.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7aa02aeb-824f-4fbe-a3f7-611f751f5b55"; Type = "Scope"},
        @{PermissionID = "5ba43d2f-fa88-4db2-bd1c-a67c5f0fb1ce"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Synchronization.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7bb27fa3-ea8f-4d67-a916-87715b6188bd"; Type = "Scope"},
        @{PermissionID = "9b50c33d-700f-43b1-b2eb-87e89b703581"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/SynchronizationData-User.Upload"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1a2e7420-4e92-4d2b-94cb-fb2952e9ddf7"; Type = "Scope"},
        @{PermissionID = "db31e92a-b9ea-4d87-bf6a-75a37a9ca35a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Tasks.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f45671fb-e0fe-4b4b-be20-3d3ce43f1bcb"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Tasks.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f10e1f91-74ed-437f-a6fd-d6ae88e26c1f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Tasks.Read.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "88d21fd4-8e5a-4c32-b5e2-4a1c95f34f72"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Tasks.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2219042f-cab5-40cc-b0d2-16b1540b4c5f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Tasks.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "44e666d1-d276-445b-a5fc-8815eeb81d55"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Tasks.ReadWrite.Shared"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c5ddf11b-c114-4886-8558-8a4e557cd52b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Team.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7825d5d6-6049-4ce7-bdf6-3b8d53f4bcd0"; Type = "Scope"},
        @{PermissionID = "23fc2474-f741-46ce-8465-674744c5c361"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Team.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "485be79e-c497-4b35-9400-0e3fa7f2a5d4"; Type = "Scope"},
        @{PermissionID = "2280dda6-0bfd-44ee-a2f4-cb867cfc4c1e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamMember.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2497278c-d82d-46a2-b1ce-39d4cdde5570"; Type = "Scope"},
        @{PermissionID = "660b7406-55f1-41ca-a0ed-0b035e182f3e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamMember.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4a06efd2-f825-4e34-813e-82a57b03d1ee"; Type = "Scope"},
        @{PermissionID = "0121dc95-1b9f-4aed-8bac-58c5ac466691"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamMember.ReadWriteNonOwnerRole.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2104a4db-3a2f-4ea0-9dba-143d457dc666"; Type = "Scope"},
        @{PermissionID = "4437522e-9a86-4a41-a7da-e380edd4a97d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsActivity.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0e755559-83fb-4b44-91d0-4cc721b9323e"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsActivity.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "70dec828-f620-4914-aa83-a29117306807"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsActivity.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7ab1d787-bae7-4d5d-8db6-37ea32df9186"; Type = "Scope"},
        @{PermissionID = "a267235f-af13-44dc-8385-c1dc93023186"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "bf3fbf03-f35f-4e93-963e-47e4d874c37a"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "cc7e7635-2586-41d6-adaa-a8d3bcad5ee5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "5248dcb1-f83b-4ec3-9f4d-a4428a961a72"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1f615aea-6bf9-4b05-84bd-46388e138537"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c395395c-ff9a-4dba-bc1f-8372ba9dca84"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9ce09611-f4f7-4abd-a629-a05450422a97"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e1408a66-8f82-451b-a2f3-3c3e38f7413f"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6e74eff9-4a21-45d6-bc03-3a20f61f8281"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "946349d5-2a9d-4535-abc0-7beeacaedd1d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b0c13be0-8e20-4bc5-8c55-963c23a39ce9"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2da62c49-dfbd-40df-ba16-fef3529d391c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "32ca478f-f89e-41d0-aaf8-101deb7da510"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a0e0e18b-8fb2-458f-8130-da2d7cab9c75"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "ba1ba90b-2d8f-487e-9f16-80728d85bb5c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "4a6bbf29-a0e1-4a4d-a7d1-cef17f772975"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1e4be56c-312e-42b8-a2c9-009600d732c0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7a349935-c54d-44ab-ab66-1b460d315be7"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteAndConsentSelfForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a87076cf-6abd-4e56-8559-4dbdf41bef96"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "aa85bf13-d771-4d5d-a9e6-bca04ce44edf"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9e19bae1-2623-4c4f-ab6e-2664615ff9a0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2e25a044-2580-450d-8859-42eeb6e996c0"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "5dad17ba-f6cc-4954-a5a2-a0dcc95154f0"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "093f8818-d05f-49b8-95bc-9d2a73e9a43c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "74ef0291-ca83-4d02-8c7e-d2391e6a444f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0ce33576-30e8-43b7-99e5-62f8569a4002"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "73a45059-f39c-4baf-9182-4954ac0e55cf"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0f4595f7-64b1-4e13-81bc-11a249df07a9"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9f67436c-5415-4e7f-8ac1-3014a7132630"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "207e0cb1-3ce7-4922-b991-5a760c346ebc"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsAppInstallation.ReadWriteSelfForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "908de74d-f8b2-4d6b-a9ed-2a17b3b78179"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "48638b3c-ad68-4383-8ac4-e6880ee6ca57"; Type = "Scope"},
        @{PermissionID = "242607bd-1d2c-432c-82eb-bdb27baa23ab"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "39d65650-9d3e-4223-80db-a335590d027e"; Type = "Scope"},
        @{PermissionID = "bdd80a03-d9bc-451d-b7c4-ce7c63fe3c8f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.Create"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a9ff19c2-f369-4a95-9a25-ba9d460efc8e"; Type = "Scope"},
        @{PermissionID = "49981c42-fd7b-4530-be03-e77b21aed25e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "59dacb05-e88d-4c13-a684-59f1afc8cc98"; Type = "Scope"},
        @{PermissionID = "46890524-499a-4bb2-ad64-1476b4f3e1cf"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b98bfd41-87c6-45cc-b104-e2de4f0dafb9"; Type = "Scope"},
        @{PermissionID = "a96d855f-016b-47d7-b51c-1218a98d791c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ee928332-e9c2-4747-b4a0-f8c164b68de6"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "fd9ce730-a250-40dc-bd44-8dc8d20f39ea"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c975dd04-a06e-4fbb-9704-62daad77bb49"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6163d4f4-fbf8-43da-a7b4-060fe85ed148"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "c37c9b61-7762-4bff-a156-afc0005847a0"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "425b4b59-d5af-45c8-832f-bb0b7402348a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForChat"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "0c219d04-3abf-47f7-912d-5cca239e90e6"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForChat.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "9f62e4a2-a2d6-4350-b28b-d244728c4f86"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForTeam"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f266662f-120a-4314-b26a-99b08617c7ef"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForTeam.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "91c32b81-0ef0-453f-a5c7-4ce2e562f449"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForUser"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "395dfec1-a0b9-465f-a783-8250a430cb8c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamsTab.ReadWriteSelfForUser.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "3c42dec6-49e8-4a0a-b469-36cff0d9da93"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamTemplates.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cd87405c-5792-4f15-92f7-debc0db6d1d6"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamTemplates.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "6323133e-1f6e-46d4-9372-ac33a0870636"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Teamwork.Migrate.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "dfb0dd15-61de-45b2-be36-d6a69fba3c79"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Teamwork.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "594f4bb6-c083-4cf9-8aa8-213823bdf351"; Type = "Scope"},
        @{PermissionID = "75bcfbce-a647-4fba-ad51-b63d73b210f4"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamworkAppSettings.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "44e060c4-bbdc-4256-a0b9-dcc0396db368"; Type = "Scope"},
        @{PermissionID = "475ebe88-f071-4bd7-af2b-642952bd4986"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamworkAppSettings.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "87c556f0-2bd9-4eed-bd74-5dd8af6eaf7e"; Type = "Scope"},
        @{PermissionID = "ab5b445e-8f10-45f4-9c79-dd3f8062cc4e"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamworkDevice.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b659488b-9d28-4208-b2be-1c6652b3c970"; Type = "Scope"},
        @{PermissionID = "0591bafd-7c1c-4c30-a2a5-2b9aacb1dfe8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamworkDevice.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ddd97ecb-5c31-43db-a235-0ee20e635c40"; Type = "Scope"},
        @{PermissionID = "79c02f5b-bd4f-4713-bc2c-a8a4a66e127b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamworkTag.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "57587d0b-8399-45be-b207-8050cec54575"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamworkTag.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "b74fd6c4-4bde-488e-9695-eeb100e4907f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamworkTag.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "539dabd7-b5b6-4117-b164-d60cd15a8671"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamworkTag.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "a3371ca5-911d-46d6-901c-42c8c7a937d8"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TeamworkUserInteraction.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b4d26916-07e0-4daf-9096-9f6d9174aa96"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TermStore.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "297f747b-0005-475b-8fef-c890f5152b38"; Type = "Scope"},
        @{PermissionID = "ea047cc2-df29-4f3e-83a3-205de61501ca"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TermStore.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6c37c71d-f50f-4bff-8fd3-8a41da390140"; Type = "Scope"},
        @{PermissionID = "f12eb8d6-28e3-46e6-b2c0-b7e4dc69fc95"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatAssessment.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "f8f035bb-2cce-47fb-8bf5-7baf3ecbee48"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatAssessment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "cac97e40-6730-457d-ad8d-4852fddab7ad"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatHunting.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b152eca8-ea73-4a48-8c98-1a6742673d99"; Type = "Scope"},
        @{PermissionID = "dd98c7f5-2d42-42d3-a0e4-633161547251"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatIndicators.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "9cc427b4-2004-41c5-aa22-757b755e9796"; Type = "Scope"},
        @{PermissionID = "197ee4e9-b993-4066-898f-d6aecc55125b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatIndicators.ReadWrite.OwnedBy"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "91e7d36d-022a-490f-a748-f8e011357b42"; Type = "Scope"},
        @{PermissionID = "21792b6c-c986-4ffc-85de-df9da54b52fa"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatIntelligence.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f266d9c0-ccb9-4fb8-a228-01ac0d8d6627"; Type = "Scope"},
        @{PermissionID = "e0b77adb-e790-44a3-b0a0-257d06303687"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatSubmission.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "fd5353c6-26dd-449f-a565-c4e16b9fce78"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatSubmission.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7083913a-4966-44b6-9886-c5822a5fd910"; Type = "Scope"},
        @{PermissionID = "86632667-cd15-4845-ad89-48a88e8412e1"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatSubmission.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "68a3156e-46c9-443c-b85c-921397f082b5"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatSubmission.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "8458e264-4eb9-4922-abe9-768d58f13c7f"; Type = "Scope"},
        @{PermissionID = "d72bdbf4-a59b-405c-8b04-5995895819ac"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/ThreatSubmissionPolicy.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "059e5840-5353-4c68-b1da-666a033fc5e8"; Type = "Scope"},
        @{PermissionID = "926a6798-b100-4a20-a22f-a4918f13951d"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/Topic.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "79c4c76f-409a-4f98-884d-e2c09291ec26"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TrustFrameworkKeySet.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7ad34336-f5b1-44ce-8682-31d7dfcd9ab9"; Type = "Scope"},
        @{PermissionID = "fff194f1-7dce-4428-8301-1badb5518201"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/TrustFrameworkKeySet.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "39244520-1e7d-4b4a-aee0-57c65826e427"; Type = "Scope"},
        @{PermissionID = "4a771c9a-1cf2-4609-b88e-3d3e02d539cd"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UnifiedGroupMember.Read.AsGuest"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "73e75199-7c3e-41bb-9357-167164dbb415"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User.EnableDisableAccount.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f92e74e7-2563-467f-9dd0-902688cb5863"; Type = "Scope"},
        @{PermissionID = "3011c876-62b7-4ada-afa2-506cbbecc68c"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User.Export.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "405a51b5-8d8d-430b-9842-8be4b0e9f324"; Type = "Scope"},
        @{PermissionID = "405a51b5-8d8d-430b-9842-8be4b0e9f324"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User.Invite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "63dd7cd9-b489-4adf-a28c-ac38b9a0f962"; Type = "Scope"},
        @{PermissionID = "09850681-111b-4a89-9bed-3f2cae46d706"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User.ManageIdentities.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "637d7bec-b31e-4deb-acc9-24275642a2c9"; Type = "Scope"},
        @{PermissionID = "c529cfca-c91b-489c-af2b-d92990b66ce6"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "a154be20-db9c-4678-8ab7-66f6cc099a59"; Type = "Scope"},
        @{PermissionID = "df021288-bdef-4463-88db-98f22de89214"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User.ReadBasic.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b340eb25-3456-403f-be2f-af7a0d370277"; Type = "Scope"},
        @{PermissionID = "97235f07-e226-4f63-ace3-39588e11d3a1"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b4e74841-8e56-480b-be8b-910348b18b4c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "204e0828-b5ca-4ad8-b9f3-f32a958e7cc4"; Type = "Scope"},
        @{PermissionID = "741f803b-c850-494e-b5df-cde7c675a1ca"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserActivity.ReadWrite.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "47607519-5fb1-47d9-99c7-da4b48f369b1"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserAuthenticationMethod.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "1f6b61c5-2f65-4135-9c9f-31c0f8d32b52"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserAuthenticationMethod.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "aec28ec7-4d02-4e8c-b864-50163aea77eb"; Type = "Scope"},
        @{PermissionID = "38d9df27-64da-44fd-b7c5-a6fbac20248f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserAuthenticationMethod.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "48971fc1-70d7-4245-af77-0beb29b53ee2"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserAuthenticationMethod.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "b7887744-6746-4312-813d-72daeaee7e2d"; Type = "Scope"},
        @{PermissionID = "50483e42-d915-4231-9639-7fdb7fd190e5"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User-ConvertToInternal.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "550e695c-7511-40f4-ac79-e8fb9c82552d"; Type = "Scope"},
        @{PermissionID = "9d952b72-f741-4b40-9185-8c53076c2339"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User-LifeCycleInfo.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "ed8d2a04-0374-41f1-aefe-da8ac87ccc87"; Type = "Scope"},
        @{PermissionID = "8556a004-db57-4d7a-8b82-97a13428e96f"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/User-LifeCycleInfo.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "7ee7473e-bd4b-4c9f-987c-bd58481f5fa2"; Type = "Scope"},
        @{PermissionID = "925f1248-0f97-47b9-8ec8-538c54e01325"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserNotification.ReadWrite.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "26e2f3e8-b2a1-47fc-9620-89bb5b042024"; Type = "Scope"},
        @{PermissionID = "4e774092-a092-48d1-90bd-baad67c7eb47"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserShiftPreferences.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "de023814-96df-4f53-9376-1e2891ef5a18"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserShiftPreferences.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "d1eec298-80f3-49b0-9efb-d90e224798ac"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserTeamwork.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "834bcc1c-762f-41b0-bb91-1cdc323ee4bf"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserTeamwork.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "fbcd7ef1-df0d-4e05-bb28-93424a89c6df"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/UserTimelineActivity.Write.CreatedByApp"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "367492fc-594d-4972-a9b5-0d58c622c91c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/VirtualAppointment.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "27470298-d3b8-4b9c-aad4-6334312a3eac"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/VirtualAppointment.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "d4f67ec2-59b5-4bdc-b4af-d78f6f9c1954"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/VirtualAppointment.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "2ccc2926-a528-4b17-b8bb-860eed29d64c"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/VirtualAppointment.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "bf46a256-f47d-448f-ab78-f226fff08d40"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/VirtualAppointmentNotification.Send"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "20d02fff-a0ef-49e7-a46e-019d4a6523b7"; Type = "Scope"},
        @{PermissionID = "97e45b36-1250-48e4-bd70-2df6dab7e94a"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/VirtualEvent.Read"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "6b616635-ae58-433a-a918-8c45e4f304dc"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/VirtualEvent.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "1dccb351-c4e4-4e09-a8d1-7a9ecbf027cc"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/VirtualEvent.ReadWrite"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "d38d189c-e29b-4344-8b3b-829bfa81380b"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/VirtualEventRegistration-Anon.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "-"; Type = "Scope"},
        @{PermissionID = "23211fc1-f9d1-4e8e-8e9e-08a5d0a109bb"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/WindowsUpdates.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "11776c0c-6138-4db3-a668-ee621bea2555"; Type = "Scope"},
        @{PermissionID = "7dd1be58-6e76-4401-bf8d-31d1e8180d5b"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/WorkforceIntegration.Read.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "f1ccd5a7-6383-466a-8db8-1a656f7d06fa"; Type = "Scope"},
        @{PermissionID = "-"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/WorkforceIntegration.ReadWrite.All"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "08c4b377-0d23-4a8b-be2a-23c1c1d88545"; Type = "Scope"},
        @{PermissionID = "202bf709-e8e6-478e-bcfd-5d63c50b68e3"; Type = "Role"}
        )
    },
	@{
    Name = "https://graph.microsoft.com/In this article"
    ResourceAppID = "00000003-0000-0000-c000-000000000000"
    TypeID = @(
        @{PermissionID = "08c4b377-0d23-4a8b-be2a-23c1c1d88545"; Type = "Scope"},
        @{PermissionID = "202bf709-e8e6-478e-bcfd-5d63c50b68e3"; Type = "Role"}
        )
    }
) #Close of APIDefs







    ######################



        $APIPermissions = @()
foreach ($CurrDef in $DefList) {
    $TempDef = $APIDefs | Where-Object -FilterScript {$_.Name -eq "https://graph.microsoft.com/$($CurrDef.Name)"}


    $APIPermissions += @{
        Name =  $TempDef.Name
        ResourceAppID = $TempDef.ResourceAppID
        PermissionID = ($TempDef.TypeID | Where-Object -FilterScript {$_.Type -eq "$($CurrDef.Type)"}).PermissionID
        Type = "$($CurrDef.Type)"
    }
}
return $APIPermissions