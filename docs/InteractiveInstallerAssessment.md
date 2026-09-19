# Interactive installer assessment

The downstream Time Matters, HotDocs, and Tabs packages were evaluated as pattern sources, not copy candidates.

## Reusable patterns

- Ordered screens identified by window title plus expected visible text.
- Explicit control actions and repeated clicks where an installer requires them.
- Conditional screens and bounded waits for appearance or completion.
- Keyboard accelerators as a fallback when controls are not exposed reliably.
- Installer file/product version discovery and installed-program detection.

These concepts are represented by schema-v2 captures and the sanitized examples under `Templates/InteractiveInstaller/Examples`.

## Deliberately excluded

- Client names, internal paths, server names, shares, credentials, and license values.
- Fixed sleeps as the primary synchronization mechanism.
- Unpinned downloads or redistribution of an automation runtime without provenance.
- Unrelated machine changes, including removal of trusted-publisher certificates.
- A committed proprietary installer. The document-assembly example is metadata-only and uses placeholder instructions.

## Execution boundary

The PowerShell recorder observes and describes. It does not execute a captured workflow. A supported AutoIt adapter must later enforce process identity, window/title/text matching, timeouts, sensitive runtime-value handling, action results, and useful failure evidence. The first disposable-VM evaluation compares interpreted `.au3` delivery with the same runner compiled to `.exe`, because reputation-based AV treatment may outweigh the convenience of a self-contained binary. AutoHotkey remains a fallback only if a concrete AutoIt gap is found.

The old scripts demonstrate useful intent, but promoting their implementation would also promote client-specific data and brittle behavior. The schema preserves the modular, stepwise design while giving a future runner a stricter contract.
