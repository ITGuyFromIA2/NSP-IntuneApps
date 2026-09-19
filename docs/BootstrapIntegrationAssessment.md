# NSP.Bootstrap and repository-boundary assessment

This assessment applies the PoSHRepo `ClaudeStuff` reorganization guidance to NSP-IntuneApps without changing PoSHRepo, NSP-Bootstrap, or any other repository.

## Repository boundary

The cross-repository reconciliation identifies NSP-IntuneApps as the existing canonical home for the proposed `NSP.IntuneApp` toolkit. It also recommends keeping the established one-repository-per-tool model instead of moving sibling tools into a PoSHRepo monorepo. This repository therefore remains a standalone module/workbench with domain functions that a future NSP-IntuneManager can orchestrate.

PoSHRepo copies should eventually become origin/attic material during that repository’s separately approved reorganization. This project does not edit or reorganize them.

## Bootstrap usage now

NSP.Bootstrap is an operator/build dependency for capabilities it already owns:

- `New-NSPRandomPassword` for code-signing PFX generation;
- `Install-NSPModule` for optional Graph dependencies;
- `Get-NSPSecret` for an exact named PFX-password lookup, with an interactive Password Boss recovery prompt when the local NSP vault is not populated.

Generated endpoint packages remain self-contained. They do not import NSP.Bootstrap on managed devices.

`Import-NSPBootstrap` is intentionally a small local adapter. Bootstrapping the bootstrap module is the one place that may still call `Install-Module` directly; once imported, dependency installation goes through `Install-NSPModule`.

## Do not move yet

The following may be broadly useful, but the user requested discussion before promoting endpoint or app-specific behavior into NSP.Bootstrap:

- dashboard rendering and menu choice helpers;
- deployment-plan/run-journal state machines;
- WTS active-user discovery and per-user prompt-task bridging;
- deterministic app-source hashing;
- artifact-manifest retrieval;
- a standardized `Success/Data/ProcessDebug/Raw` result shape;
- elevation/re-execution helpers.

The first five are currently Intune/application-domain behavior and should remain here. The last two are plausible Bootstrap candidates only after their cross-repository callers and required PowerShell 5.1 behavior are agreed.

## Compatibility and testing

The PoSHRepo plan sets Windows PowerShell 5.1 as the default floor and Pester 5+ as the module-testing convention. The module manifest already declares 5.1. The repository gate now also launches `powershell.exe` when available, parses every PowerShell source file under the 5.1 parser, and imports the module in 5.1 before the PowerShell 7 preflight/Pester suite continues.

This is separate from generated endpoint compatibility testing. Install/detect/uninstall scripts still need disposable-VM execution for vendor-specific behavior.

## Secret boundary

Password Boss remains the shared recovery/source-of-truth location for the PFX password. NSP.Bootstrap’s vault is an optional local operational cache/resolution layer; it is not presumed to integrate natively with Password Boss. The encrypted PFX stays separate in this private repository. The repository must never log or persist the password, Base64 private key, or sensitive runtime-parameter values.
