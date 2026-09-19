# Shortcut template

This template creates one managed shortcut in the Public Desktop or common Start Menu. The generator supports a website in the default browser, a website forced into Edge or Chrome, or a file/program target. Client-specific output is written to `Config/Local/GeneratedApps` by default and is ignored by Git.

Detection validates the shortcut target and arguments rather than only checking that a similarly named file exists.
