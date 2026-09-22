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

The executor must verify tenant/account, show the resolved object and assignments, require an approved tracker entry, execute one app at a time, and persist the result after each app. Metadata PATCH, content upload, assignment mutation, relationship creation, and cleanup are separate recorded operations. Cleanup of an old superseded object is never implied by deployment.

`Resolve-NSPAppDeploymentAction` implements the pure, offline decision portion of this contract. It makes no Graph calls and performs no writes.

`Get-NSPIntuneAppInventory -Connect` performs delegated interactive authentication with `DeviceManagementApps.Read.All`, reads Win32 app identity/state into a local ignored JSON file, and makes no tenant changes. `Update-NSPAppDeploymentPlan` resolves that saved inventory against a tracker, allowing inventory and planning to be reviewed or repeated without holding a live Graph session.

### Implemented: the Create path

The `Create` action is implemented end to end, proven against `Apps/VCred` on a test tenant:

- `Register-NSPIntuneWin32AppRegistration` is a one-time, plan-only-by-default tenant bootstrap. With `-Execute` it registers the `NSP-IntuneApps-Win32AppDeployment` Azure AD application, grants org-wide admin consent for the four Graph permissions `IntuneWin32App` needs, and records `Config/Local/GraphAppRegistration.json` (TenantId, ClientId; no secret, since `IntuneWin32App`'s delegated flow needs only the public ClientID).
- `Invoke-NSPAppDeploymentRunStage -RunPath <run>` advances a run journal by exactly one stage, plan-only by default. With `-Execute` it dispatches: `ValidatePlan` (re-verifies the source hashes haven't drifted since planning), `Build`/`Sign` (`New-NSPAppPackage`/`Set-NSPAppSignature`, both local/offline), `Package` (a no-op — the package already exists from the `Build` stage; `Package` is not adjacent to `Build` in the stage list, since `Sign` sits between them), `CreateApp` (`New-NSPIntuneWin32App`, the one function that writes to the tenant — it creates the Win32 app via `IntuneWin32App`'s own delegated session, then immediately PATCHes the deterministic `ManagementNotes` block via a separate `Microsoft.Graph.Authentication` session), and `RecordManagementNotes` (a no-op — the PATCH already happened as part of `CreateApp`).
- Stages belonging to `UpdateMetadataInPlace`, `UpdateContentInPlace`, or `CreateSupersedingApp` (`PatchMetadata`, `UploadContent`, `CommitContent`, `AddSupersedence`) fail immediately with an explicit "not yet implemented in this executor" message rather than being guessed at. This is the current boundary of the executor, not a silent gap.
- No assignment is created by any of the above; assignment remains a separate reviewed operation, matching the existing `AssignmentColl` preflight rule.

`Start-NSPIntuneApps.ps1`'s dashboard exposes this as "Advance the next stage of a saved run": it always previews the next app/stage first and only passes `-Execute` after an explicit `[Y/N]` confirmation.
