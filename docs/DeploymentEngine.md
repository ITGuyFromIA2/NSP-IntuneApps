# Win32 app deployment engine contract

The replacement for the Gen1 uploader is an inventory-and-plan engine. It never treats delete/recreate as an update operation.

## Stable identity

Each NSP-managed Intune app records three machine-readable lines in its Notes field:

```text
[NSP-IntuneApps:<source id>]
[NSP-Metadata-SHA256:<64-character hash>]
[NSP-Content-SHA256:<64-character hash>]
```

The source ID is the primary identity. Display name and publisher are only a discovery fallback for an older, unmarked app. A fallback match results in `AdoptOrReview`, never automatic ownership. Duplicate source IDs result in `Conflict` and stop that app.

## Planned actions

| Condition | Action | Existing object ID |
|---|---|---|
| No match | `Create` | New object |
| Hashes match | `NoChange` | Preserved |
| Metadata only changed | `UpdateMetadataInPlace` | Preserved |
| Compatible package content changed | `UpdateContentInPlace` | Preserved |
| Install/detection/uninstall contract is declared breaking | `CreateSupersedingApp` | Old object retained and related |
| Unmarked fallback match | `AdoptOrReview` | No write until approved |
| Multiple matches | `Conflict` | No write |

Microsoft Graph v1.0 exposes Win32 app property updates and content-version relationships. New content can be committed to an app through its content-version/file resources, so a routine package refresh does not inherently require deleting the app. See Microsoft Learn: [win32LobApp resource](https://learn.microsoft.com/graph/api/resources/intune-apps-win32lobapp?view=graph-rest-1.0) and [commit content file](https://learn.microsoft.com/graph/api/intune-apps-mobileappcontentfile-commit?view=graph-rest-1.0).

Side-by-side creation is reserved for a breaking contract change. The new app may supersede the old app as an update or replacement after the operator reviews the uninstall behavior. Intune limits a supersedence graph to ten nodes, so execution must inspect the graph before adding a relationship. See [Add and assign Win32 apps](https://learn.microsoft.com/mem/intune-service/apps/apps-win32-add#step-6-supersedence).

## Execution gates

The future executor must verify tenant/account, show the resolved object and assignments, require an approved tracker entry, execute one app at a time, and persist the result after each app. Metadata PATCH, content upload, assignment mutation, relationship creation, and cleanup are separate recorded operations. Cleanup of an old superseded object is never implied by deployment.

`Resolve-NSPAppDeploymentAction` implements the pure, offline decision portion of this contract. It makes no Graph calls and performs no writes.

`Get-NSPIntuneAppInventory -Connect` performs delegated interactive authentication with `DeviceManagementApps.Read.All`, reads Win32 app identity/state into a local ignored JSON file, and makes no tenant changes. `Update-NSPAppDeploymentPlan` resolves that saved inventory against a tracker, allowing inventory and planning to be reviewed or repeated without holding a live Graph session.
