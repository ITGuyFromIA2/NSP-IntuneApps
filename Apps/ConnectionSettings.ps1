throw @'
The Gen1 connection bootstrap is intentionally disabled. It previously depended on
tenant-specific GraphInfo.ps1 values and legacy Intune/AzureAD connection modules.
Use the delegated, interactive, least-privilege inventory and plan commands exported
by NSP.IntuneApps. No tenant identity or application ID belongs in this source file.
'@
