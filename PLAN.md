# NSP-IntuneApps ongoing plan

Last updated: 2026-09-21

This is the durable roadmap and decision log for the upstream Intune application repository. Update it whenever a phase is completed, a design decision changes, a new blocker is discovered, or the next active work item changes.

## Mission and boundary

`NSP-IntuneApps` is the source-of-truth catalog and operator workbench used to onboard and maintain Intune Win32 applications across customer repositories.

It owns app source, reusable app templates, package generation, signing, app discovery, deployment planning, and app deployment execution. It does not own the broader tenant-management domains planned for `NSP-IntuneManager`: configuration profiles, compliance policies, notification templates, Android/iOS policy and application configuration, groups, enrollment profiles, and shared assignment-filter lifecycle.

Only this repository may be edited during this effort. Downstream repositories and other NSP tool repositories may be inspected and copied from, but they are not modified without separate approval.

## Settled decisions

- The repository is source-only. Generated `.intunewin` files are ignored and removed from Git history going forward.
- Endpoint packages are self-contained. `NSP.Bootstrap` is primarily an operator/build dependency, not an endpoint prerequisite. Reuse on endpoints requires prior discussion.
- Large vendor payloads that cannot be reliably downloaded belong in an approved private artifact repository, which may be a separate private GitHub Releases repository. This public source repository retains only a pinned manifest with repository/tag, filename, SHA-256, version/source notes, and package-specific metadata.
- Printer driver payloads remain part of the generated Intune package; managed endpoints do not fetch them from an external service.
- Code-signing private keys never enter repository source, regardless of repository visibility. Certificate generation writes the encrypted PFX only to ignored operator-local storage; its strong password and approved recovery copy are held separately in Password Boss or another private recovery location. Public CER and OMA-URI material may remain versioned.
- Signing certificate selection is by exact configured thumbprint, never merely the newest certificate sharing a subject.
- Certificate lifetime is configurable. Rotation/trust is required for tenants receiving newly signed packages; timestamped older packages retain their existing signature behavior.
- Certificate trust uses one `NSP Code Signing` profile with distinct Root and Trusted Publisher OMA-URI settings. Generations can coexist. Conflicting pre-existing structures stop for review rather than being automatically deleted or consolidated.
- Graph authentication is delegated and interactive. Discovery/validation/plan are read-only. Every tenant write requires explicit execution approval.
- Trust assignment defaults to All Devices when the operator accepts the default, with selected-group and unassigned options presented before rollout.
- App changes default to plan-only. The Gen1 delete/recreate uploader remains disabled.
- Compatible app changes preserve the existing Intune object ID. Breaking changes use a side-by-side app plus reviewed supersedence. Unmarked or ambiguous existing apps stop for review.
- Deployment review is one app at a time with Approve, Skip, save/resume, and per-item result tracking.
- Drive maps, RDP/RemoteApp connections, and printers are configuration-driven wizards rather than copied client instances.
- RDP prompts use simple numbered choices, contextual examples, and only questions relevant to Desktop versus RemoteApp mode.
- Parallels RAS Client resolves the latest official x64 MSI on the endpoint at install time by default and validates HTTPS, MSI structure, Authenticode status, and signer identity. Pinning is an explicit compatibility exception and requires SHA-256 equality.
- AutoIt is the leading interactive-installer engine for disposable-VM evaluation. Interpreted source is the initial delivery preference; a compiled executable is adopted only if Defender/SmartScreen testing shows acceptable behavior and a material operational advantage.
- Printer queues are separate from reusable driver apps. One anonymized queue example per driver behavior is sufficient; redundant named client queues do not come upstream.
- No client names, internal UNC paths, tenant identifiers, credentials, or customer-specific printer/RDS instances belong upstream.
- The downstream customer-branded FortiClient app is explicitly excluded; generic FortiClient/IPsec work belongs with the existing generic app and `NSP-FGTIPSecTools` integration path.
- Downstream credential remediation is out of scope unless separately authorized.
- The accidentally published Gen1 history will be replaced by one sanitized, public-safe root commit. Existing downstream repositories will not merge that unrelated root automatically; each will receive a deliberate catalog/configuration uplift and be re-established against the sanitized upstream during onboarding.

