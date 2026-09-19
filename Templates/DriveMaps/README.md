# DriveMaps template

This template generates a self-contained Intune app from a small JSON configuration. The drive letter is data, not duplicated source code. The generated package copies its runtime into `ProgramData\NSP\DriveMaps`, then registers a user-logon scheduled task.

Use `New-NSPDriveMapApp -Interactive` for the guided path. Prompts include examples and defaults. Client names, real server names, and real UNC paths belong only in the downstream client repository.

The example uses the documentation-only `example.invalid` domain and is safe to retain upstream.
