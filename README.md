# NSP-IntuneApps

Source catalog and operator workbench for building, signing, planning, and deploying Microsoft Intune applications.

The maintained implementation roadmap and decision log is [PLAN.md](PLAN.md).

The current technical handoff, including uncommitted work and validation evidence, is [HANDOFF.md](HANDOFF.md).

Disposable installer testing and VM handoff instructions are in [docs/TestVM.md](docs/TestVM.md).

This repository is intentionally **public-safe source only**. Generated `.intunewin` packages, executable vendor payloads, and private-key artifacts are ignored and blocked by preflight. Large, non-downloadable payloads such as printer drivers belong in an approved private artifact repository and are represented here by pinned, SHA-256-verified manifests.

## Start the Apps workbench

```powershell
.\Start-NSPIntuneApps.ps1
```

The dashboard currently provides:

- repository preflight and recursive PowerShell syntax validation;
- catalog classification for deployable, shared, incomplete, and Gen1 legacy entries;
- guided DriveMap, RDP/RemoteApp, printer driver/queue, FortiClient VPN configuration, and web/file shortcut generators;
- a technician-guided interactive-installer capture draft;
- resumable, one-app-at-a-time approve/skip deployment trackers;
- an offline update-action resolver that preserves existing Intune object IDs and stops on ambiguous ownership;
- code-signing generation status and read-only Intune trust planning.

Discovery and planning are read-only. Certificate creation requires an elevated, explicit command. Tenant writes require `Publish-NSPCodeSigningTrust -Execute` plus confirmation. No dashboard path silently deletes and recreates an app.

The update strategy and management markers are defined in [docs/DeploymentEngine.md](docs/DeploymentEngine.md). Compatible content revisions are planned against the existing object; breaking changes use side-by-side supersedence; unmarked or duplicate matches stop for review.

## Build/operator dependencies

- Windows PowerShell 5.1 or PowerShell 7 on Windows;
- `NSP.Bootstrap` for shared operator helpers such as secure random password generation and module installation;
- `IntuneWin32App` only when package/build/upload operations are used;
- Microsoft Graph PowerShell authentication only when a tenant plan or execution is requested;
- GitHub CLI authentication when retrieving assets from the approved private artifact repository.

Generated endpoint packages remain self-contained and do not require `NSP.Bootstrap` on managed devices.

## Code-signing model

The active signing generation is pinned by exact thumbprint in `Z-MiscSetup/CodeSigning/CodeSigning.config.json`. A PFX or other private-key artifact must never be committed. Certificate generation writes the encrypted PFX under ignored `Config/Local/CodeSigning`; its password and approved recovery copy belong in Password Boss or another private recovery location. Public CER and OMA-URI material may be versioned.

The Intune profile is named `NSP Code Signing` and contains separate Root and Trusted Publisher OMA-URI entries. New generations are added while old generations remain trusted for timestamped packages. Existing conflicting profiles stop execution for manual review; they are not automatically deleted or consolidated.

## Scope

This is the Apps workbench, not the future tenant-wide manager. See [docs/Architecture.md](docs/Architecture.md) for the boundary with the planned `NSP-IntuneManager`, including configuration profiles, compliance, notification templates, mobile platforms, filters, groups, and enrollment-profile targeting.

The downstream archived-area review is captured in [docs/ArchivedAppInventory.md](docs/ArchivedAppInventory.md); it found no archived family missing from upstream.

## Validation

```powershell
.\tools\Test-Repo.ps1
```

The validation runner always performs parser, module-import, catalog, and preflight checks. It also runs the Pester suite when Pester 5 or newer is installed.