## Completed foundation

- [x] Added module manifest, public/private command layout, and dashboard launcher.
- [x] Added recursive catalog discovery and classifications for Deployable, RequiresConfiguration, SharedComponent, TemplateOrIncomplete, Legacy, and Blocked.
- [x] Added preflight checks for parser errors, client markers, generated packages, executable payloads, private-key artifacts, dependency availability, catalog blockers, and code-signing state.
- [x] Fixed the MachineVPN/UserVPN parser and configuration issues identified during exploration.
- [x] Sanitized MachineVPN, UserVPN, and ScreenConnect upstream defaults.
- [x] Disabled the Gen1 destructive uploader pending the replacement executor.
- [x] Removed tracked `.intunewin` outputs and added source-only ignore policy.
- [x] Added exact-thumbprint signing resolution.
- [x] Added configurable certificate generation using `NSP.Bootstrap`, encrypted PFX export, public CER export, and activation metadata.
- [x] Added read-only certificate trust planning and explicit Graph execution with tenant/target visibility.
- [x] Added the combined-profile/multi-generation trust model.
- [x] Added DriveMap and RDP/RemoteApp generators.
- [x] Added the first interactive-installer capture prototype.
- [x] Added GitHub Release artifact manifest/download/hash verification.
- [x] Added configuration-driven printer driver and queue generators, archive integrity checks, dependency declaration, and safe removal checks.
- [x] Promoted the modern VCred logic into a self-contained upstream app.
- [x] Added resumable app deployment trackers.
- [x] Added the offline deployment-action resolver and documented stable app identity/update semantics.
- [x] Inventoried archived downstream areas. All 21 archived families already exist upstream; no archived promotion is needed.
- [x] Corrected the `TRAFx` catalog assessment: TRAFx is a distinct application whose folder was seeded with an incorrect FortiClient scaffold. It is preserved as `RequiresRepair`, with no FortiClient replacement relationship, until a validated TRAFx Communicator package is built.
- [x] Removed active targeting from app settings and added a structural preflight blocker; assignments now belong exclusively to reviewed deployment plans.
- [x] Added preflight blockers for missing literal deployable identity and file-mutating deployable settings; generator-style prototypes cannot silently enter execution planning.
- [x] Added a preflight blocker for likely committed passwords, passphrases, license keys, API keys, access tokens, client secrets, and credential-bearing `net use` commands. Reports identify only file/line/type and never print the suspected value.
- [x] Removed a missed organization-specific Parallels RAS connection profile and legacy tenant/application identifiers from the Gen1 connection shim. Parallels is now `RequiresRepair` with fail-closed placeholders until a reviewed MSI/configuration generator replaces it; the marker regression list includes the newly discovered names.
- [x] Installed Pester 6.2.0 for the current user and established a passing repository suite (304 tests at the current checkpoint), plus a successful Windows PowerShell 5.1 parser/module-import gate.
- [x] Documented the future `NSP-IntuneManager` boundary and targeting contract.
- [x] Audited every fetched branch and all 46 historical `.intunewin` objects after discovering the repository was public. No PFX/private key, Forti credential, Parallels credential, or Graph secret was found. The apparent ScreenConnect `GuestCode` values were customer-label custom properties, not authentication or enrollment secrets.
- [x] Removed the literal Bitdefender GravityZone package ID from install/uninstall source, made tenant injection fail closed, and added a preflight/Pester regression blocker for future literal `GZ_PACKAGE_ID` values.

## Current work

The first downstream-only app wave is implemented as sanitized generic apps and generators; its remaining external step is the reviewed private Canon/HP artifact release. Disposable-machine validation for Parallels, DelegateService/SetACL, and AutoIt is now complete (see Phase 3 and [docs/TestVM.md](docs/TestVM.md)); the next development work is the reviewed deployment executor in Phase 4, plus the Parallels guided configuration generator and the engine-neutral schema-v2 runner noted under Phase 3. The exact handoff state, test evidence, and uncommitted-file warning are in [HANDOFF.md](HANDOFF.md).

