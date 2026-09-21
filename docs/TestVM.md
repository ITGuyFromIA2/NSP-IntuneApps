# Disposable test VM runbook

This VM is the evidence-gathering environment for installers and endpoint behavior. It is not connected to a production tenant and must not contain production credentials, certificates, license keys, customer names, internal addresses, or client configuration.

## Prepare the VM

1. Use a current Windows 11 VM and take a clean checkpoint before installing test dependencies.
2. Leave Microsoft Defender and real-time protection enabled with their normal policy.
3. Install the Codex Windows app if Codex will work directly in the VM, then clone/open this public source repository.
4. Do not preinstall Parallels Client, AutoIt, or AutoHotkey. The first readiness snapshot records the clean state.
5. From an elevated Windows PowerShell 5.1 console in the repository, run:

   ```powershell
   .\tools\VM\Test-NSPTestVMReadiness.ps1
   .\tools\Test-Repo.ps1
   ```

Generated evidence is written below the ignored `Config\Local\VMResults` directory. Commit no VM result containing local machine or environment data.

## Parallels sequence

The endpoint policy is latest-by-default. `Pinned` is reserved for an explicit compatibility need.

1. Copy `Apps\ParallelsClient\Source\ParallelsConnection.config.psd1.example` to the ignored `ParallelsConnection.config.psd1` and use documentation-only test values initially.
2. Prove source resolution and validation without installing anything:

   ```powershell
   & .\Apps\ParallelsClient\Source\DownloadInstall_ParallelsClient.ps1 -DownloadOnly
   ```

   Confirm the resolver obtains exactly one x64 MSI from the official Parallels JSON catalog and reports a valid signer and SHA-256.
3. Run the same script without `-DownloadOnly` to install. Record the resolved URI, signer subject, MSI product/version, process exit code, installed-program record, and installed executable signature.
4. Export a mode-1 shared-device connection from the installed current client. Compare its non-secret structure with the generated minimal XML. Do not use mode 2 and do not save credentials.
5. Re-run the installation to exercise update/repair behavior. Parallels documents that MSI properties may be ignored during repair, so explicitly verify the shared connection rather than assuming it was reapplied.
6. Run uninstall and verify installed-program, files, services, and shared-connection residue.
7. Revert to the clean checkpoint and repeat once with a deliberately invalid signer/hash test fixture to prove fail-closed behavior without executing it.

Do not mark the app Deployable until clean install, repeat/upgrade, configuration, detection, and uninstall evidence is reviewed.

Initial download-only evidence was recorded on 2026-09-19. The official catalog resolved `RASClient-x64-21.2.27311.msi`; its MSI ProductVersion is 21.2.27311, ProductCode is `{488DEDE2-4326-430D-96B0-FEE0C9B3B9EB}`, SHA-256 is `A675997CF1F9AFEE8E773C8F84AA34C1442A73191DFB113122373F32FAB2C43B`, and the Authenticode signature is valid from Parallels International GmbH.

Full install/repair/uninstall evidence was recorded on this disposable VM on 2026-09-21 using a documentation-only connection (`Alias=NSP-Test-RAS`, `Server=203.0.113.10` per RFC 5737, `Port=443`). `Apps/ParallelsClient/Source/ParallelsConnection.config.psd1` is now correctly gitignored (it was not before this session; `.gitignore` only had blanket extension/directory patterns, not this file).

- **Install**: `msiexec` exit 0. `Parallels Client 64-bit` 21.2.27311 registered under Parallels International GmbH; `RAS RDP Backend Service` running; installed executable (`APPServerClient.exe`) has a valid Authenticode signature from the same publisher, thumbprint `53E0A7430A45E49ED94973B08945D007553645CD`.
- **Shared-device import**: the generated mode-1 XML lands in the registry at `HKLM:\SOFTWARE\Parallels\AppServerClientSharedDevice` (`Alias=NSP-Test-RAS`, `SharedDeviceMode=1`, `Domain`/`Password`/`UserName` all empty) with the connection itself under its `Conn0000` subkey (`Mode=2`, `Server=203.0.113.10`, `ServerPort=443`). No credentials are present, matching the source XML.
- **Repeat/upgrade**: re-running the same install command (same version) exits 0 and the shared-connection registry values are byte-for-byte identical afterward — explicitly verified rather than assumed, per the note above about MSI repair possibly ignoring properties.
- **Uninstall**: removes the installed-program record, the `RAS RDP Backend Service`, and `C:\Program Files\Parallels\Client`. It does **not** remove `HKLM:\SOFTWARE\Parallels\AppServerClientSharedDevice` — the connection alias and server address remain as registry residue after uninstall. No credentials are in that residue, but note it for anyone who needs the machine fully scrubbed between tenants.
- **Fail-closed behavior**: verified without a checkpoint revert, using `Pinned` `SourceMode` against the already-downloaded, otherwise-valid MSI. A deliberately wrong `PinnedSha256` throws `Pinned Parallels MSI hash mismatch...` before install; a deliberately unmatchable `ExpectedSignerPattern` throws `...does not match the approved signer pattern.` after a correct hash. Neither path reaches `msiexec`. The full "revert to clean checkpoint and repeat with an invalid fixture end-to-end" step from the sequence above still requires host-level snapshot management this session doesn't have access to from inside the guest.

