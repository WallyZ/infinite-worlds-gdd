[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$cacheRoot = Join-Path $repoRoot ".codex-cache"
$logsRoot = Join-Path $cacheRoot "logs"
$tmpRoot = Join-Path $cacheRoot "tmp"
$runId = Get-Date -Format "yyyyMMdd-HHmmss"
$runTemp = Join-Path $tmpRoot $runId
$logPath = Join-Path $logsRoot "codex-verify-$runId.log"

New-Item -ItemType Directory -Force -Path $logsRoot | Out-String | Write-Verbose
New-Item -ItemType Directory -Force -Path $runTemp | Out-String | Write-Verbose

$oldTemp = $env:TEMP
$oldTmp = $env:TMP
$env:TEMP = $runTemp
$env:TMP = $runTemp

function Write-VerifyLine {
    param([AllowEmptyString()][string]$Message)
    $Message | Tee-Object -FilePath $logPath -Append
}

function Assert-RepoPath {
    param([Parameter(Mandatory)][string]$RelativePath)

    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing required path: $RelativePath"
    }
}

try {
    Write-VerifyLine "codex-verify started"
    Write-VerifyLine "repo: $repoRoot"
    Write-VerifyLine "log: $logPath"
    Write-VerifyLine "temp: $runTemp"

    Assert-RepoPath "README.md"
    Assert-RepoPath "AGENTS.md"
    Assert-RepoPath ".editorconfig"
    Assert-RepoPath ".gitignore"
    Assert-RepoPath "docs\game_design_document"
    Assert-RepoPath "docs\CODEX_GDD_NAVIGATION.md"
    Assert-RepoPath "docs\GDD_ORGANIZATION.md"
    Assert-RepoPath "docs\GDD_RETENTION_REVIEW.md"
    Assert-RepoPath "docs\GDD_STANDARDS.md"
    Assert-RepoPath "docs\GDD_STRUCTURE_REVIEW.md"
    Assert-RepoPath "docs\GDD_TARGET_STRUCTURE.md"
    Assert-RepoPath "docs\index\GDD_SOURCE_INDEX.md"
    Assert-RepoPath "docs\index\GDD_CONTENT_AUDIT.md"
    Assert-RepoPath "docs\index\GDD_DOCUMENT_FIT_AUDIT.md"
    Assert-RepoPath "docs\index\gdd_source_index.json"
    Assert-RepoPath "docs\index\gdd_content_audit.json"
    Assert-RepoPath "docs\index\gdd_document_fit_audit.json"
    Assert-RepoPath "docs\index\gdd_filename_migration.json"
    Assert-RepoPath "scripts\build-gdd-index.ps1"
    Assert-RepoPath "scripts\build-gdd-content-audit.ps1"
    Assert-RepoPath "scripts\build-gdd-document-fit-audit.ps1"
    Assert-RepoPath "scripts\markdown_format_guard.py"
    Assert-RepoPath "scripts\codex-verify.ps1"

    $markdownFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot "docs\game_design_document") -File -Filter "*.md" -ErrorAction Stop
    if ($markdownFiles.Count -eq 0) {
        throw "docs\game_design_document contains no Markdown files."
    }

    $badNames = @($markdownFiles | Where-Object { $_.Name -notmatch "^(?:\d{2}_){6}\d{2}__[a-z0-9]+(?:-[a-z0-9]+)*\.md$" })
    if ($badNames.Count -gt 0) {
        throw "GDD source filenames do not match the sortable naming standard: $($badNames[0].Name)"
    }

    $legacyMergedPath = Join-Path $repoRoot "merged_gdd.txt"
    if (Test-Path -LiteralPath $legacyMergedPath) {
        throw "merged_gdd.txt should not be present. Use docs\index\GDD_SOURCE_INDEX.md for broad keyword search."
    }

    Write-VerifyLine "markdown format guard started"
    $markdownGuard = Join-Path $repoRoot "scripts\markdown_format_guard.py"
    $markdownGuardTargets = @(
        (Join-Path $repoRoot "README.md"),
        (Join-Path $repoRoot "AGENTS.md"),
        (Join-Path $repoRoot "docs")
    )
    $markdownOutput = & python $markdownGuard --check @markdownGuardTargets 2>&1
    $markdownExit = $LASTEXITCODE
    foreach ($line in $markdownOutput) {
        Write-VerifyLine "$line"
    }
    if ($markdownExit -ne 0) {
        throw "Markdown format guard failed with exit code $markdownExit. Run python scripts\markdown_format_guard.py --fix README.md AGENTS.md docs."
    }

    Write-VerifyLine "gdd index freshness check started"
    $indexScript = Join-Path $repoRoot "scripts\build-gdd-index.ps1"
    $indexOutput = & $indexScript -RepoRoot $repoRoot -Check 2>&1
    $indexExit = $LASTEXITCODE
    foreach ($line in $indexOutput) {
        Write-VerifyLine "$line"
    }
    if ($indexExit -ne 0) {
        throw "GDD index freshness check failed with exit code $indexExit."
    }

    $sourceIndex = Get-Content -LiteralPath (Join-Path $repoRoot "docs\index\GDD_SOURCE_INDEX.md") -Raw
    if ($sourceIndex -notmatch "## Full-Text Search Snapshot") {
        throw "GDD_SOURCE_INDEX.md is missing the full-text search snapshot."
    }
    if ($sourceIndex -notmatch "GDD_SOURCE_TEXT_BEGIN") {
        throw "GDD_SOURCE_INDEX.md is missing source text blocks."
    }

    Write-VerifyLine "gdd content audit freshness check started"
    $auditScript = Join-Path $repoRoot "scripts\build-gdd-content-audit.ps1"
    $auditOutput = & $auditScript -RepoRoot $repoRoot -Check 2>&1
    $auditExit = $LASTEXITCODE
    foreach ($line in $auditOutput) {
        Write-VerifyLine "$line"
    }
    if ($auditExit -ne 0) {
        throw "GDD content audit freshness check failed with exit code $auditExit."
    }

    Write-VerifyLine "gdd document fit audit freshness check started"
    $documentFitAuditScript = Join-Path $repoRoot "scripts\build-gdd-document-fit-audit.ps1"
    $documentFitAuditOutput = & $documentFitAuditScript -RepoRoot $repoRoot -Check 2>&1
    $documentFitAuditExit = $LASTEXITCODE
    foreach ($line in $documentFitAuditOutput) {
        Write-VerifyLine "$line"
    }
    if ($documentFitAuditExit -ne 0) {
        throw "GDD document fit audit freshness check failed with exit code $documentFitAuditExit."
    }

    Write-VerifyLine "checked Markdown files: $($markdownFiles.Count)"
    Write-VerifyLine "checked Markdown format guard"
    Write-VerifyLine "checked GDD filename standard"
    Write-VerifyLine "checked GDD source index full-text snapshot"
    Write-VerifyLine "checked GDD index freshness"
    Write-VerifyLine "checked GDD content audit freshness"
    Write-VerifyLine "checked GDD document fit audit freshness"
    Write-VerifyLine "codex-verify passed"
    exit 0
}
catch {
    Write-VerifyLine "codex-verify failed"
    Write-VerifyLine $_.Exception.Message
    Write-VerifyLine "log: $logPath"
    exit 1
}
finally {
    $env:TEMP = $oldTemp
    $env:TMP = $oldTmp

    if (Test-Path -LiteralPath $runTemp) {
        Remove-Item -LiteralPath $runTemp -Recurse -Force
    }
}
