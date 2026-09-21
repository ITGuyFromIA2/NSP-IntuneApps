# Deployment executor implementation plan (handoff)

This is an approved, not-yet-implemented plan for the Phase 4 deployment executor, written on
the disposable test VM (2026-09-21) and handed off here so implementation can happen on a
machine kept for real client work, connected to the tenant that will actually be used — not the
disposable VM this plan was drafted on. Nothing described below has been built yet; treat this
as the starting point for the next session, not a status report.

## Context

NSP-IntuneApps can plan a deployment (discover, hash, resolve Create/NoChange/Update/Supersede,
build a local run journal with named stages) but the executor that actually performs any of
those stages against Microsoft Graph has never been built — `Get-NSPAppDeploymentPlanReview`
hardcodes `ExecutorStatus = 'NotImplemented'`. This plan builds the first real, working slice:
**creating a brand-new Win32 app in Intune from a catalog entry**, end to end, verified against
a test tenant using `Apps/VCred` (a clean, dependency-free, real deployable app with no
icon/vendor complications) as the proof case.

Explicitly out of scope for this pass (stubbed to fail clearly, not silently mishandled):
`UpdateMetadataInPlace`, `UpdateContentInPlace`, `CreateSupersedingApp`. These need the
content-version update side of the IntuneWin32App module verified against a real update
scenario, which is a separate, later pass — building and shipping all four paths at once in one
untested go against a real tenant is more risk than the timeline calls for.

## What already exists and will be reused, not rebuilt

- `Get-NSPAppSourceState` (`Public/Get-NSPAppSourceState.ps1`) + `Get-NSPDeterministicTreeHash`/
  `Get-NSPDeterministicFileHash` (`Private/`) — SourceId, MetadataSha256, ContentSha256, and the
  exact 3-line `ManagementNotes` block. Do not recompute hashes elsewhere.
- `Resolve-NSPAppDeploymentAction` — pure decision logic, already correct, untouched.
- `New-NSPAppDeploymentRun` / `Set-NSPAppDeploymentRunStage` — the local stage journal. The
  `Create` stage list is already `ValidatePlan, Build, Sign, Package, CreateApp,
  RecordManagementNotes`. This plan implements the work *behind* each stage; the journal
  mechanics (atomic writes, one-app-at-a-time ordering) are not touched.
- `Get-NSPCodeSigningConfiguration` (Private) / `Get-NSPCodeSigningCertificate` (Public) — cert
  resolution by exact thumbprint. Reused by the new Sign stage, not reimplemented.
- The `Connect-MgGraph` + `Get-MgContext` + `Invoke-NSPGraphCollection` pattern already used by
  `Get-NSPIntuneAppInventory.ps1` and `Get-NSPCodeSigningTrustPlan.ps1` — factored into one
  shared helper (see below) instead of copied a third time.
- `Apps/Create_UploadToIntune_SplitScript.ps1` (disabled) — reference only, for the
  `IntuneWin32App`-module call shapes (detection rule, requirement rule, install/uninstall
  command-line convention). Its display-name matching and delete/recreate semantics are
  deliberately **not** carried forward.
- `Z-MiscSetup/CreateNewAppReg-Graph.ps1` — reference only, for the app-registration creation
  mechanics (`New-MgApplication`, `RequiredResourceAccess`, `New-MgOauth2PermissionGrant` for
  admin consent). Rewritten cleanly rather than ported: targeted live permission-GUID lookup
  instead of porting the 384KB static `MSGraph_AppRegDefs.ps1` table, current module's actual
  required redirect URI (`http://localhost`) and permission set instead of the old ones, and a
  proper plan/`-Execute` gate instead of running unconditionally.

## New pieces