Vendor helper binaries follow a procurement policy rather than being copied into source. Bitdefender's vendor-published wrapper is retrieved and Authenticode-validated on the endpoint. SetACL 3.1.2 is retrieved directly from its publisher because its redistribution terms require a license when bundled; its publisher archive is SHA-256 pinned after confirming the signed x86 and x64 executable variants. DelegateService's install/detect/uninstall mechanism is functionally verified against a disposable local service and user (the SetACL grant/revoke round-tripped correctly via `sc start` access checks, not just a textual ACL listing); the real production detection target (`IntuneManagementExtension`) remains unverified since the test VM isn't Intune-enrolled. Historical ServiceUI copies are not replaced: Microsoft retired MDT in January 2026, Managed Reboots no longer needs ServiceUI, and any future legacy exception requires an explicit reviewed design. See `docs/VendorDependencyPolicy.md`.

The replacement prompt bridge is based on the proven `NSP-FGTIPSecTools` SuperScript pattern: WTS-based active-user discovery, transient per-user interactive scheduled tasks, first-response-wins cleanup, and the domain-qualified `UserId` XML repair. It remains self-contained in generated endpoint packages. Possible future promotion into `NSP.Bootstrap` requires discussion before creating any endpoint runtime dependency.

The downstream Adobe variants required consolidation rather than direct copying. They installed NuGet/Evergreen on each endpoint, slept for two minutes after installation, and encoded stale edition/architecture assumptions. The replacement resolves standalone Reader at operator/build time when requested and accepts reviewed unified or Admin Console packages, then generates a self-contained app. Adobe's current unified 64-bit model supplies Reader, Standard, or Pro behavior according to entitlement instead of separate installed product identities.

## Queued phases

### Phase 1 — Complete the curated generic app wave

- [x] Consolidate Adobe variants into a shared build-time generator. Standalone Reader can be resolved through operator-side Evergreen; unified 64-bit Acrobat/Reader and Admin Console packages are accepted as reviewed local input. Detection follows installed architecture and Adobe's current unified entitlement model rather than pretending Standard/Pro are separate installed products.
- [x] Rebuild and harden Dell Optimizer as a desired-state removal package.
- [x] Rebuild the two LG removal apps from their actual intent rather than their copied Chrome scaffolding.
- [x] Rebuild Managed Reboots as a wizard-generated policy app with testable state transitions, a SYSTEM evaluator, WTS/per-user interactive prompts adapted from the SuperScript pattern, bounded deferrals, and a hard deadline. No ServiceUI, AnyBox, endpoint PSGallery access, permanent user process, or `C:\\admin` state is retained.
- [x] Add hash-pinned generic Canon/HP release manifests and document measured ZIP results; private Release upload/provenance review remains an explicit operator step.
- [x] Add one sanitized Canon color queue and one sanitized HP monochrome queue example using non-routable documentation addresses.
- [ ] Publish and retrieve the staged Canon/HP assets from the private Release after provenance/redistribution review.
  - Current environment note: GitHub CLI is not installed; preflight reports this as a release-only warning rather than blocking unrelated catalog work.
- [x] Run catalog/client-marker/parser/Pester checks after each family. Current consolidated gate: 304 passing tests.

### Phase 2 — Generic client-pattern generators

- [x] DriveMap wizard.
- [x] RDP/RemoteApp wizard.
- [x] Printer driver/queue wizard.
- [x] FortiClient SSL VPN configuration wizard; generated tenant values remain in the ignored local area.
- [x] Shortcut/web-shortcut wizard, including default-browser, Edge, Chrome, and file/program modes derived from the useful behavior in the 511IA prototype.
- [x] Decide whether Downloads redirection is a generally safe app pattern or belongs in configuration/profile management. It belongs in the future `NSP-IntuneManager` user-configuration/profile domain because it changes known-folder state and depends on identity, storage, logon, and migration policy; the client-specific Win32 scheduled-task package is not promoted.
- [x] Generate sanitized examples without importing client names, addresses, or UNC paths. DriveMap, RDP, printer, shortcut, Adobe, and managed-reboot generators/examples use documentation-only values or ignored local output.