Parallels is now install/repair/uninstall-verified; it remains `RequiresRepair`/not yet `Deployable` until a guided configuration generator exists (the connection file is still hand-authored) and the catalog classification is updated accordingly.

## Bitdefender wrapper validation

The public source tree does not contain the Bitdefender wrapper or a tenant package ID. First validate only the official fetch and signer boundary:

```powershell
& .\Apps\BitDefender\Source\DownloadInstall_BEST.ps1 -DownloadOnly
```

Confirm that the download succeeds over HTTPS, reports `Valid`, identifies Bitdefender as the signer, prints a SHA-256 value, and removes its temporary MSI. Do not put a production GravityZone package ID into the VM readiness transcript or repository. A later disposable-tenant execution test may pass `-PackageId` interactively after the output/transcript boundary is reviewed.

## Interactive-installer/AV sequence

AutoIt is the leading functional engine, but delivery remains undecided because a newly compiled automation executable may attract AV or reputation scrutiny.

1. Take a checkpoint. Install a reviewed AutoIt release only inside the VM.
2. Use `Start-NSPInstallerCapture` against a harmless disposable installer and produce a sanitized schema-v2 capture.
3. Implement the same minimal workflow as interpreted `.au3` and as an AutoIt-compiled `.exe`. Do not sign either with the production code-signing certificate during the first comparison.
4. Scan both artifacts without remediation:

   ```powershell
   .\tools\VM\Invoke-NSPDefenderComparison.ps1 -CandidatePath .\Runner.au3,.\Runner.exe
   ```

5. Record Defender results, SmartScreen/reputation behavior, execution behavior as SYSTEM and interactive user, and whether the compiled binary remains stable after packaging.
6. Repeat after signing the reviewed compiled runner with a disposable test certificate if that comparison is useful. Never upload proprietary installers or private automation samples to public malware-analysis services.

Initial local evidence was recorded on 2026-09-19 with the official portable AutoIt 3.3.18.0 release. The x64 interpreter ran the harmless probe successfully, Aut2Exe compiled the same source to an unsigned x64 console executable, and Microsoft Defender custom scans returned exit code 0 with no detections for either artifact. The ignored report is `Config\Local\VMResults\DefenderComparison-AutoIt-20260919.json`.

### SYSTEM context and SmartScreen, recorded 2026-09-21

