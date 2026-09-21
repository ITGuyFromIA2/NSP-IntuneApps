function Test-NSPIntuneAppsPreflight {
    <#
    .SYNOPSIS
        Performs read-only repository, syntax, module, and certificate checks.
    .EXAMPLE
        Test-NSPIntuneAppsPreflight -RepoRoot C:\GitRepos\NSP-IntuneApps
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot
    )

    $results = [System.Collections.Generic.List[object]]::new()
    $add = {
        param($Area, $Name, $Status, $Detail)
        $results.Add([pscustomobject]@{ Area=$Area; Name=$Name; Status=$Status; Detail=$Detail })
    }

    & $add 'Environment' 'PowerShell' $(if ($PSVersionTable.PSVersion.Major -ge 5) { 'Pass' } else { 'Blocked' }) $PSVersionTable.PSVersion.ToString()
    & $add 'Environment' 'NSP.Bootstrap' $(if (Get-Module -ListAvailable NSP.Bootstrap) { 'Pass' } else { 'Warning' }) 'Build/operator dependency'
    & $add 'Environment' 'IntuneWin32App' $(if (Get-Module -ListAvailable IntuneWin32App) { 'Pass' } else { 'Warning' }) 'Required only for package/upload operations'
    & $add 'Environment' 'GitHub CLI' $(if (Get-Command gh -ErrorAction SilentlyContinue) { 'Pass' } else { 'Warning' }) 'Required only for private Release asset download/upload operations'

    $syntaxErrors = [System.Collections.Generic.List[object]]::new()
    foreach ($file in Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter '*.ps1') {
        if ($file.FullName -like '*\.git\*') { continue }
        $tokens = $null
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
        foreach ($error in $errors) {
            $syntaxErrors.Add([pscustomobject]@{ File=$file.FullName; Line=$error.Extent.StartLineNumber; Message=$error.Message })
        }
    }
    & $add 'Repository' 'PowerShell syntax' $(if ($syntaxErrors.Count -eq 0) { 'Pass' } else { 'Blocked' }) "$($syntaxErrors.Count) parser error(s)"

    $legacyUploader = Join-Path $RepoRoot 'Apps\Create_UploadToIntune_SplitScript.ps1'
    $legacyUploaderDisabled = (Test-Path -LiteralPath $legacyUploader) -and ((Get-Content -LiteralPath $legacyUploader -TotalCount 3) -join "`n") -match 'intentionally disabled'
    & $add 'Safety' 'Gen1 delete/recreate uploader' $(if ($legacyUploaderDisabled) { 'Pass' } else { 'Blocked' }) $(if ($legacyUploaderDisabled) { 'Disabled pending update-in-place/supersedence executor.' } else { 'Legacy destructive workflow is not guarded.' })

    $intuneWinFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'Apps') -Recurse -File -Filter '*.intunewin')
    & $add 'Repository' 'Generated Intune packages' $(if ($intuneWinFiles.Count -eq 0) { 'Pass' } else { 'Blocked' }) "$($intuneWinFiles.Count) .intunewin file(s) present"

    $repositoryFiles = $null
    $gitDirectory = Join-Path $RepoRoot '.git'
    if ((Get-Command git -ErrorAction SilentlyContinue) -and (Test-Path -LiteralPath $gitDirectory)) {
        $gitPaths = @(& git -C $RepoRoot ls-files --cached --others --exclude-standard 2>$null)
        if ($LASTEXITCODE -eq 0) {
            $repositoryFiles = @($gitPaths |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
                ForEach-Object { Get-Item -LiteralPath (Join-Path $RepoRoot $_) -ErrorAction SilentlyContinue } |
                Where-Object { $_ -and -not $_.PSIsContainer })
        }
    }
    if ($null -eq $repositoryFiles) {
        # git is unavailable or failed: a raw filesystem scan would include ignored local
        # evidence (Config/Local, extracted vendor archives) and misreport it as committed.
        # Report degraded confidence instead of guessing.
        $privateKeyArtifacts = @()
        $binaryPayloads = @()
        $gitUnavailableDetail = 'git was not found on PATH (or `git ls-files` failed), so repository-tracked-file safety checks could not be verified and were skipped. Install Git or add it to PATH to run this check.'
        & $add 'Safety' 'Private-key artifacts' 'Warning' $gitUnavailableDetail
        & $add 'Repository' 'Committed binary payloads' 'Warning' $gitUnavailableDetail
    } else {
        $privateKeyArtifacts = @($repositoryFiles | Where-Object { $_.Extension -in @('.pfx','.p12','.pem','.key') })
        & $add 'Safety' 'Private-key artifacts' $(if ($privateKeyArtifacts.Count -eq 0) { 'Pass' } else { 'Blocked' }) $(if ($privateKeyArtifacts.Count -eq 0) { 'No PFX, PKCS#12, PEM, or key files are present in repository source' } else { "$($privateKeyArtifacts.Count) private-key artifact(s) present" })

        $binaryPayloads = @($repositoryFiles | Where-Object { $_.Extension -in @('.exe','.msi','.dll') })
        & $add 'Repository' 'Committed binary payloads' $(if ($binaryPayloads.Count -eq 0) { 'Pass' } else { 'Blocked' }) $(if ($binaryPayloads.Count -eq 0) { 'No executable vendor or build payloads are committed' } else { "$($binaryPayloads.Count) executable payload(s) present" })
    }

    $downstreamPattern = 'simpco|greenberg|chesterman|klass|scigrain|sscha|hnrco|\bHnR\b|gm\.nsp|gmrds|accubuild|caasiouxland|sschousingagency'
    $downstreamFiles = @(Get-ChildItem -LiteralPath $RepoRoot -Recurse -File |
        Where-Object { $_.FullName -notlike '*\.git\*' -and $_.Name -notin @('Test-NSPIntuneAppsPreflight.ps1','Module.Tests.ps1') })
    $downstreamContentMarkers = @($downstreamFiles |
        Where-Object { $_.Extension -in @('.ps1','.psd1','.json','.md','.txt','.reg','.xml','.ini','.cmd','.bat') } |
        Select-String -Pattern $downstreamPattern)
    $downstreamPathMarkers = @($downstreamFiles | Where-Object FullName -Match $downstreamPattern)
    $downstreamMarkers = @($downstreamContentMarkers) + @($downstreamPathMarkers)
    & $add 'Repository' 'Known downstream client markers' $(if ($downstreamMarkers.Count -eq 0) { 'Pass' } else { 'Blocked' }) "$($downstreamMarkers.Count) match(es)"

    $embeddedSecrets = [System.Collections.Generic.List[object]]::new()
    $secretNamePattern = '(?i)(password|passwd|passphrase|secret|licensekey|api[_-]?key|access[_-]?token|client[_-]?secret)'
    $sourceRoots = @('Apps','Templates','Public','Private') | ForEach-Object { Join-Path $RepoRoot $_ } | Where-Object { Test-Path -LiteralPath $_ }
    foreach ($file in Get-ChildItem -LiteralPath $sourceRoots -Recurse -File -Filter '*.ps1') {
        if ($file.Name -eq 'Test-NSPIntuneAppsPreflight.ps1') { continue }
        $tokens = $null; $parseErrors = $null
        $ast = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
        foreach ($assignment in $ast.FindAll({
            param($node)
            $node -is [Management.Automation.Language.AssignmentStatementAst] -and
            $node.Left.Extent.Text -match $secretNamePattern -and
            $node.Right -is [Management.Automation.Language.StringConstantExpressionAst] -and
            $node.Right.Value.Length -ge 6 -and
            $node.Right.Value -notmatch '(?i)^(placeholder|example|changeme|runtime|from[-_ ]secret|<.+>|\$\(.+\))$'
        }, $true)) {
            $embeddedSecrets.Add([pscustomobject]@{ File=$file.FullName; Line=$assignment.Extent.StartLineNumber; Kind='Literal secret-like assignment' })
        }
        foreach ($match in Select-String -LiteralPath $file.FullName -Pattern '(?i)net\s+use\b[^\r\n]*\/user:\S+\s+[^\s"'']{6,}') {
            $embeddedSecrets.Add([pscustomobject]@{ File=$file.FullName; Line=$match.LineNumber; Kind='Credential-bearing net use command' })
        }
    }
    & $add 'Safety' 'Embedded secret-like literals' $(if ($embeddedSecrets.Count -eq 0) { 'Pass' } else { 'Blocked' }) $(if ($embeddedSecrets.Count -eq 0) { 'No likely passwords, license keys, API keys, tokens, or credential-bearing net use commands found' } else { "$($embeddedSecrets.Count) likely secret-bearing source line(s) found" })

    $operationalIdentifiers = [System.Collections.Generic.List[object]]::new()
    foreach ($file in Get-ChildItem -LiteralPath $sourceRoots -Recurse -File -Filter '*.ps1') {
        if ($file.Name -eq 'Test-NSPIntuneAppsPreflight.ps1') { continue }
        foreach ($match in Select-String -LiteralPath $file.FullName -Pattern '(?i)\bGZ_PACKAGE_ID\s*=\s*(?<Value>[A-Za-z0-9+/_=-]{24,})' -AllMatches) {
            foreach ($regexMatch in $match.Matches) {
                $value = $regexMatch.Groups['Value'].Value
                if ($value -notmatch '(?i)(REPLACE|PLACEHOLDER|EXAMPLE|RUNTIME)') {
                    $operationalIdentifiers.Add([pscustomobject]@{ File=$file.FullName; Line=$match.LineNumber; Kind='Bitdefender GravityZone package ID' })
                }
            }
        }
    }
    & $add 'Safety' 'Embedded operational deployment identifiers' $(if ($operationalIdentifiers.Count -eq 0) { 'Pass' } else { 'Blocked' }) $(if ($operationalIdentifiers.Count -eq 0) { 'No literal tenant enrollment or deployment identifiers found' } else { "$($operationalIdentifiers.Count) operational identifier(s) found" })

    $catalog = @(Get-NSPIntuneAppCatalog -RepoRoot $RepoRoot)
    & $add 'Catalog' 'Deployable entries' 'Info' "$(@($catalog | Where-Object Classification -eq 'Deployable').Count)"
    & $add 'Catalog' 'Legacy entries' $(if (@($catalog | Where-Object Classification -eq 'Legacy').Count -gt 0) { 'Warning' } else { 'Pass' }) "$(@($catalog | Where-Object Classification -eq 'Legacy').Count)"
    & $add 'Catalog' 'Needs configuration' 'Info' "$(@($catalog | Where-Object Classification -eq 'RequiresConfiguration').Count)"
    & $add 'Catalog' 'Requires source repair' $(if (@($catalog | Where-Object Classification -eq 'RequiresRepair').Count -gt 0) { 'Warning' } else { 'Pass' }) "$(@($catalog | Where-Object Classification -eq 'RequiresRepair').Count)"
    & $add 'Catalog' 'Blocked entries' $(if (@($catalog | Where-Object Classification -eq 'Blocked').Count -gt 0) { 'Blocked' } else { 'Pass' }) "$(@($catalog | Where-Object Classification -eq 'Blocked').Count)"
    $duplicateIdentities = @($catalog | Where-Object Classification -eq 'Deployable' | Group-Object DisplayName,Publisher | Where-Object Count -gt 1)
    & $add 'Catalog' 'Duplicate deployable identities' $(if ($duplicateIdentities.Count -gt 0) { 'Blocked' } else { 'Pass' }) $(if ($duplicateIdentities.Count -gt 0) { ($duplicateIdentities.Name -join '; ') } else { '0 duplicate display-name/publisher pairs' })
    $missingDeployableIdentity = @($catalog | Where-Object {
        $_.Classification -eq 'Deployable' -and
        ([string]::IsNullOrWhiteSpace([string]$_.DisplayName) -or [string]::IsNullOrWhiteSpace([string]$_.Publisher))
    })
    & $add 'Catalog' 'Literal deployable identities' $(if ($missingDeployableIdentity.Count -gt 0) { 'Blocked' } else { 'Pass' }) $(if ($missingDeployableIdentity.Count -gt 0) { ($missingDeployableIdentity.Name -join ', ') } else { 'Every deployable app has a literal display name and publisher' })
    $mutatingDeployableSettings = [System.Collections.Generic.List[object]]::new()
    $fileMutationCommands = @('Set-Content','Add-Content','Out-File','Copy-Item','Move-Item','Remove-Item','Rename-Item','Clear-Content')
    foreach ($entry in $catalog | Where-Object { $_.Classification -eq 'Deployable' -and $_.SettingsPath }) {
        $tokens = $null
        $parseErrors = $null
        $settingsAst = [Management.Automation.Language.Parser]::ParseFile($entry.SettingsPath, [ref]$tokens, [ref]$parseErrors)
        foreach ($command in $settingsAst.FindAll({
            param($node)
            $node -is [Management.Automation.Language.CommandAst] -and
            $node.GetCommandName() -in $fileMutationCommands
        }, $true)) {
            $mutatingDeployableSettings.Add([pscustomobject]@{ App=$entry.Name; Command=$command.GetCommandName(); Line=$command.Extent.StartLineNumber })
        }
    }
    & $add 'Safety' 'Deployable settings are declarative' $(if ($mutatingDeployableSettings.Count -gt 0) { 'Blocked' } else { 'Pass' }) $(if ($mutatingDeployableSettings.Count -gt 0) { "$($mutatingDeployableSettings.Count) file-mutation command(s) found" } else { 'No deployable settings file mutates package source' })
    & $add 'Catalog' 'Retired duplicate entries' $(if (@($catalog | Where-Object Classification -eq 'RetiredDuplicate').Count -gt 0) { 'Info' } else { 'Pass' }) "$(@($catalog | Where-Object Classification -eq 'RetiredDuplicate').Count)"
    & $add 'Catalog' 'Retired template entries' $(if (@($catalog | Where-Object Classification -eq 'RetiredTemplate').Count -gt 0) { 'Info' } else { 'Pass' }) "$(@($catalog | Where-Object Classification -eq 'RetiredTemplate').Count)"
    $embeddedAssignments = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $catalog | Where-Object SettingsPath) {
        $tokens = $null
        $parseErrors = $null
        $settingsAst = [Management.Automation.Language.Parser]::ParseFile($entry.SettingsPath, [ref]$tokens, [ref]$parseErrors)
        foreach ($assignment in $settingsAst.FindAll({
            param($node)
            $node -is [Management.Automation.Language.AssignmentStatementAst] -and
            $node.Operator -eq 'PlusEquals' -and
            $node.Left.Extent.Text -match '^\$VariableConfig\.AssignmentColl$'
        }, $true)) {
            $embeddedAssignments.Add([pscustomobject]@{ App=$entry.Name; Line=$assignment.Extent.StartLineNumber })
        }
    }
    & $add 'Safety' 'Embedded app assignments' $(if ($embeddedAssignments.Count -gt 0) { 'Blocked' } else { 'Pass' }) $(if ($embeddedAssignments.Count -gt 0) { "$($embeddedAssignments.Count) assignment(s) remain in app settings" } else { 'Targeting is supplied only by deployment plans' })

    try {
        $config = Get-NSPCodeSigningConfiguration -RepoRoot $RepoRoot
        if ([string]::IsNullOrWhiteSpace([string]$config.Current.Thumbprint)) {
            & $add 'Certificate' 'Active generation' 'Warning' 'No active generation configured yet.'
        } else {
            $cerPath = Join-Path $config.CodeSigningDir ([string]$config.Current.PublicCerFile)
            if (Test-Path -LiteralPath $cerPath) {
                $publicCert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($cerPath)
                $matches = $publicCert.Thumbprint -eq ([string]$config.Current.Thumbprint).Replace(' ', '')
                & $add 'Certificate' 'Public certificate' $(if ($matches) { 'Pass' } else { 'Blocked' }) "$($publicCert.Thumbprint); expires $($publicCert.NotAfter.ToString('yyyy-MM-dd'))"
            } else {
                & $add 'Certificate' 'Public certificate' 'Blocked' "Missing: $cerPath"
            }
        }
    } catch {
        & $add 'Certificate' 'Configuration' 'Blocked' $_.Exception.Message
    }

    [pscustomobject]@{
        Passed       = @($results | Where-Object Status -eq 'Blocked').Count -eq 0
        Results      = @($results)
        SyntaxErrors = @($syntaxErrors)
        DownstreamMarkers = @($downstreamMarkers)
        EmbeddedSecrets = @($embeddedSecrets)
        OperationalIdentifiers = @($operationalIdentifiers)
        PrivateKeyArtifacts = @($privateKeyArtifacts)
        BinaryPayloads = @($binaryPayloads)
        EmbeddedAssignments = @($embeddedAssignments)
        MissingDeployableIdentity = @($missingDeployableIdentity)
        MutatingDeployableSettings = @($mutatingDeployableSettings)
        Catalog      = $catalog
    }
}