### Phase 3 — Interactive installer capture

- [x] Establish a stepwise capture schema and initial UI Automation metadata capture.
- [x] Evaluate the Time Matters/HotDocs/Tabs scripts for reusable GUI sequencing patterns. Retain ordered window/text matching, conditional screens, bounded waits, keyboard fallbacks, and version metadata; reject client values, credentials, fixed sleeps, unrelated certificate changes, and unpinned automation downloads.
- [x] Build a technician recorder/shim that launches an installer and captures window title, visible text/control, and editable actions. Global Ctrl+Shift+F12/F11 hotkeys preserve installer focus; the separate review pass stores sensitive/customer-specific input only as named runtime parameters.
- [ ] Keep runtime window/process validation in the AutoIt/AHK execution layer when that remains the strongest implementation.
- [x] Port generic document-assembly installer logic as a metadata/version-aware placeholder; no proprietary installer, real license value, or client source path is committed.
- [x] Sanitize and genericize the useful multi-screen and document-assembly patterns as schema-v2 examples.
- [x] Add a non-interactive schema-v2 validator so future `NSP-IntuneManager` orchestration can reject broken or undeclared runtime-parameter references before execution.
- [x] Add a disposable-VM/Sandbox runbook, clean-machine readiness snapshot, and local Defender comparison harness for interpreted versus compiled runner evidence.
- [x] Complete AutoIt source and compiled delivery validation in the disposable VM. Interpreted and compiled forms ran clean for both a harmless synthetic probe and a realistic multi-screen captured installer (Notepad++ v8.9.8), including a true SYSTEM-context comparison and a Mark-of-the-Web/SmartScreen check; Defender scans found no detections on any artifact. A GUI installer wizard does not reliably complete under a true non-interactive SYSTEM session (an informative negative result, not a bug) and belongs in user-context deployment instead. See `docs/TestVM.md`.
- [ ] Implement the selected engine-neutral schema-v2 runner: a generic interpreter that drives AutoIt directly from a capture file. This session hand-implemented one capture as a one-off script to prove the technique end to end; a reusable generic runner is still future work.
- [x] Complete Parallels validation in the disposable VM. Install, mode-1 shared-device XML import (verified via registry against the generated XML, no credentials present), repeat/repair (connection state explicitly verified to survive, not assumed), uninstall (installed-program/service/files removed; the shared-connection registry key is left as residue, noted but not cleaned up), and fail-closed hash/signer validation are all verified for 21.2.27311 with a valid Parallels International GmbH signature. See `docs/TestVM.md`.
- [ ] Build the Parallels guided configuration generator so `ParallelsConnection.config.psd1` isn't hand-authored; the last blocker before promoting the catalog entry past `RequiresRepair`.
- [ ] Replace the GitHub repository refs with the verified sanitized root after repository visibility is private, then uplift each downstream customer repository deliberately rather than merging unrelated histories.

### Phase 4 — Deployment engine

- [x] Define stable management markers and offline action resolution.
- [x] Compute deterministic metadata and source-content hashes while ignoring Authenticode renewal and checkout line endings.
- [ ] Record the deterministic source hashes in Intune Notes during create/update execution.
- [x] Add read-only tenant inventory with delegated Graph login, tenant/account reporting, and an ignored local snapshot.
- [x] Bind saved inventory JSON to the local tracker and resolve Create, NoChange, UpdateMetadataInPlace, UpdateContentInPlace, CreateSupersedingApp, AdoptOrReview, or Conflict without tenant writes.
- [x] Connect delegated Graph discovery to the saved inventory format after tenant/account confirmation.
- [ ] Implement metadata PATCH while preserving assignments, dependencies, reporting history, and object ID.
- [ ] Implement a new content-version upload/commit against the existing object.
- [ ] Implement reviewed supersedence with graph-depth validation and explicit update-versus-replace choice.
- [ ] Keep cleanup/retirement as a separate explicitly approved workflow.
- [x] Add resumable per-operation logs and a concise sanitized Markdown run report. Operator-entered transition messages stay in the ignored local journal and are omitted from the durable report.

