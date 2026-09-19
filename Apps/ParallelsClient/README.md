# Parallels RAS Client — repair placeholder

This folder is excluded from deployment planning as `RequiresRepair`.

The previous source embedded one customer’s alias, gateway, full exported client profile, an endpoint download of a fixed major version over HTTP, a `C:\admin` working directory, and a fixed two-minute sleep. Those values and behaviors have been removed.

The intended source policy is now explicit: **resolve the latest official x64 MSI on the managed endpoint at installation time**, unless a documented compatibility requirement selects `Pinned`. This avoids rebuilding packages for every vendor release across every client. Both modes fail closed unless the downloaded MSI is HTTPS, has an MSI compound-file header, has a valid Authenticode signature, and matches the approved Parallels/Alludo signer pattern. Pinned mode additionally requires SHA-256 equality.

Before this app can become deployable:

1. copy `ParallelsConnection.config.psd1.example` to `ParallelsConnection.config.psd1` in an ignored/generated app workspace and fill in the connection alias, gateway, and port;
2. verify in the disposable VM that the official download-page resolver finds exactly one current x64 MSI and accepts its real signing certificate;
3. export a shared-device mode-1 connection from the current client and compare it with the minimal generated XML;
4. replace the broad installed-program detection with a version-aware contract;
5. expose these inputs through a guided generator and add Pester coverage;
6. test clean install, repeated install/upgrade, connection import, and uninstall.

The repair implementation defaults to `Latest`; `PinnedMsiUri` plus `PinnedSha256` is an explicit exception path. It fails closed while example values remain. No customer connection profile belongs in this upstream repository, and no credentials may be embedded in shared-device configuration.
