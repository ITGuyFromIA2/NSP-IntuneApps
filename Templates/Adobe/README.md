# Adobe Acrobat and Reader app generator

Use `New-NSPAdobeApp` to turn a reviewed Adobe package into a self-contained generated app under the ignored `Config/Local/GeneratedApps` area.

Modern 64-bit Acrobat uses Adobe's unified installation model: the same installation provides Reader behavior to users without an Acrobat entitlement and Standard/Pro features to appropriately licensed users. Do not create separate Standard and Pro apps solely by renaming the unified installer.

Supported input models:

- `UnifiedBootstrapper`: the current 64-bit Acrobat/Reader bootstrapper; default silent arguments are `/sAll /rs`.
- `StandaloneReader`: a standalone Reader package, including an intentional 32-bit compatibility deployment. The operator can ask Evergreen to resolve and download this package at build time.
- `AdminConsole`: a reviewed package created in Adobe Admin Console; default silent argument is `--silent`.

For directory or ZIP input, the wizard auto-detects exactly one `Setup.exe`, or accepts an explicit safe relative path. Every payload file is SHA-256 recorded and verified on the endpoint before execution. Evergreen is an optional operator dependency and is never installed on, or required by, the endpoint.

The generic uninstall implementation only executes MSI product-code removal. If an Adobe package uses a non-MSI removal mechanism, validate it and intentionally extend the generated package rather than executing an arbitrary registry command line.
