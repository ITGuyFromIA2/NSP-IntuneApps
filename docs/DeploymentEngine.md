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

`Get-NSPIntuneAppInventory -Connect` performs delegated interactive authentication with `DeviceManagementApps.ReadWrite.All`, reads Win32 app identity/state into a local ignored JSON file, and makes no tenant changes on its own. It deliberately requests the same scope every other stage of the deployment flow needs (rather than the narrower `Read.All`), since MSAL treats a different scope string as new consent and reprompts even mid-session; sharing one scope across the flow is what lets a single login cover inventory, notes PATCH, and content update together. `Update-NSPAppDeploymentPlan` resolves that saved inventory against a tracker, allowing inventory and planning to be reviewed or repeated without holding a live Graph session.

### Implemented: the Create path

The `Create` action is implemented end to end and **verified against a real test tenant** using `Apps/VCred`: its run journal completed all six stages with zero failures, and the created app's Notes field carried all three `[NSP-...]` marker lines.

- `Register-NSPIntuneWin32AppRegistration` is a one-time, plan-only-by-default tenant bootstrap. With `-Execute` it registers the `NSP-IntuneApps-Win32AppDeployment` Azure AD application, grants org-wide admin consent for the four Graph permissions `IntuneWin32App` needs, and records `Config/Local/GraphAppRegistration.json` (TenantId, TenantDomain, ClientId; no secret, since `IntuneWin32App`'s delegated flow needs only the public ClientID). `TenantDomain` is the tenant's default verified domain, resolved via a plain `GET /organization` call so the record and console output are identifiable by more than a bare GUID; a lookup failure there is non-fatal and just leaves it empty. `-TenantId` is optional — it is read from the connected Graph context; pass it only to fail fast if you land in the wrong tenant. It also asserts the Windows broker (WAM) redirect URI `ms-appx-web://Microsoft.AAD.BrokerPlugin/<ClientId>` is registered - required the moment `Connect-MgGraph` authenticates as this app instead of a Microsoft-owned default one (see the login-sharing note below), or sign-in fails with `AADSTS50011`. A registration created before this fix repairs itself the next time this function runs with `-Execute`.
- `Invoke-NSPAppDeploymentRunStage -RunPath <run>` advances a run journal by exactly one stage, plan-only by default. With `-Execute` it dispatches: `ValidatePlan` (re-verifies the source hashes haven't drifted since planning), `Build`/`Sign` (`New-NSPAppPackage`/`Set-NSPAppSignature`, both local/offline), `Package` (a no-op — the package already exists from the `Build` stage; `Package` is not adjacent to `Build` in the stage list, since `Sign` sits between them), `CreateApp` (`New-NSPIntuneWin32App`, the one function that writes to the tenant — it creates the Win32 app via `IntuneWin32App`'s own delegated session, then immediately PATCHes the deterministic `ManagementNotes` block via a separate `Microsoft.Graph.Authentication` session), and `RecordManagementNotes` (a no-op — the PATCH already happened as part of `CreateApp`).
- Stages belonging to `UpdateMetadataInPlace` or `CreateSupersedingApp` (`PatchMetadata`, `AddSupersedence`) fail immediately with an explicit "not yet implemented in this executor" message rather than being guessed at. This is the current boundary of the executor, not a silent gap.
- No assignment is created by any of the above; assignment remains a separate reviewed operation, matching the existing `AssignmentColl` preflight rule.

Two real defects surfaced only by the live run, both now fixed: `Get-NSPIntuneAppInventory`'s Graph query used an invalid OData path-segment type cast (`/mobileApps/microsoft.graph.win32LobApp`) instead of `$filter=isof('microsoft.graph.win32LobApp')`, and `committedContentVersion` needed the `microsoft.graph.win32LobApp/` cast prefix in `$select` since it isn't a property of the base `mobileApp` type. Separately, `New-NSPCodeSigningCertificate` generated certificates with Basic Constraints `ca=TRUE` (CA) instead of `ca=FALSE` (end entity); a CA-flagged certificate fails Authenticode signing with `TRUST_E_BASIC_CONSTRAINTS` ("A certificate's basic constraint extension has not been observed"). The live run also exposed a defect in the VCred catalog entry itself, not the executor: its detection script dot-sourced sibling files (`VCred.Runtime.ps1`, `VCred.config.json`) that exist in the full package, but Intune ships a custom-script detection rule to the client as one standalone file with no siblings — unlike install/uninstall, which run from the fully extracted package. `Detect_VCred.ps1` is now self-contained; the orphaned sibling files were removed from `Detect/` (the `Source/` copies remain, since install/uninstall genuinely do run from the extracted package).

### Implemented: the UpdateContentInPlace path

`UpdateContentInPlace` (compatible package content changed, no breaking install/detection contract, existing object ID preserved) reuses `Build`/`Sign`/`Package` from the Create path and adds two new stages:

- `Update-NSPIntuneWin32AppContent` is the `UploadContent`/`CommitContent` stages: `Update-IntuneWin32AppPackageFile` performs the content-version upload and commit as one call, so `CommitContent` is its own no-op stage transition, matching how `Package` is already folded into `Build`'s own output.
- `Set-NSPAppManagementNotes` is `RecordManagementNotes` — unlike Create, this does real work here (a direct PATCH of the recomputed `ManagementNotes` block), since no earlier stage in this path already touches the object's Notes field.

`UpdateMetadataInPlace` and `CreateSupersedingApp` (`PatchMetadata`, `AddSupersedence`) remain not yet implemented.

### Assignment management (V1: AND-chain filters only)

No path elsewhere in this document creates or modifies an app assignment - assignment is a deliberately separate, reviewed operation (the `AssignmentColl` preflight rule already blocks embedded targeting in app settings). This is now implemented as its own family of tools:

- `Get-NSPIntuneAppAssignmentInventory` (read-only): harvests every Win32 app's current assignments (group, intent, any filter) plus every assignment filter defined in the tenant, so groups/filters already in real use can be picked instead of hand-typed object IDs. Assignment filters need the `beta` Graph endpoint, not `v1.0` (`v1.0` returns "Resource not found for the segment 'assignmentFilters'").
- `Find-NSPIntuneGroup` (read-only): live substring search across every tenant group (`$filter=contains(displayName,...)` with `ConsistencyLevel: eventual`), for picking a group that was never previously used for an assignment - the harvested list above only covers groups already in use.
- `Get-NSPIntuneEnrollmentProfileNames` (read-only): Windows Autopilot deployment profile names, for a picklist when a filter clause targets `device.enrollmentProfileName` instead of hand-typing a profile name. Android/Apple enrollment profile sources are a separate Graph surface and are not yet covered.
- `Build-NSPAssignmentFilterRule` (private, pure/offline): assembles one or more clauses (`Property`, `Operator`, `Value`) into a valid Intune filter rule string, joined with `and`. **V1 scope is AND-chains only** - real tenant filters can mix `and`/`or` with explicit parenthesized grouping (e.g. Android enrollment-profile filters routinely do), which this does not yet build; that's a planned, not accidental, gap.
- `New-NSPIntuneAssignmentFilter`: creates a filter from `-Clauses` (via the builder above) or a hand-authored `-Rule` string, plan-only by default.
- `New-NSPIntuneWin32AppAssignment`: assigns an app to a group (Include/Exclude, with intent), optionally scoped by an existing filter (Intune does not allow filters on Exclude assignments). Wraps `IntuneWin32App`'s `Add-IntuneWin32AppAssignmentGroup`, plan-only by default.

Registering an app for the first time now also requests `DeviceManagementServiceConfig.ReadWrite.All` (needed for the enrollment-profile lookup); `Register-NSPIntuneWin32AppRegistration` self-repairs an existing registration's admin consent the same way it already self-repairs the broker redirect URI - `NeedsPermissionRepair`/`PermissionsRepaired` alongside `NeedsRedirectUriRepair`/`RedirectUriRepaired`.

The dashboard exposes this as `[13]` (save the assignment/filter inventory), `[14]` (assign an app to a group, with the group picked from the harvested "already used" list or a live wildcard search, and an optional existing filter), and `[15]` (a guided clause-by-clause filter builder, with the enrollment-profile picklist above wired in for that one property).

`Start-NSPIntuneApps.ps1`'s dashboard exposes stage advancement as "Advance the next stage of a saved run" (`[10]`): it always previews the next app/stage first, then offers execute-one-stage, auto-advance-every-remaining-stage (no per-stage confirm — clearly labeled for test-tenant use, since it still performs real tenant writes), or cancel. `[6]`'s tracker builder shows a numbered catalog picker so a batch can be built by number as well as by name. `[11]` exposes `Register-NSPIntuneWin32AppRegistration` directly from the dashboard.

### Reducing sign-ins further: reusing the registered app

`Connect-NSPGraph` accepts `-ClientId`/`-TenantId`: when the caller knows the recorded `NSP-IntuneApps-Win32AppDeployment` registration (`Get-NSPIntuneAppInventory`, `Set-NSPAppManagementNotes`, and `New-NSPIntuneWin32App`'s notes-PATCH session all read it from `Config/Local/GraphAppRegistration.json` when present), it authenticates as that app instead of the Microsoft Graph PowerShell SDK's own default multi-tenant app. Since that app already carries org-wide admin consent for everything this tool needs, Azure AD recognizes it as pre-consented and can pass through silently instead of prompting - the same reason `IntuneWin32App`'s `Connect-MSIntuneGraph` reprompts less once it's used consistently. This does not merge the two into one login (they remain separate auth stacks with separate token caches), but it removes the per-differing-scope reprompting within each stack.

### Deliberate app deletion

`Remove-NSPIntuneWin32App` (plan-only by default, `-Execute`-gated like everything else that writes) permanently deletes a Win32 app via `IntuneWin32App`'s `Remove-IntuneWin32App`. It is never called automatically by planning or execution - automatic delete/recreate as an update mechanism remains excluded by design. It exists for genuine, human-confirmed cleanup (retiring a test-tenant app, or an old superseded object once its replacement is confirmed working), and pairs with `New-NSPIntuneWin32App` as two separate, separately reviewed steps rather than one combined "replace" operation. The dashboard's `[12]` additionally requires typing the app's exact display name before it will pass `-Execute`, on top of the usual explicit gate, given how irreversible this one is.
