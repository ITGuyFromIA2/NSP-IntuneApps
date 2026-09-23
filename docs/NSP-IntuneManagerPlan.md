# NSP-IntuneManager: planning notes

This is the working roadmap for the future tenant-wide manager `docs/Architecture.md` names but
does not detail. That file stays a short boundary statement by design; this document is where the
actual plan lives.

The repository exists: `C:\GitRepo\NSP-PoSHToolkits\NSP-IntuneManager` (decided and created
2026-09-23). `NSP-PoSHToolkits` is a plain filesystem folder, not itself a git repo - each tool
under it (`NSP-Console`, `NSP-LogParse`, now `NSP-IntuneManager`) is its own independent git
repository, consistent with the one-repo-per-tool convention below. `NSP-IntuneManager` is
currently just `.git` + `.gitattributes` - no source yet.

## Charter

Per `docs/Architecture.md`'s already-stated boundary, the manager owns:

- Windows, Android, and iOS configuration profiles;
- compliance policies;
- notification templates, including reusable templates for generating tenant templates;
- managed application and application-configuration policies;
- assignment filters and cookie-cutter filter generation;
- group and enrollment-profile-aware targeting;
- cross-domain discovery, drift reporting, planning, approvals, and execution.

`NSP-IntuneApps` (this repo) keeps owning app source, packaging, signing, discovery, deployment
planning, and deployment execution. It does not absorb any of the domains above, and the manager
does not absorb app source or packaging - each tool stays a single-purpose workbench.

## Relationship to NSP-IntuneApps

The manager orchestrates; the Apps workbench executes. Two things already exist to make that
handoff cheap:

1. **The targeting contract** (`Schemas/TargetingReference.schema.json`) is the formal, versioned
   interface between the two tools. An app's targeting request is expressed as stable references -
   `Groups.Include`/`Groups.Exclude` (Entra object IDs, with a display-name hint for operator
   review only, never identity), `Filter.{Id, Mode, BlueprintId}` (`BlueprintId` names which
   manager-owned blueprint produced a resolved filter), and `EnrollmentProfileSelector`
   (`Platform` + `ProfileIds`, `ResolutionPolicy: "requireUnique"`). NSP-IntuneApps validates and
   displays these references; it does not create or manage the groups/filters/profiles they point
   at. This repo owns and validates the schema, since Apps is the consumer; the manager is
   responsible for producing conformant data.
