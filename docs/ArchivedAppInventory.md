# Archived downstream app inventory

Inventory date: 2026-09-18

Scope: immediate app folders under downstream `Unused`, `RetiredApps`, `OrigApps`, and `Testing` directories. Generated `.intunewin` files were excluded from source comparisons.

## Conclusion

The archived areas contain no missing upstream app family. All 21 named app families already exist under `NSP-IntuneApps\Apps`.

- 18 families have at least one byte-for-byte source-equivalent archived copy.
- `MachineVPN`, `UserVPN`, and `ScreenConnect` intentionally differ because the upstream copies were repaired and stripped of downstream customer defaults.
- `Testing` contains only two loose PowerShell experiments and no app folder suitable for promotion.
- Archived `.intunewin` outputs are generated artifacts and are not promotion candidates.

## Family summary

| Family | Archived copies | Distinct archived source versions | Exact source-equivalent upstream copy |
|---|---:|---:|---|
| 365Apps | 1 | 1 | Yes |
| BitDefender | 6 | 2 | Yes |
| Chrome | 4 | 2 | Yes |
| DCU_DriverScan | 4 | 1 | Yes |
| DCU_DriverUpdate | 4 | 1 | Yes |
| DCU_Shared | 4 | 1 | Yes |
| DelegateService | 6 | 1 | Yes |
| DellCommandUpdate | 4 | 1 | Yes |
| Firefox | 4 | 1 | Yes |
| FortiClient | 4 | 1 | Yes |
| FortiClient_ImportConfig | 5 | 2 | Yes |
| Huntress | 1 | 1 | Yes |
| MachineVPN | 6 | 1 | No; upstream intentionally repaired/sanitized |
| ManualIntuneSync | 6 | 1 | Yes |
| ParallelsClient | 6 | 1 | Yes |
| RemoteDesktop-Shortcut | 6 | 1 | Yes |
| ScreenConnect | 3 | 2 | No; upstream intentionally sanitized |
| TRAFx | 7 | 1 | Yes |
| TRAFxDrivers | 7 | 1 | Yes |
| UserVPN | 6 | 1 | No; upstream intentionally repaired/sanitized |
| VLC | 3 | 1 | Yes |

This inventory is evidence against promoting anything directly from the archived areas. Future app-port work should use active downstream folders and select one generic champion per duplicate family.
