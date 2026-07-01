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
    param([Parameter(Mandatory)][string]$Message)
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
    Assert-RepoPath ".gitignore"
    Assert-RepoPath "markdown_export"
    Assert-RepoPath "Notion_backup"
    Assert-RepoPath "merged_gdd.txt"
    Assert-RepoPath "docs\CODEX_GDD_NAVIGATION.md"
    Assert-RepoPath "docs\GDD_ORGANIZATION.md"
    Assert-RepoPath "docs\GDD_RETENTION_REVIEW.md"
    Assert-RepoPath "docs\index\GDD_SOURCE_INDEX.md"
    Assert-RepoPath "docs\index\gdd_source_index.json"
    Assert-RepoPath "scripts\build-gdd-index.ps1"
    Assert-RepoPath "scripts\codex-verify.ps1"

    $markdownFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot "markdown_export") -File -Filter "*.md" -ErrorAction Stop
    if ($markdownFiles.Count -eq 0) {
        throw "markdown_export contains no Markdown files."
    }

    $merged = Get-Item -LiteralPath (Join-Path $repoRoot "merged_gdd.txt")
    if ($merged.Length -eq 0) {
        throw "merged_gdd.txt is empty."
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

    Write-VerifyLine "checked Markdown files: $($markdownFiles.Count)"
    Write-VerifyLine "checked merged_gdd bytes: $($merged.Length)"
    Write-VerifyLine "checked GDD index freshness"
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
