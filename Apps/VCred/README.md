# Microsoft Visual C++ Redistributables

This is the self-contained Intune wrapper around the reusable VCred logic first refined in `NSP-FGTIPSecTools`. The endpoint does not require that toolset or `NSP.Bootstrap`.

The default configuration installs the current v14 family for x86 and x64. Microsoft documents v14 as the shared, binary-compatible runtime for Visual Studio 2017–2026: <https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist>. The catalog also retains explicit opt-in support for the unsupported 2005, 2008, 2012, and 2013 side-by-side runtimes when an application genuinely requires one.

Change `Source/VCred.config.json` and the matching copy under `Detect` together. Do not enable a legacy runtime merely because it exists in the catalog.
