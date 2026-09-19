# Printer templates

Printer drivers and printer queues are separate generated apps. A driver app contains one ZIP artifact and installs one exact Windows driver name. Any number of queue apps can depend on it while supplying their own safe, tenant-local name, address, and preferences.

Large driver ZIPs belong in a private GitHub Release. Commit only a pinned manifest under `Artifacts/PrinterDrivers`; the generator verifies its SHA-256 value and embeds the downloaded ZIP in the generated app. Endpoints never need GitHub or vendor-network access.

Use `New-NSPPrinterApp -RepoRoot <path> -Interactive` for the short wizard. Generated tenant-specific apps default to the Git-ignored `Config/Local/GeneratedApps` directory.

`Examples` contains one sanitized queue configuration for each curated first-wave driver. The addresses use IANA documentation networks and must be replaced through the wizard; the examples are never deployment-ready client instances.
