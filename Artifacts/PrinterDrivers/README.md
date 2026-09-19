# Printer driver release assets

Large vendor driver payloads are source inputs, but they do not belong in normal Git history. Store each payload as a ZIP in a private GitHub Release and commit only a pinned manifest beside the printer-driver template.

Each manifest records:

- private GitHub repository and immutable release tag;
- exact asset filename;
- SHA-256 hash;
- expected INF path and Windows printer-driver name;
- vendor source URL and version notes for human traceability.

`Get-NSPReleaseAsset` downloads through the authenticated GitHub CLI and refuses a hash mismatch. It never stores a GitHub token in an Intune package. Release publication remains a deliberate operator action; this repository does not silently upload assets.

Copy `PrinterDriver.release.example.json`, replace every placeholder, upload the ZIP to the matching private release, and verify the resulting manifest before using it in a generated driver app.

## Staged first wave

The first generic candidates use the `printer-drivers-v1` tag in `ITGuyFromIA2/NSP-IntuneApps`:

| Driver | Raw payload | ZIP | Reduction | Manifest state |
|---|---:|---:|---:|---|
| Canon Generic Plus UFR II 2.72.0.0 | 63.82 MiB | 20.08 MiB | 68.5% | Hash-pinned; release upload and provenance review pending |
| HP Universal Printing PCL 6 61.240.01.24630 | 53.61 MiB | 19.81 MiB | 63.1% | Hash-pinned; release upload and provenance review pending |

A comparison run against a Brother HL-L2370DW payload reduced 31.63 MiB to 29.69 MiB (6.2%), demonstrating that ZIP effectiveness varies significantly by vendor payload. ZIP remains useful as a single intentional release artifact even when the bytes are already compressed.

The staged ZIPs are intentionally Git-ignored. Do not mark these manifests ready for normal generation until the assets are uploaded to the private release and the legacy payload provenance/redistribution notes are reviewed.
