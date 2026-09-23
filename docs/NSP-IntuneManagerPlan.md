# NSP-IntuneManager: planning notes

This is the working roadmap for the future tenant-wide manager `docs/Architecture.md` names but
does not detail. That file stays a short boundary statement by design; this document is where the
actual plan lives. No `NSP-IntuneManager` repository exists yet - see [Open questions](#open-questions)
below for what has to be decided before one is created.

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

A separate repository, following the same one-repo-per-tool convention `NSP-IntuneApps` itself
uses (`PLAN.md`: "the recommended one-repository-per-tool model"). Client-specific manager
deployments would fork it the same way client `IntuneApps-<Client>` repos fork `NSP-IntuneApps`
today - see `HowToFork.txt` for the proven pattern (`git remote add upstream`, periodic
`git fetch upstream && git merge upstream/main`). That pattern is already validated in production
across multiple client forks of this repo.

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

Not yet decided - needed before a real `NSP-IntuneManager` repository is created:

- **Target repo name and location.** Which private org/host, and what repo name (matching the
  `NSP-<Purpose>` convention this codebase already uses)?
- **App registration.** Does the manager reuse `NSP-IntuneApps`' existing tenant app registration,
  or register its own? The manager's Graph scope surface is materially broader (RBAC, groups,
  configuration/compliance policy write access) than anything Apps needs today - sharing one
  registration would grant Apps' own registration those broader permissions even when Apps itself
  never uses them, which argues for a separate registration scoped to only what the manager needs.
- **Inventory/blueprint storage at manager scale.** `NSP-IntuneApps` uses flat JSON files under
  `.nsp-intuneapps/` for saved inventories and plans, which works for one tenant's app catalog.
  Whether that same approach scales once the manager is tracking config profiles, compliance
  policies, and filter blueprints across a growing number of client tenants is worth deciding
  deliberately rather than defaulting to "just do what Apps does."
