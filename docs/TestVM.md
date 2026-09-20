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

   Confirm the resolver obtains exactly one x64 MSI from the official Parallels page and reports a valid signer and SHA-256.
3. Run the same script without `-DownloadOnly` to install. Record the resolved URI, signer subject, MSI product/version, process exit code, installed-program record, and installed executable signature.
4. Export a mode-1 shared-device connection from the installed current client. Compare its non-secret structure with the generated minimal XML. Do not use mode 2 and do not save credentials.
5. Re-run the installation to exercise update/repair behavior. Parallels documents that MSI properties may be ignored during repair, so explicitly verify the shared connection rather than assuming it was reapplied.
6. Run uninstall and verify installed-program, files, services, and shared-connection residue.
7. Revert to the clean checkpoint and repeat once with a deliberately invalid signer/hash test fixture to prove fail-closed behavior without executing it.

Do not mark the app Deployable until clean install, repeat/upgrade, configuration, detection, and uninstall evidence is reviewed.

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

DelegateService remains non-deployable until this audit is completed. It does not embed SetACL in source or in the Intune package.

```powershell
. .\Apps\DelegateService\Source\Get-NSPSetAcl.ps1
$audit = Get-NSPSetAcl -AuditOnly
$audit | Format-List Version, Uri, ArchiveLength, ArchiveSha256
$audit.Executables | Format-Table Architecture, RelativePath, Length, Sha256, ProductVersion, SignatureStatus, SignerSubject -AutoSize
```

Record the complete output in the test evidence. Confirm that there is exactly one x86 and one x64 executable, both report the expected 3.1.2 product version, and the archive came from `helgeklein.com`. After review, replace `REPLACE_AFTER_VM_VALIDATION` in the helper with the uppercase archive SHA-256 and rerun the audit. Only then test DelegateService install, detection, and uninstall against a disposable service or the intended test service.
