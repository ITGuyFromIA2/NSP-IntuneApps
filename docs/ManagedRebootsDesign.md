# Managed Reboots redesign notes

## Preserve the behavior, not the package

The downstream prototype established four useful requirements:

1. detect Windows servicing and application reboot signals;
2. enforce a configurable maximum uptime;
3. warn an interactive user and allow a bounded number of deferrals;
4. reset deferral state after a successful reboot.

The existing files are unsuitable for direct upstream promotion. They install a gallery UI module on endpoints, depend on an embedded session-bridging executable, write logs/state under `C:\admin`, modify app source during packaging, and carry tenant test assignments.

## Proposed replacement

Use a two-layer, self-contained design:

- a SYSTEM evaluator owns policy, pending-reboot detection, deadlines, enforcement, and machine state under `C:\ProgramData\NSP\ManagedReboots` plus `HKLM:\SOFTWARE\NSP\ManagedReboots`;
- an interactive-user notifier displays only the current machine-authored state and records a constrained response through a machine-created, user-writable response file or named channel;
- a SYSTEM follow-up validates the response, advances the deferral/deadline state, and performs the reboot when required;
- tasks use versioned names and deterministic action/trigger definitions that detection can compare field by field;
- installation, detection, and uninstall never download PowerShell modules or modify package source;
- assignments are always supplied by the deployment plan, never embedded in the upstream app.

The notifier will reuse the proven SuperScript prompt bridge as a self-contained template: SYSTEM discovers fully qualified active console/RDP users with the WTS API, creates transient per-user scheduled tasks using interactive tokens, and collects the first WinForms response. This removes the need for ServiceUI, AnyBox, an always-running user process, or another binary. The genericized implementation preserves the domain-qualified-user XML repair and task cleanup while moving display text into JSON to avoid scheduled-task argument injection.

## Required tests before deployable status

- no pending reboot and uptime below threshold;
- each individual pending-reboot signal;
- uptime-only enforcement;
- user accepts immediately;
- user defers until the configured limit;
- user ignores the prompt before and after the final deadline;
- no interactive user session;
- multiple user sessions;
- reboot resets state;
- reinstall/repair preserves policy but repairs tasks;
- uninstall removes tasks/state without rebooting the device.
