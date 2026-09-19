# RDP and RemoteApp template

`New-NSPRdpApp -Interactive` generates either a full desktop connection or a RemoteApp connection. The wizard asks only questions relevant to the selected mode, uses numbered choices, accepts comma-separated redirection choices, and shows an example before free-text inputs.

Generated client connection details default to `Config\Local\GeneratedApps`, which is ignored by Git. The upstream example uses `example.invalid` and demonstrates structure only.
