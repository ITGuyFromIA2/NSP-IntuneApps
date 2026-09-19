# NSP Intune tooling boundary

## This repository: the Apps workbench

`NSP-IntuneApps` owns the source catalog and the workflow needed to discover, validate, generate, package, sign, plan, upload, update, supersede, and report on Intune applications. Endpoint packages are self-contained. `NSP.Bootstrap` is a build/operator dependency unless a reusable endpoint capability is deliberately reviewed and promoted there.

The local dashboard is intentionally an Apps workbench. It exposes domain functions rather than containing all implementation logic, so a future parent orchestrator can call the same functions non-interactively.

Certificate generation and the `NSP Code Signing` trust profile currently live here because they are prerequisites for the signed-app supply chain. Their Graph interaction is isolated from catalog and package logic so it can later move behind an `NSP-IntuneManager` provider without changing the app workflow.

## Future parent: NSP-IntuneManager

The future manager is the tenant-wide orchestration and inventory layer. Expected domains include:

- Windows, Android, and iOS configuration profiles;
- compliance policies;
- notification templates, including reusable templates for generating tenant templates;
- managed application and application-configuration policies;
- assignment filters and cookie-cutter filter generation;
- group and enrollment-profile aware targeting;
- cross-domain discovery, drift reporting, planning, approvals, and execution.

The manager should consume app plans from this repository rather than absorb app source and packaging internals.

## Targeting contract

App definitions may request targeting using stable references such as group object IDs, filter object IDs with include/exclude mode, and an enrollment-profile selector. This repository may validate and display those references. Creation, lifecycle management, and tenant-wide reuse of groups, filters, and enrollment-profile mappings belongs to `NSP-IntuneManager`.

Until that manager exists, the Apps workbench must stop when a named target resolves ambiguously. It must never silently create a tenant-wide filter or guess between duplicate groups.

## Safety contract

All tenant workflows are staged:

1. discover;
2. validate;
3. produce a reviewable plan;
4. request explicit approval;
5. execute one item at a time;
6. record the result and recovery information.

Delete-and-recreate is not a default update strategy. Existing object IDs should be preserved when supported. When content cannot be updated safely in place, the preferred fallback is side-by-side creation plus supersedence, with cleanup as a separate approved action.
