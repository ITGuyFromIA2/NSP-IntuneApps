$ErrorActionPreference = 'Stop'
$uninstallRoots = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$applications = @(Get-ItemProperty -Path $uninstallRoots -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like '*Parallels*Client*' -and $_.PSChildName -match '^\{[A-Fa-f0-9-]+\}$' })

foreach ($application in $applications) {
    $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList "/qn /norestart /x $($application.PSChildName)" -Wait -PassThru
    if ($process.ExitCode -notin @(0, 1605, 1614, 3010)) {
        throw "Parallels RAS Client uninstall failed with exit code $($process.ExitCode)."
    }
}
