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
    Assert-RepoPath "scripts\codex-verify.ps1"

    $markdownFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot "markdown_export") -File -Filter "*.md" -ErrorAction Stop
    if ($markdownFiles.Count -eq 0) {
        throw "markdown_export contains no Markdown files."
    }

    $merged = Get-Item -LiteralPath (Join-Path $repoRoot "merged_gdd.txt")
    if ($merged.Length -eq 0) {
        throw "merged_gdd.txt is empty."
    }

    Write-VerifyLine "checked Markdown files: $($markdownFiles.Count)"
    Write-VerifyLine "checked merged_gdd bytes: $($merged.Length)"
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
