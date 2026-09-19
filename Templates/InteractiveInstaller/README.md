# Interactive installer capture

`Start-NSPInstallerCapture` is a technician-facing observation and design tool. It does not silently record keystrokes, values, or screenshots, and its JSON output is not executable endpoint code.

## Capture workflow

1. Run the command on a disposable test VM with the installer copied locally.
2. Advance to a meaningful installer screen and focus the relevant control.
3. Press **Ctrl+Shift+F12** while the installer still has focus. Repeat for each distinct screen or control.
4. Press **Ctrl+Shift+F11** to finish observation.
5. In the PowerShell review, classify each observation using the numbered choices and add expected visible text, timing, and notes.
6. Use a named runtime parameter for every secret or customer-specific value. The recorder stores the parameter name and sensitivity, never its value.
7. Review the JSON against `Schemas/InteractiveInstaller.schema.json` before implementing or packaging automation.

The hotkeys avoid the unreliable “press Enter and switch windows” timing used by the first prototype. The review questions include examples and defaults so the technician normally answers with a number, Y/N, or Enter.

## Model

Each step identifies a window, an optional focused control, an action, a timeout, and whether the screen may be absent. Values are either safe literals or runtime-parameter references. `WaitForWindow` and `WaitForWindowClose` provide explicit synchronization instead of fixed sleeps.

AutoIt is the leading execution engine for process/window validation and UI interaction. The first VM comparison uses interpreted `.au3` source and the same workflow compiled as an `.exe`; compiled delivery does not become the default until Defender and SmartScreen behavior is measured. AutoHotkey remains schema-compatible but is not planned unless AutoIt exposes a concrete gap. `AutoItSelector` is intentionally blank when Windows UI Automation cannot provide the final selector; the implementation technician can add a reviewed selector later.

See `Examples/InstallShield.MultiScreen.example.json` for a multi-screen sequence and `Examples/DocumentAssembly.Placeholder.example.json` for a sensitive runtime parameter and installer metadata placeholder.

## Safety rules

- Capture only in a disposable VM or other approved test environment.
- Never type a real password, license key, token, customer name, internal path, or tenant identifier into a literal field.
- Do not assume title text is unique; add visible window text and a control selector where possible.
- Treat captured output as a draft. Test both the expected path and optional/missing-screen paths before promotion.
- Do not commit installers or generated `.intunewin` files. Follow the repository artifact policy.
