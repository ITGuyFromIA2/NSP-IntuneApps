# Vendor dependency procurement

NSP-IntuneApps is source-only. Vendor executables, MSI files, DLLs, private keys, and generated `.intunewin` files do not belong in Git. Retrieval behavior depends on the vendor's intended distribution model and on whether endpoint internet access is an acceptable runtime requirement.

## Current decisions

| Dependency | Retrieval point | Validation | Source-tree status |
|---|---|---|---|
| Bitdefender BEST downloader wrapper | Endpoint, at install/uninstall time | HTTPS plus valid Bitdefender Authenticode signature | Wrapper MSI excluded |
| SetACL 3.1.2 | Endpoint, at install time; persisted under `%ProgramData%\NSP\Tools` for detection/uninstall | Fixed publisher HTTPS URI, pinned archive SHA-256, safe ZIP layout, exact x86/x64 inventory | EXEs and ZIP excluded |
| ServiceUI from MDT 8456 | None | Not applicable | Removed; no active package depends on it |

SetACL's publisher identifies the tool as freeware but requires a distribution license when it is distributed with another application. Direct retrieval from the publisher avoids embedding the executable in NSP source or an Intune package. The version remains fixed because service ACL behavior is infrastructure, not an evergreen end-user application. The 2026-09-19 provenance audit recorded the archive and executable hashes, file versions, archive paths, and Authenticode state in [TestVM.md](TestVM.md). DelegateService still needs disposable-service install, detection, and uninstall tests before it can become deployable.

Microsoft retired the Microsoft Deployment Toolkit in January 2026. MDT receives no fixes or support, and Microsoft warns that its download packages may be removed. The two historical ServiceUI executables therefore have no automatic replacement. Managed Reboots already uses the native WTS/per-user scheduled-task bridge and does not need ServiceUI. If a future legacy app proves that ServiceUI is unavoidable, its design must explicitly document the consumer, pin a reviewed MDT 8456 source and hash, require operator opt-in, and include a migration path away from it.

## Fail-closed rules

- A download destination is always temporary or an application-specific `%ProgramData%\NSP` path.
- Retrieval uses a fixed HTTPS publisher host; redirects to an unexpected host are rejected where the HTTP client exposes the final URI.
- Mutable vendor content is not trusted only because its filename matches.
- Normal execution is blocked until stable artifacts have a reviewed SHA-256 value.
- ZIP extraction rejects traversal paths and unexpected executable inventory.
- Audit output may contain hashes, versions, paths, and signer identity, but never credentials or tenant enrollment values.
- A vendor download failure is an app-install failure; it never falls back to an unverified mirror.