2. **Every NSP-IntuneApps domain function is already callable non-interactively.** Every guided
   generator gates its prompts behind `-Interactive` and is fully parameterizable without it
   (`PLAN.md`, "Keep domain functions callable non-interactively so NSP-IntuneManager can
   orchestrate them later" - audited across every `Public/*.ps1` function). The manager does not
   need any new interface work on the Apps side to call these functions; it just needs to call
   them with the right parameters instead of a human choosing them interactively.

## Repo model

`C:\GitRepo\NSP-PoSHToolkits\NSP-IntuneManager` - its own git repository, following the same
one-repo-per-tool convention `NSP-IntuneApps` itself uses (`PLAN.md`: "the recommended
one-repository-per-tool model"), just filed under the `NSP-PoSHToolkits` grouping folder alongside
`NSP-Console` and `NSP-LogParse` rather than directly under `C:\GitRepo`.

Whether client-specific manager deployments fork it the same way client `IntuneApps-<Client>`
repos fork `NSP-IntuneApps` today (`HowToFork.txt`'s proven `git remote add upstream` /
`git fetch upstream && git merge upstream/main` pattern) depends on the multi-tenant decision
below - a single manager instance covering many client tenants centrally doesn't need per-client
forks the way per-client app catalogs do.

## App registration

**Decided: a separate app registration**, not a reuse of `NSP-IntuneApps`' existing one. The
manager's Graph scope surface (RBAC, groups, configuration/compliance policy write access) is
materially broader than anything Apps needs - sharing one registration would grant Apps' own
registration those broader permissions even when Apps itself never uses them.

Carry over the exact lesson this session spent real effort learning the hard way in
`NSP-IntuneApps`: centralize the manager's own required-scopes list in one place (its own
`Get-NSP*GraphRoutineScopes`-equivalent) and make every routine `Connect-*Graph` call site use it,
including the registration bootstrap's own granted-permissions list - **never** a second literal
copy of the same scopes. A drifted duplicate is exactly what caused repeated, unexplained
reconnect prompts in `NSP-IntuneApps` (`Get-NSPCodeSigningTrustPlan` requesting its own narrower
ad-hoc list, and separately the registration bootstrap duplicating the scope list instead of
referencing it) - both fixed this session, but worth not re-introducing from scratch in a new repo.

## Multi-tenant design

Not originally planned as multi-tenant - reconsidered after reviewing an existing multi-tenant
pattern already proven in production: the Exchange Online DirectSend script
(`AIO_-_V4.ps1`, Office 365 Best Practices Configurations). That script holds several **simultaneous**
tenant connections in one process by using `Connect-ExchangeOnline -Prefix <T0|T1|...>`, tracking
each in a `$script:ConnPrefixMap` (ConnectionId -> Prefix) plus an `$script:ActivePrefix` for
"which tenant is current," with a connection-management menu to list/switch/add/disconnect and a
session cache file to restore across runs.

**This exact mechanism cannot be ported to Microsoft Graph.** `-Prefix` is a feature specific to
the `ExchangeOnlineManagement` module. `Microsoft.Graph.Authentication`'s `Connect-MgGraph` has no
equivalent - `Get-MgContext` returns exactly one context per process, full stop. `Connect-NSPGraph`
(`NSP-IntuneApps`) already works around the single-context model by reconnecting only when the
current context doesn't match what's requested; that's the ceiling of what the SDK's own session
model allows, not a workaround waiting to be lifted.

To get genuinely concurrent multi-tenant sessions (switch between tenants without a reconnect,
the way the Exchange script does), the manager would have to bypass `Connect-MgGraph`/
`Invoke-MgGraphRequest` entirely for its own calls: acquire and cache one token per tenant
directly (MSAL.PS or the underlying MSAL library), then call Graph via plain
`Invoke-RestMethod -Headers @{ Authorization = "Bearer $token" }` instead of the SDK's cmdlets,
refreshing each tenant's token independently. That's a real, buildable equivalent of the
`ConnPrefixMap`/`ActivePrefix` pattern - just implemented against MSAL instead of a
module-provided `-Prefix`, and a materially bigger build than anything in `NSP-IntuneApps` today.

**Not yet decided**: whether that investment is worth it for v0.1, or whether the manager starts
single-tenant-at-a-time (reconnect to switch tenants, same model `NSP-IntuneApps` already uses)
and multi-tenant concurrency is a later milestone once the MVP proves out. Given how many client
tenants this practice already operates across, the concurrent model is plausibly worth it - but
it's a scope decision for the user, not a default to assume.

## MVP scope

`docs/TargetingContract.md` already sketches the day-one workflow; propose building exactly that
and nothing broader for v0.1 (no configuration profiles, compliance policies, or notification
templates yet):

1. Inventory groups, enrollment profiles, and existing assignment filters in the tenant.
2. Resolve existing filters against manager-owned blueprints, or plan creation of new ones from
   reusable blueprints.
3. The operator approves those tenant-wide resources.
4. The manager hands the Apps workbench stable group and filter IDs.
5. The Apps planner shows those resolved targets alongside each app before execution.

This is deliberately the narrowest useful slice - it's the one domain (filters/groups/targeting)
that already has a design doc and a schema, and it's the one piece of manager-domain
functionality NSP-IntuneApps has already had to build a stopgap for (see next section).

## Migration note

`New-NSPCookieCutterAssignmentFilters` and `Get-NSPCookieCutterFilterBlueprints`
(`NSP-IntuneApps`, added 2026-09-23) are a **documented interim placement**, not
a permanent home. `docs/Architecture.md` explicitly assigns "assignment filters and cookie-cutter
filter generation" to the manager's domain. They were built directly in the Apps workbench because
the manager didn't exist yet and an operator needed the capability immediately (an active
SSLVPN-to-IPSEC migration driving repeated new-client filter setup).

Once the manager's MVP (above) absorbs cookie-cutter filter blueprint lifecycle, these two
functions - and the `[18]` dashboard entry that calls them - should be **deprecated and removed**
from `NSP-IntuneApps`, in favor of the Apps workbench consuming a resolved `Filter.BlueprintId`
from the manager via the targeting contract instead of creating filters itself. Recording this now
so it isn't forgotten or rediscovered as "surprising" tech debt later.

## Open questions

Resolved: repo location (`NSP-PoSHToolkits\NSP-IntuneManager`) and app registration (separate,
not shared with Apps) - see above. Still not decided:

- **Multi-tenant concurrency** (see above) - single-tenant-at-a-time for v0.1 with concurrent
  multi-tenant sessions as a later milestone, or build the MSAL-based concurrent token cache from
  the start?
- **Inventory/blueprint storage at scale.** `NSP-IntuneApps` uses flat JSON files under
  `.nsp-intuneapps/` for saved inventories and plans, which works for one tenant's app catalog.
  Whether that same approach scales once the manager is tracking config profiles, compliance
  policies, and filter blueprints across a growing number of client tenants - and, if multi-tenant
  concurrency is in scope, across multiple tenants' data in the same process - is worth deciding
  deliberately rather than defaulting to "just do what Apps does."
