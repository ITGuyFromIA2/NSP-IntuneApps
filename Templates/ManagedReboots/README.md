# Managed Reboots generator

`New-NSPManagedRebootsApp` creates a self-contained policy app. A SYSTEM scheduled task evaluates maximum uptime and standard Windows pending-reboot signals. When action is needed, it uses the reusable WTS/per-user scheduled-task prompt bridge in `Templates/UserPrompt`.

The final deadline is a hard boundary. A deferral suppresses prompts for the configured interval but never moves that boundary. If no user is logged on, the evaluator waits until the deadline rather than rebooting immediately. At the deadline, Windows receives a scheduled restart with the configured countdown.

The generated package has no ServiceUI, AnyBox, PSGallery, or endpoint module dependency and does not write to `C:\admin`.
