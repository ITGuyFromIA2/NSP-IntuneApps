function Get-VCredCatalog {
    @(
        [pscustomobject]@{ Version='2005'; Architecture='x86'; Uri='https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE'; Arguments=@('/q','/r:n'); DisplayName='Microsoft Visual C++ 2005 Redistributable*' }
        [pscustomobject]@{ Version='2005'; Architecture='x64'; Uri='https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE'; Arguments=@('/q','/r:n'); DisplayName='Microsoft Visual C++ 2005 Redistributable (x64)*' }
        [pscustomobject]@{ Version='2008'; Architecture='x86'; Uri='https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe'; Arguments=@('/q','/norestart'); DisplayName='Microsoft Visual C++ 2008 Redistributable - x86*' }
        [pscustomobject]@{ Version='2008'; Architecture='x64'; Uri='https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe'; Arguments=@('/q','/norestart'); DisplayName='Microsoft Visual C++ 2008 Redistributable - x64*' }
        [pscustomobject]@{ Version='2012'; Architecture='x86'; Uri='https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe'; Arguments=@('/quiet','/norestart'); DisplayName='Microsoft Visual C++ 2012 Redistributable (x86)*' }
        [pscustomobject]@{ Version='2012'; Architecture='x64'; Uri='https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe'; Arguments=@('/quiet','/norestart'); DisplayName='Microsoft Visual C++ 2012 Redistributable (x64)*' }
        [pscustomobject]@{ Version='2013'; Architecture='x86'; Uri='https://aka.ms/highdpimfc2013x86enu'; Arguments=@('/quiet','/norestart'); DisplayName='Microsoft Visual C++ 2013 Redistributable (x86)*' }
        [pscustomobject]@{ Version='2013'; Architecture='x64'; Uri='https://aka.ms/highdpimfc2013x64enu'; Arguments=@('/quiet','/norestart'); DisplayName='Microsoft Visual C++ 2013 Redistributable (x64)*' }
        [pscustomobject]@{ Version='V14'; Architecture='x86'; Uri='https://aka.ms/vc14/vc_redist.x86.exe'; Arguments=@('/install','/quiet','/norestart'); DisplayName='Microsoft Visual C++ * Redistributable (x86)*' }
        [pscustomobject]@{ Version='V14'; Architecture='x64'; Uri='https://aka.ms/vc14/vc_redist.x64.exe'; Arguments=@('/install','/quiet','/norestart'); DisplayName='Microsoft Visual C++ * Redistributable (x64)*' }
    )
}

function Get-VCredSelection {
    param([Parameter(Mandatory)]$Configuration)
    $selection = @(Get-VCredCatalog | Where-Object { $_.Version -in $Configuration.Versions -and $_.Architecture -in $Configuration.Architectures })
    $expected = @($Configuration.Versions).Count * @($Configuration.Architectures).Count
    if ($selection.Count -ne $expected) { throw 'VCred configuration contains an unsupported version or architecture.' }
    $selection
}

function Get-VCredInstalledPrograms {
    $paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    @(Get-ItemProperty -Path $paths -ErrorAction SilentlyContinue | Where-Object DisplayName)
}

function Test-VCredEntry {
    param([Parameter(Mandatory)]$Entry, [object[]]$InstalledPrograms = (Get-VCredInstalledPrograms))
    if ($Entry.Version -eq 'V14') {
        $runtimeKey = "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\$($Entry.Architecture)"
        $runtime = Get-ItemProperty -LiteralPath $runtimeKey -ErrorAction SilentlyContinue
        return $null -ne $runtime -and [int]$runtime.Installed -eq 1
    }
    @($InstalledPrograms | Where-Object DisplayName -like $Entry.DisplayName).Count -gt 0
}

function Install-VCredSelection {
    param([Parameter(Mandatory)]$Configuration)
    $cache = Join-Path $env:ProgramData 'NSP\Cache\VCred'
    New-Item -ItemType Directory -Path $cache -Force | Out-Null
    $installed = Get-VCredInstalledPrograms
    $rebootRequired = $false
    foreach ($entry in Get-VCredSelection -Configuration $Configuration) {
        if (Test-VCredEntry -Entry $entry -InstalledPrograms $installed) { continue }
        $file = Join-Path $cache ("{0}-{1}.exe" -f $entry.Version, $entry.Architecture)
        try {
            Invoke-WebRequest -UseBasicParsing -Uri $entry.Uri -OutFile $file -ErrorAction Stop
            $process = Start-Process -FilePath $file -ArgumentList $entry.Arguments -Wait -PassThru
            if ($process.ExitCode -eq 3010) { $rebootRequired = $true }
            elseif ($process.ExitCode -notin @(0, 1638)) { throw "Installer returned exit code $($process.ExitCode)." }
            if (-not (Test-VCredEntry -Entry $entry -InstalledPrograms (Get-VCredInstalledPrograms))) {
                throw "The installer completed but $($entry.Version) $($entry.Architecture) was not detected."
            }
        } finally {
            Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
        }
    }
    if ($rebootRequired) { exit 3010 }
}

function Uninstall-VCredSelection {
    param([Parameter(Mandatory)]$Configuration)
    $programs = Get-VCredInstalledPrograms
    foreach ($entry in Get-VCredSelection -Configuration $Configuration) {
        $matches = if ($entry.Version -eq 'V14') {
            @($programs | Where-Object { $_.DisplayName -like $entry.DisplayName -and $_.DisplayName -match '2015|2017|2019|2022|2026' })
        } else {
            @($programs | Where-Object DisplayName -like $entry.DisplayName)
        }
        foreach ($app in $matches) {
            if ($app.WindowsInstaller -eq 1 -and $app.PSChildName -match '^\{[0-9A-F-]+\}$') {
                $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList @('/x', $app.PSChildName, '/quiet', '/norestart') -Wait -PassThru
            } else {
                $command = if ($app.QuietUninstallString) { $app.QuietUninstallString } else { $app.UninstallString }
                if (-not $command) { Write-Warning "No uninstall command was registered for $($app.DisplayName)."; continue }
                $process = Start-Process -FilePath $env:ComSpec -ArgumentList @('/d','/s','/c',"$command /quiet /norestart") -Wait -PassThru
            }
            if ($process.ExitCode -notin @(0, 1605, 1614, 3010)) { Write-Warning "Uninstall returned $($process.ExitCode) for $($app.DisplayName)." }
        }
    }
}