### Phase 5 — Dashboard refinement

- [x] Add a persistent local deployment-tracker summary and resume selector to the dashboard.
- [x] Present warnings, blockers, planned tenant/account, assignment target, object-preserving versus side-by-side effects, and the intentionally unavailable executor before decisions. Inventory binding now precedes approval and cross-tenant inventory binding is rejected.
- [x] Add a local one-app-at-a-time run state machine that expands approved Create, metadata-update, content-update, supersedence, and no-change actions into explicit validate/build/sign/package/write stages. The actual Graph executor remains deliberately disabled.
- [x] Add recoverable resume behavior after partial failure. Every `Pending/Failed -> Running -> Succeeded/Failed` transition is persisted through a temporary replacement file; failures remain the current stage and later apps cannot bypass them.
- [ ] Reuse suitable CLIBuilder/MasterOrchestrator and pushable-tools presentation conventions without coupling endpoint packages to those repositories.
- [ ] Keep domain functions callable non-interactively so `NSP-IntuneManager` can orchestrate them later.

### Phase 6 — Bootstrap and repository organization

- [x] Review repeated endpoint helpers and document possible `NSP.Bootstrap` promotions without introducing a managed-endpoint runtime dependency. Result/state, elevation, and prompt helpers stay local pending explicit discussion.
- [x] Reconcile with the PoSHRepo/ClaudeStuff direction: NSP-IntuneApps is the canonical standalone home for the IntuneApp toolkit, consistent with the recommended one-repository-per-tool model and future NSP-IntuneManager orchestration.
- [x] Avoid duplicating stable `NSP.Bootstrap` operator functions. Random passwords, optional module installation, and named secret retrieval use Bootstrap; the self-bootstrap adapter remains necessarily local.
- [x] Enforce the shared Windows PowerShell 5.1 floor by parsing all scripts and importing the module under `powershell.exe` as part of the repository gate when available.

## Deferred or explicitly excluded

- Password Boss SSH-certificate/Base64 round-trip test: optional later experiment.
- Automatic consolidation/deletion of pre-existing trust profiles: excluded; conflicts stop for review.
- Automatic deletion/recreation of Intune apps: excluded.
- Direct port of client-specific RDS, drive-map, printer queue, or internal path instances: excluded; generators/examples replace them.
- Direct port of the customer-branded FortiClient package: excluded.
- Downstream credential remediation: excluded for now.
- Publishing GitHub Release assets: requires an explicit operator action after payload selection and verification.
- Live tenant writes and certificate generation during repository development: require separate explicit approval.

## Open decisions

These are not blockers for current source work:

- Choose the normal certificate lifetime default within the supported configurable range. The implementation currently preserves the existing annual default; a longer default remains acceptable if operational policy changes.
- Choose the private GitHub repository/tag naming convention for driver and other large source artifacts before publishing the first real asset.
- Define the exact threshold for declaring a package change “breaking” versus compatible in-place content replacement. The safe starting point is that changes to install/uninstall commands, detection identity, architecture, or product ownership require explicit review.
- Confirm AutoIt's delivery form after VM testing: interpreted `.au3` plus reviewed runtime is preferred, while a compiled executable remains a measured fallback. AutoHotkey is not planned unless AutoIt exposes a specific gap.

## Validation checkpoint

Run:

```powershell
.\tools\Test-Repo.ps1
```

Expected baseline at this checkpoint: Windows PowerShell 5.1 parser/module import passes, PowerShell 7 parser/preflight is clean, zero committed `.intunewin` files, zero private-key artifacts, zero executable payloads, zero known downstream client markers, no embedded app assignments, no likely embedded secret literals, no literal tenant deployment identifiers, no duplicate or nonliteral deployable identities, no file-mutating deployable settings, no blocked catalog entries, and 304 passing Pester tests. A missing active signing generation, `NSP.Bootstrap`, `IntuneWin32App`, or GitHub CLI is a warning until its corresponding operation is deliberately invoked.
