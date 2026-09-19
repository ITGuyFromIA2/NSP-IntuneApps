# Targeting contract for NSP-IntuneManager

App deployment plans need targeting, but this repository should not become the lifecycle owner for tenant-wide groups, assignment filters, or enrollment profiles.

The contract in `Schemas/TargetingReference.schema.json` separates those responsibilities:

- apps store stable group object IDs; display names are hints for operator review, never identity;
- apps consume a resolved Intune assignment-filter ID and an include/exclude mode;
- a future enrollment-profile selector is a request to `NSP-IntuneManager`, not something the Apps workbench silently translates or creates;
- manager-owned filter blueprints can record which standard recipe produced a resolved filter;
- duplicate names or a missing target stop the plan rather than falling back to a similarly named object.

The intended parent workflow is:

1. `NSP-IntuneManager` inventories groups, enrollment profiles, and existing filters.
2. It resolves or plans creation of cookie-cutter filters from reusable blueprints.
3. The operator approves those tenant-wide resources.
4. The manager hands this Apps workbench stable group and filter IDs.
5. The app planner shows those resolved targets alongside each app before execution.

This supports Windows now without baking Windows-only assumptions into the eventual Android and iOS policy/app-configuration layers.