Using the same `Probe.au3`/`Probe.exe` (identical SHA-256 to the 2026-09-19 evidence), staged into `Config\Local\AutoItAudit\SystemContext\`:

- **SYSTEM context, no Mark-of-the-Web**: both the interpreted script (via `AutoIt3_x64.exe`) and the compiled `.exe`, run through a temporary scheduled task (`SYSTEM` principal, `ServiceAccount` logon, highest run level, deleted immediately after each run), completed with `LastTaskResult 0` and the expected output file written. No prompt, no delay worth noting.
- **Interactive session, with Mark-of-the-Web**: a copy (`Probe-downloaded.exe`) was tagged with a `Zone.Identifier` alternate data stream (`ZoneId=3`, simulating a real internet download) and launched with plain `Start-Process` — **not** `ShellExecute`, on the assumption that only Explorer's shell verb triggers SmartScreen's consent UI. That assumption was wrong: it produced an interactive "Windows protected your PC" prompt in the operator's session, which the human operator had to click through manually. Recorded here as a caution for the next person testing this: expect that prompt if you repeat this step on an interactive desktop, and warn whoever's watching the screen before you trigger it — this session didn't, the first time.
- **True SYSTEM context, with Mark-of-the-Web**: the same MOTW-tagged `Probe-downloaded.exe`, run through the same kind of temporary SYSTEM/`ServiceAccount` scheduled task (Session 0, no interactive desktop) with a bounded 45-second poll rather than an indefinite wait. It completed in about 3 seconds with `LastTaskResult 0`, the output file freshly rewritten, no lingering process, and no Microsoft-Windows-Windows Defender/Operational event logged for the run. **No prompt appeared and none was needed** — SmartScreen's interactive consent check did not block or delay execution in a non-interactive SYSTEM session, even for the identical MOTW-tagged, unsigned, freshly-compiled binary that required a manual click when launched interactively.

This is a direct answer to the open "delivery choice" question: Intune Management Extension deploys and executes as SYSTEM, non-interactively — the same context that ran clean here, not the interactive-desktop context that needed a click. An unsigned compiled AutoIt executable does not appear to be blocked by SmartScreen under the deployment mechanism this app actually uses, even carrying Mark-of-the-Web. This is one disposable VM's evidence, not a guarantee across builds, policy configurations, or SmartScreen's cloud-reputation state (which can change independently of anything in this repository as the binary's hash accumulates — or fails to accumulate — real-world reputation); treat it as a strong signal, not a closed case, before finalizing the interpreted-vs-compiled decision.

### Realistic captured installer, recorded 2026-09-21

The human operator ran `Start-NSPInstallerCapture` interactively against the official Notepad++ v8.9.8 x64 installer (`npp.8.9.8.Installer.x64.exe`, downloaded from `github.com/notepad-plus-plus/notepad-plus-plus` releases, Authenticode-valid, `CN="NOTEPAD++"`, no Mark-of-the-Web since it was fetched with `Invoke-WebRequest`). Capture is at `Config\Local\InstallerCaptures\npp.8.9.8.Installer.x64-20260921-131726.json` (9 steps: language dialog, welcome, license, choose components, choose install location, create-desktop-shortcut checkbox, install, uncheck run-after-install, finish).

Two real things were learned doing this, both worth carrying forward:

1. **The capture tool's first attempt was wrong**, and it's a real gap in `Start-NSPInstallerCapture`, not operator error alone: pressing the hotkey right after *hovering* the mouse over a button doesn't capture that button, because hovering never sets Win32/UI-Automation keyboard focus — the tool captures `AutomationElement.FocusedElement`, which was still whatever had focus by default on that screen. The fix that worked: **Tab to the control until it visibly has focus, then hotkey, then click/activate it.** The tool would be more forgiving if it captured "last element the mouse clicked" (a low-level mouse hook) instead of, or in addition to, focus — worth a future improvement, not done in this session.
2. **Implementing the capture as AutoIt needs control IDs, not button text.** This NSIS installer's buttons all report `ControlType.Pane` under UI Automation (not `ControlType.Button`), and their real Win32 window text includes the mnemonic ampersand — `&Next >`, not `Next >` — so a naive `ControlClick(..., "[TEXT:Next >]")` silently fails to find the control. NSIS also reuses Win32 control ID `1` for the primary action button on every single screen (Next/I Agree/Install/Finish all share ID 1) and gives checkboxes their own stable IDs (`1200` for "Create Shortcut on Desktop", `1203` for "Run Notepad++" on the finish screen) — which is exactly what the capture's `AutomationId` field already recorded correctly for every step. The working implementation uses `[ID:n]` selectors built from that field, not the `Control.Name` text. This first attempt hung twice against real button clicks that silently no-op'd before this was diagnosed via direct Win32 `EnumChildWindows`/`GetWindowText` calls; worth remembering that as the diagnostic technique if a future capture's `ControlClick` mysteriously does nothing.

The resulting automation (`Config\Local\InstallerCaptures\Install-NppCapture.au3`, compiled to `Install-NppCapture.exe`) was run to completion, verified, uninstalled, and re-run three times total:

- **Interpreted, interactive session**: full 9-step sequence completed, exit 0. Verified: `Notepad++ (64-bit x64) 8.9.8` registered, desktop shortcut created (the checkbox step worked), Notepad++ did **not** auto-launch (the uncheck step worked), setup window closed. Uninstalled cleanly (`uninstall.exe /S`, exit 0) before the next run.
- **Compiled, interactive session**: identical outcome, exit 0, same verification, Microsoft Defender custom scan found no threats in either the `.au3` or the compiled `.exe` (`Config\Local\VMResults\DefenderComparison-20260921-133555.json`). Uninstalled again before the next run.
- **Compiled, true SYSTEM scheduled task (Session 0, no interactive desktop)**: a genuinely different and informative result. The language dialog's OK button *did* get clicked successfully — Session 0 has its own non-interactive desktop, and `ControlClick`'s `SendMessage`-based click doesn't require a human-visible window. But the main setup wizard window that should follow never became queryable the same way (its process ran, but `MainWindowTitle` came back empty, and the script's `WinWait` correctly timed out rather than hanging indefinitely) — Notepad++ was never installed by that run. This is a real negative result, not a bug in the automation: a GUI installer wizard does not reliably drive to completion under a true non-interactive SYSTEM session, which is consistent with why Intune Management Extension deploys system-context apps via silent/unattended command-line installers rather than GUI automation, and reserves an approach like this one for **user-context** app deployment (`InstallExperience = 'user'`), where a real interactive desktop exists. Worth remembering as a design constraint the next time this pattern gets used for a real catalog app, not just this test.

This closes out the "realistic captured installer" gap noted earlier. Package-stability, interpreted-vs-compiled, and SYSTEM-vs-interactive are all now answered for a real multi-screen installer, not just the harmless synthetic probe above — with the caveat that "SYSTEM context" only cleanly applies to non-GUI payloads (like the AutoIt probe earlier); a GUI wizard installer's natural home is user-context deployment.

The initial implementation preference is interpreted/source-based AutoIt if it is operationally supportable. A compiled runner becomes the default only if VM evidence shows acceptable AV behavior and a meaningful deployment advantage. PowerShell remains the orchestrator and secret boundary; the UI engine receives only the runtime values needed for the current action.

## Windows Sandbox

Sandbox is useful for fast clean-room capture and basic install/detect/uninstall checks. It does not replace the checkpointed VM for reboot, Intune Management Extension, SYSTEM-to-user interaction, device drivers, printers, VPN, or tenant behavior.

Generate rather than commit machine-specific `.wsb` files:

```powershell
.\tools\Sandbox\New-NSPWindowsSandboxFile.ps1 -Mode Offline
.\tools\Sandbox\New-NSPWindowsSandboxFile.ps1 -Mode Networked
```

Offline is the default. Networked is an explicit choice for vendor resolution tests such as Parallels. Both map the repository read-only and expose only the ignored results directory as writable.

## SetACL provenance audit

DelegateService does not embed SetACL in source or in the Intune package. The provenance audit was completed on 2026-09-19; disposable-service install, detection, and uninstall testing remains required before promotion.

```powershell
. .\Apps\DelegateService\Source\Get-NSPSetAcl.ps1
$audit = Get-NSPSetAcl -AuditOnly
$audit | Format-List Version, Uri, ArchiveLength, ArchiveSha256
$audit.Executables | Format-Table Architecture, RelativePath, Length, Sha256, ProductVersion, SignatureStatus, SignerSubject -AutoSize
```

The reviewed publisher archive is pinned as SHA-256 `BA74399A70963C156580180455FBFC0FA68EA673A64EB89010A46273C7D478CC`. It contained exactly one x86 executable (`9E2E0F10F6DDE0E19E441DEC7A6F14A813E5D39E9D7F70B2B48B88491F69BB9B`) and one x64 executable (`4EFC87B7E585FCBE4EAED656D3DBADAEC88BECA7F92CA7F0089583B428A6B221`). Both reported product version 3.1.2.86 and valid Authenticode signatures from vast limits GmbH. Rerun the audit before a release to detect publisher-side drift.

### Service delegation, functionally verified (2026-09-21)

`DownloadInstall_DelegateIntuneService.ps1`/`Uninstall_DelegateIntuneService.ps1` were exercised end to end on this disposable VM against a throwaway service and a throwaway non-admin local user, both deleted afterward — not against a production DelegateService install:

1. Created service `NSPTestSvc` (`sc.exe create ... binPath= "cmd.exe /c exit"`) and local user `NSPDelegateTest` (standard, non-admin).
2. Baseline: `sc start NSPTestSvc` as `NSPDelegateTest` before any delegation fails with **exit 5, "Access is denied."**
3. Ran `DownloadInstall_DelegateIntuneService.ps1 -ServiceName NSPTestSvc -DelegateTo NSPDelegateTest`: exit 0.
4. Same `sc start` as the same user now fails with **exit 1053, "The service did not respond..."** — a different failure than access-denied, proving the grant is functionally effective (the dummy binary isn't a real service, so it can't succeed, but it's no longer being rejected at the ACL). Independently confirmed via `SetACL ... -actn list`, which shows `<machine>\NSPDelegateTest  start_stop  allow`.
5. Ran `Uninstall_DelegateIntuneService.ps1 -ServiceName NSPTestSvc -DelegateTo NSPDelegateTest`: exit 0.
6. Same `sc start` as the same user reverts to **exit 5, "Access is denied."** — delegation was actually revoked, not just left stale. The trustee line is gone from `SetACL ... -actn list`.

The SetACL supply boundary and the delegation/revocation mechanics are both verified. `Detect_DelegateIntuneService.ps1` (the real, unparameterized production script, hardcoded to `ServiceName=IntuneManagementExtension` and `DelegateTo="Power Users"` — matching `DelegateService_IntuneService_SplitScriptSettings.ps1`'s actual deployment args) was also run as-is: it correctly exits `1` on this VM, because `IntuneManagementExtension` doesn't exist here (this VM isn't Intune-enrolled, by design — see the top of this document). That's the right, fail-closed answer for a machine where the target service is absent, but it means the detect script's true-positive path (finding the real ACE on the real service name) is still unverified on this VM. Deliberately did not create a stub service literally named `IntuneManagementExtension` to force that path — impersonating a real Microsoft service name felt like the wrong kind of shortcut even on disposable hardware. That path needs either real tenant/Intune enrollment or accepting that risk consciously, and either way is a call for whoever owns that decision, not an automatic one.
