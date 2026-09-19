function Get-VCredCatalog {
    @(
        [pscustomobject]@{ Version='2005'; Architecture='x86'; DisplayName='Microsoft Visual C++ 2005 Redistributable*' }
        [pscustomobject]@{ Version='2005'; Architecture='x64'; DisplayName='Microsoft Visual C++ 2005 Redistributable (x64)*' }
        [pscustomobject]@{ Version='2008'; Architecture='x86'; DisplayName='Microsoft Visual C++ 2008 Redistributable - x86*' }
        [pscustomobject]@{ Version='2008'; Architecture='x64'; DisplayName='Microsoft Visual C++ 2008 Redistributable - x64*' }
        [pscustomobject]@{ Version='2012'; Architecture='x86'; DisplayName='Microsoft Visual C++ 2012 Redistributable (x86)*' }
        [pscustomobject]@{ Version='2012'; Architecture='x64'; DisplayName='Microsoft Visual C++ 2012 Redistributable (x64)*' }
        [pscustomobject]@{ Version='2013'; Architecture='x86'; DisplayName='Microsoft Visual C++ 2013 Redistributable (x86)*' }
        [pscustomobject]@{ Version='2013'; Architecture='x64'; DisplayName='Microsoft Visual C++ 2013 Redistributable (x64)*' }
        [pscustomobject]@{ Version='V14'; Architecture='x86'; DisplayName='Microsoft Visual C++ * Redistributable (x86)*' }
        [pscustomobject]@{ Version='V14'; Architecture='x64'; DisplayName='Microsoft Visual C++ * Redistributable (x64)*' }
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
    $paths = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
    @(Get-ItemProperty -Path $paths -ErrorAction SilentlyContinue | Where-Object DisplayName)
}

function Test-VCredEntry {
    param([Parameter(Mandatory)]$Entry, [object[]]$InstalledPrograms = (Get-VCredInstalledPrograms))
    if ($Entry.Version -eq 'V14') {
        $runtime = Get-ItemProperty -LiteralPath "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\$($Entry.Architecture)" -ErrorAction SilentlyContinue
        return $null -ne $runtime -and [int]$runtime.Installed -eq 1
    }
    @($InstalledPrograms | Where-Object DisplayName -like $Entry.DisplayName).Count -gt 0
}