### 1. `Private/Connect-NSPGraph.ps1` — shared Graph connect helper
Extracts the duplicated block from `Get-NSPIntuneAppInventory.ps1`/`Get-NSPCodeSigningTrustPlan.ps1`:
checks/installs `Microsoft.Graph.Authentication` via the existing `Import-NSPBootstrap`/
`Install-NSPModule` pattern, `Connect-MgGraph -Scopes $Scopes -NoWelcome` if `-Connect`, else
requires an existing `Get-MgContext` with the needed scopes present, returns the context.
Refactor the two existing callers onto it (behavior-preserving; covered by their existing tests).

### 2. `Public/Register-NSPIntuneWin32AppRegistration.ps1` — one-time tenant bootstrap
`[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]`, params `-RepoRoot`, `-TenantId`,
`-Execute`. Plan-only by default (mirrors `Publish-NSPCodeSigningTrust`'s `-Execute` gate):

- Connects via `Connect-NSPGraph` with `Application.ReadWrite.All`, `Directory.ReadWrite.All`,
  `DelegatedPermissionGrant.ReadWrite.All` (needed to create the app and grant consent — this
  requires the connecting account to actually be a Global/Privileged Role Administrator; the
  function does not attempt to elevate or work around that).
- Checks for an existing recorded registration first: `Config/Local/GraphAppRegistration.json`
  (new, git-ignored path — **not** the legacy `Apps/GraphInfo.ps1`; that path stays ignored in
  `.gitignore` for backward compatibility but this is a clean-rebuild feature and belongs under
  `Config/Local/` like every other piece of local/tenant state per `README.md`). If a ClientID is
  already recorded, verify the app still exists (`Get-MgApplication -ApplicationId`) and report
  its status rather than creating a duplicate.
- If none recorded (or `-Execute` confirms creating a new one): looks up the *live* permission
  GUIDs for exactly the four permissions `IntuneWin32App` needs (`DeviceManagementApps.ReadWrite.All`,
  `DeviceManagementConfiguration.ReadWrite.All`, `DeviceManagementRBAC.Read.All`,
  `Group.Read.All`) via `Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'"` and
  its `Oauth2PermissionScopes` — a small targeted lookup, not a ported static table.
- Creates the application (`New-MgApplication -DisplayName 'NSP-IntuneApps-Win32AppDeployment' -SignInAudience AzureADMyOrg -RequiredResourceAccess ... -IsFallbackPublicClient`),
  sets `http://localhost` as the redirect URI (current module's actual documented requirement —
  not the old ADAL-era URIs in the legacy script), creates the service principal, and grants
  org-wide admin consent via `New-MgOauth2PermissionGrant -ConsentType AllPrincipals` for those
  four scopes.
- Writes `Config/Local/GraphAppRegistration.json` (`TenantId`, `ClientId`, `AppName`, `CreatedAtUtc`,
  `GrantedScopes`) — no secret is involved; `IntuneWin32App`'s interactive/device-code flow
  needs only the public ClientID, never a client secret, so nothing sensitive is written.
- Every write gated behind `ShouldProcess`; without `-Execute` it reports exactly what it would
  create/grant and stops.

### 3. `Private/Resolve-NSPAppBuildPlan.ps1` — pure, offline metadata derivation
Takes a catalog entry (`Name`, `SettingsPath`, `Path`) and the loaded `$VariableConfig`, returns
an object with `InstallCommandLine`, `UninstallCommandLine` (the
`"PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{0}""" [+ Args_String]`
convention from the Gen1 script, tolerating both `DetectScript_Filter` and the older
`Filter_DetectScript` key names), `DetectionScriptPath`, `RequirementRule` inputs
(`REQ_Architecture`, `REQ_MinWindowsRelase`), and `IconPath` (use `$VariableConfig.ImagePath` if
set and the file exists; else the first `*.png` directly in the app's root folder, matching the
Gen1 fallback; else `$null` — `Add-IntuneWin32App`'s `-Icon` is optional). No Graph calls, no
file mutation — fully unit-testable against `$TestDrive` fixtures the same way
`Tests/DeploymentRun.Tests.ps1` already tests the local state machine.

### 4. `Public/Set-NSPAppSignature.ps1` — the Sign stage
`[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]`, params `-RepoRoot`, `-AppPath`
(or catalog `Name`). Resolves the cert via the existing `Get-NSPCodeSigningCertificate -RepoRoot`
(no `-ImportIfMissing` — assumes the cert is already imported machine-wide on the build/signing
host, matching the non-interactive requirement the code-signing research surfaced). Enumerates
the app's `Detect/*.ps1` and `Source/*.ps1` (per the settings file's own filters), signs each
with `Set-AuthenticodeSignature -Certificate ... -TimeStampServer $config.Policy.TimestampServer`,
and throws with the offending file/`StatusMessage` if any signature comes back non-`Valid` —
mirrors the exact validation the disabled Gen1 script already did, just as a supported, tested
function instead of dead code.

### 5. `Public/Build-NSPAppPackage.ps1` — the Build + Package stages (local, no Graph)
Params `-RepoRoot`, `-AppName` (catalog name), `-OutputPath` (defaults to git-ignored
`Config/Local/Build/<AppName>/`). Bootstraps `IntuneWin32App` via the same
`Import-NSPBootstrap`/`Install-NSPModule` on-demand pattern as the Graph modules (it is not a
manifest `RequiredModules` dependency, matching how `Microsoft.Graph.Authentication` is already
handled). Calls `Resolve-NSPAppBuildPlan`, then `New-IntuneWin32AppPackage -SourceFolder
<app's Source dir> -SetupFile <resolved setup file> -OutputFolder $OutputPath`, then
`Get-IntuneWin32AppMetaData` on the result. Returns the `.intunewin` path + metadata + the
build-plan object. Entirely offline — no `Connect-MSIntuneGraph`, no tenant contact — consistent
with `Build`/`Package` being separate stages from `CreateApp` in the journal.

### 6. `Public/New-NSPIntuneWin32App.ps1` — the CreateApp + RecordManagementNotes stages
Params `-RepoRoot`, `-AppName`, `-PackagePath` (from step 5's output), `-TenantId`, `-ClientId`
(from the registration record in step 2), `-Execute`. `[CmdletBinding(SupportsShouldProcess,
ConfirmImpact='High')]` — this is the one function that actually writes to the tenant.

- Connects via `Connect-MSIntuneGraph -TenantID -ClientID` (interactive by default; the function
  does not choose device-code vs. interactive for the operator — that's their call at the
  prompt).
- Builds `New-IntuneWin32AppDetectionRuleScript` (from the resolved `DetectionScriptPath`,
  `EnforceSignature_Detection`, `RunAs32Bit_Detection`), `New-IntuneWin32AppRequirementRule`,
  `New-IntuneWin32AppIcon` (if an icon was resolved).
- Calls `Add-IntuneWin32App` with the built package, metadata-derived `DisplayName`/`Publisher`
  (or the settings file's literal values), install/uninstall command lines, detection rule,
  requirement rule, icon — under `ShouldProcess`.
- Immediately follows with a direct `Invoke-MgGraphRequest -Method PATCH` (via `Connect-NSPGraph`
  under the *existing* `Microsoft.Graph.Authentication` session — `Add-IntuneWin32App`'s own
  session is separate, but the created object's Graph ID is enough to patch it from either
  session) to write the `Notes` field with `Get-NSPAppSourceState`'s `ManagementNotes` block —
  this is what makes the app recognizable as NSP-managed on the next planning pass. Recorded as
  its own stage (`RecordManagementNotes`), matching `docs/DeploymentEngine.md`'s "metadata PATCH
  ... separate recorded operations" execution gate.
- No assignment is created here — matches the existing "assignment is a separate reviewed
  operation" rule already enforced by the preflight check on `AssignmentColl`.

### 7. Orchestration: `Public/Invoke-NSPAppDeploymentRunStage.ps1`
The missing piece — nothing currently drives the run journal forward. Params `-RunPath`,
`-Execute`. Resolves the current app/current stage the same way `Set-NSPAppDeploymentRunStage`
already does (current-entry/current-stage lookup), dispatches to the matching function above for
`Create`-path stages (`ValidatePlan` re-verifies hashes haven't drifted since planning;
`Build`→`Build-NSPAppPackage`; `Sign`→`Set-NSPAppSignature`; `Package` is folded into the `Build`
call's output, recorded as its own stage transition; `CreateApp`/`RecordManagementNotes`→
`New-NSPIntuneWin32App`), wraps each in `Set-NSPAppDeploymentRunStage -Status Running` before and
`Succeeded`/`Failed` after with the real error message on failure. For any stage belonging to
`UpdateMetadataInPlace`, `UpdateContentInPlace`, or `CreateSupersedingApp` (`PatchMetadata`,
`UploadContent`, `CommitContent`, `AddSupersedence`), it fails the stage immediately with a clear
"not yet implemented in this executor" message rather than guessing — this is the explicit
boundary of this pass's scope. Advances **one stage per invocation**, not the whole run
unattended, matching the existing one-app-at-a-time/persist-after-every-transition safety model;
without `-Execute` it reports which stage would run and what it would do, and stops.

### 8. Dashboard wiring
Add option to `Public/Start-NSPIntuneApps.ps1`'s menu (after the existing "View resumable
deployment run journals") to advance the current run's next stage via
`Invoke-NSPAppDeploymentRunStage`, plan-only by default with an explicit `[Y/N]` confirm before
passing `-Execute` — consistent with every other write-capable path already in that dashboard
(code-signing trust push, etc.).

## Tests

- `Tests/AppBuildPlan.Tests.ps1` (new): `Resolve-NSPAppBuildPlan`'s install/uninstall
  command-line derivation (including the `Filter_DetectScript` vs `DetectScript_Filter` fallback)
  and icon resolution fallback, against `$TestDrive` fixtures — no Graph, no IntuneWin32App
  module needed.
- Extend `Tests/DeploymentRun.Tests.ps1` for `Invoke-NSPAppDeploymentRunStage`'s dispatch/failure
  behavior for the explicitly-unimplemented stage names, and its stage-advance-one-at-a-time
  contract — using fake/stub stage functions via Pester's function-scoping, not real Graph calls,
  matching the existing no-mocking-Graph philosophy.
- `Set-NSPAppSignature` gets a real (non-Graph) test: generate a throwaway self-signed
  code-signing cert in the test, sign a throwaway `.ps1`, assert `Valid`. No tenant needed.
- `Build-NSPAppPackage`/`New-NSPIntuneWin32App`/`Register-NSPIntuneWin32AppRegistration` are
  **not** unit-tested (they need `IntuneWin32App`/live Graph) — verified manually against the
  test tenant instead, per the existing pattern of pushing Graph I/O to untested edges.

## Verification (test tenant, VCred)

1. `Register-NSPIntuneWin32AppRegistration -RepoRoot . -TenantId <test tenant> -Execute` once,
   as an admin in the test tenant — records `Config/Local/GraphAppRegistration.json`.
2. Build a plan for VCred, bind a read-only inventory, approve it, create a run journal (all
   already-working dashboard steps).
3. `Invoke-NSPAppDeploymentRunStage -RunPath <run> -Execute` repeatedly (once per stage) through
   `ValidatePlan → Build → Sign → Package → CreateApp → RecordManagementNotes`.
4. Confirm in the test tenant: the app exists, has the right detection/requirement rules, and
   its `Notes` field carries the three `[NSP-...]` marker lines.
5. Re-run planning against the same tenant: `Resolve-NSPAppDeploymentAction` should now report
   `NoChange` for VCred, proving the marker round-trips correctly.
6. Run the full `tools/Test-Repo.ps1` suite to confirm nothing regressed.

## Docs to update once implemented

Update `docs/DeploymentEngine.md`'s "Execution gates" section to describe what's now implemented
vs. still-deferred, and `PLAN.md` Phase 4 checklist to reflect the same. This plan document
itself should be folded into those (or deleted) once the work lands, rather than left to go
stale alongside the real implementation.
