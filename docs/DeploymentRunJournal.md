# Deployment run journal

The run journal is the durable handoff between an approved deployment tracker and the future Graph executor. It is local operator state under `.nsp-intuneapps/runs` and is ignored by Git.

`New-NSPAppDeploymentRun` accepts only an inventory-resolved plan whose entries have all received Approve or Skip decisions. It queues approved apps in their reviewed order and expands each planned action into explicit stages:

- create: validate, build, sign, package, create, record management notes;
- metadata update: validate, patch the existing object, record management notes;
- content update: validate, build, sign, package, upload and commit content, record management notes;
- supersedence: validate, build, sign, package, create side-by-side, add the reviewed relationship, record management notes;
- no change: validate only.

Creating a journal performs none of those operations. `Set-NSPAppDeploymentRunStage` only records a stage transition made by a future executor or an explicitly supervised operator. It enforces one app at a time and requires `Pending/Failed -> Running -> Succeeded/Failed`. A failure remains the current stage and can be retried; later apps cannot be bypassed.

Every transition is written to disk immediately using a replacement file. `Get-NSPAppDeploymentRunSummary` reconstructs the current app/stage from that file after a process exit or machine restart. Transition messages must be concise and must never contain secrets, tokens, package bytes, or sensitive runtime-parameter values.

This state machine does not grant Graph permissions or authorize writes. The Graph executor remains deliberately unimplemented until its metadata, content-upload, and supersedence operations have independent safety and integration coverage.
