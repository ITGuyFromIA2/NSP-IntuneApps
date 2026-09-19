# Interactive user prompt bridge

This reusable template adapts the proven SuperScript prompt model without taking a runtime dependency on `NSP-FGTIPSecTools`, `NSP.Bootstrap`, ServiceUI, or a gallery module.

A SYSTEM process enumerates active console and RDP sessions through the Windows Terminal Services API. It creates one transient scheduled task per fully qualified active user with an interactive-token principal. The WinForms child executes inside the user's session, and the first response wins. Every child task is then stopped and removed.

Important retained hardening:

- fully qualified `DOMAIN\\user` identity from WTS rather than ambiguous `query session` text;
- restoration of the qualified identity after `Export-ScheduledTask`, which otherwise may emit only the bare username;
- finite parent and child execution limits;
- no permanent polling process;
- response passed through a result file, not process exit-code guessing.

The generic version improves argument safety by reading title, message, and button labels from JSON rather than embedding operator text in a scheduled-task command line.
