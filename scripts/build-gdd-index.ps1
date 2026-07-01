[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path,
    [switch]$Check
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$sourceRootRelative = "docs\game_design_document"
$sourceRootPortable = "docs/game_design_document"
$sourceRoot = Join-Path $repoRoot $sourceRootRelative
$indexRoot = Join-Path $repoRoot "docs\index"
$markdownIndexPath = Join-Path $indexRoot "GDD_SOURCE_INDEX.md"
$jsonIndexPath = Join-Path $indexRoot "gdd_source_index.json"
$migrationMapPath = Join-Path $indexRoot "gdd_filename_migration.json"

function Get-PortablePath {
    param([Parameter(Mandatory)][string]$Path)

    return ($Path -replace "\\", "/")
}

function ConvertTo-MarkdownTableCell {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) {
        return ""
    }

    return (($Value -replace "\|", "\|") -replace "\r?\n", " ").Trim()
}

function ConvertTo-MarkdownLinkLabel {
    param([Parameter(Mandatory)][string]$Value)

    return ((ConvertTo-MarkdownTableCell -Value $Value) -replace "\[", "\[" -replace "\]", "\]")
}

function ConvertTo-RelativeMarkdownLink {
    param([Parameter(Mandatory)][string]$FileName)

    return "../game_design_document/$([uri]::EscapeDataString($FileName))"
}

function Get-SectionFromFileName {
    param([Parameter(Mandatory)][string]$FileName)

    if ($FileName -match "^((?:\d{2}_){6}\d{2})__") {
        $parts = @($Matches[1] -split "_" | ForEach-Object { [int]$_ })
        while ($parts.Count -gt 1 -and $parts[$parts.Count - 1] -eq 0) {
            $parts = @($parts[0..($parts.Count - 2)])
        }

        return ($parts -join ".")
    }

    throw "File does not follow GDD filename standard: $FileName"
}

function Get-SortKey {
    param([Parameter(Mandatory)][string]$Section)

    return ((@($Section -split "\.") | ForEach-Object { "{0:D4}" -f [int]$_ }) -join ".")
}

function Get-HeadingInfo {
    param(
        [Parameter(Mandatory)][string]$Raw,
        [Parameter(Mandatory)][string]$FileName
    )

    $firstHeading = ""
    foreach ($line in ($Raw -split "\r?\n")) {
        if ($line -match "^#\s+(.+)$") {
            $firstHeading = $Matches[1].Trim()
            break
        }
    }

    if ([string]::IsNullOrWhiteSpace($firstHeading)) {
        throw "Missing H1 heading in $FileName"
    }

    if ($firstHeading -match "^(\d+(?:(?:\.|\s+)\d+)*)(?:[\\.:])?\s+(.+)$") {
        return [pscustomobject]@{
            Section = ($Matches[1] -replace "\s+", ".")
            Title = $Matches[2].Trim()
            FirstHeading = $firstHeading
        }
    }

    return [pscustomobject]@{
        Section = Get-SectionFromFileName -FileName $FileName
        Title = $firstHeading.Trim()
        FirstHeading = $firstHeading
    }
}

function Get-MigrationByNewFile {
    $lookup = @{}
    if (-not (Test-Path -LiteralPath $migrationMapPath)) {
        return $lookup
    }

    $items = @(Get-Content -LiteralPath $migrationMapPath -Raw | ConvertFrom-Json)
    foreach ($item in $items) {
        if (($item.PSObject.Properties.Name -contains "status") -and ($item.status -ne "active")) {
            continue
        }
        $lookup[$item.new_file] = $item
    }

    return $lookup
}

function New-GddIndex {
    if (-not (Test-Path -LiteralPath $sourceRoot)) {
        throw "Missing GDD source root: $sourceRoot"
    }

    $markdownFiles = @(Get-ChildItem -LiteralPath $sourceRoot -File -Filter "*.md" | Sort-Object Name)
    if ($markdownFiles.Count -eq 0) {
        throw "No Markdown files found in $sourceRoot"
    }

    $migrationByNewFile = Get-MigrationByNewFile
    $records = @()
    $rawByFile = @{}
    foreach ($file in $markdownFiles) {
        $raw = Get-Content -LiteralPath $file.FullName -Raw
        $heading = Get-HeadingInfo -Raw $raw -FileName $file.Name
        $fileSection = Get-SectionFromFileName -FileName $file.Name
        if ($heading.Section -ne $fileSection) {
            throw "Heading section '$($heading.Section)' does not match filename section '$fileSection' in $($file.Name)"
        }

        $parts = @($fileSection -split "\.")
        $relativePath = Get-PortablePath -Path ($sourceRootRelative + "\" + $file.Name)
        $migration = $migrationByNewFile[$relativePath]
        $rawByFile[$relativePath] = $raw

        $records += [pscustomobject]@{
            section = $fileSection
            sort_key = Get-SortKey -Section $fileSection
            top_section = [int]$parts[0]
            depth = $parts.Count
            title = $heading.Title
            first_heading = $heading.FirstHeading
            file = $relativePath
            source_id = if ($migration) { $migration.source_id } else { "" }
            original_file = if ($migration) { $migration.old_file } else { "" }
            bytes = $file.Length
            lines = (($raw -split "\r?\n") | Measure-Object).Count
            words = ([regex]::Matches($raw, "\S+")).Count
        }
    }

    $topSectionRecords = @($records | Where-Object { $_.depth -eq 1 } | Sort-Object top_section)
    $sectionSummaries = @()
    foreach ($top in ($records | Group-Object top_section | Sort-Object { [int]$_.Name })) {
        $topNumber = [int]$top.Name
        $topRecord = @($topSectionRecords | Where-Object { $_.top_section -eq $topNumber } | Select-Object -First 1)
        $label = if ($topRecord) { $topRecord.title } else { "Unsectioned" }
        $sectionSummaries += [pscustomobject]@{
            section = $topNumber
            title = $label
            files = $top.Count
            bytes = (($top.Group | Measure-Object -Property bytes -Sum).Sum)
            words = (($top.Group | Measure-Object -Property words -Sum).Sum)
        }
    }

    $md = [System.Collections.Generic.List[string]]::new()
    $md.Add("# GDD Source Index")
    $md.Add("")
    $md.Add('Generated by `scripts/build-gdd-index.ps1`. Regenerate after GDD source changes.')
    $md.Add("")
    $md.Add("## Summary")
    $md.Add("")
    $md.Add("- Markdown files: $($records.Count)")
    $md.Add("- Source root: ``$sourceRootPortable/``")
    $md.Add('- Structured index: `docs/index/gdd_source_index.json`')
    $md.Add('- Filename migration map: `docs/index/gdd_filename_migration.json`')
    $md.Add('- Full-text source snapshot: included below in this file')
    $md.Add("")
    $md.Add("## Top-Level Sections")
    $md.Add("")
    $md.Add("| Section | Title | Files | Words |")
    $md.Add("| ---: | --- | ---: | ---: |")
    foreach ($summary in $sectionSummaries) {
        $summaryTitle = ConvertTo-MarkdownTableCell -Value $summary.title
        $md.Add("| $($summary.section) | $summaryTitle | $($summary.files) | $($summary.words) |")
    }
    $md.Add("")
    $md.Add("## Files By Section")

    foreach ($summary in $sectionSummaries) {
        $md.Add("")
        $summaryTitle = ConvertTo-MarkdownTableCell -Value $summary.title
        $md.Add("### $($summary.section) - $summaryTitle")
        $md.Add("")
        $md.Add("| Section | Title | Words | Source |")
        $md.Add("| --- | --- | ---: | --- |")
        foreach ($record in ($records | Where-Object { $_.top_section -eq $summary.section } | Sort-Object sort_key, file)) {
            $fileName = Split-Path -Leaf $record.file
            $link = ConvertTo-RelativeMarkdownLink -FileName $fileName
            $recordTitle = ConvertTo-MarkdownTableCell -Value $record.title
            $linkLabel = ConvertTo-MarkdownLinkLabel -Value $fileName
            $md.Add("| $($record.section) | $recordTitle | $($record.words) | [$linkLabel]($link) |")
        }
    }

    $md.Add("")
    $md.Add("## Full-Text Search Snapshot")
    $md.Add("")
    $md.Add("This generated section replaces the old root `merged_gdd.txt` broad keyword search artifact. It is rebuilt from `docs/game_design_document/` by `scripts/build-gdd-index.ps1`.")
    foreach ($record in ($records | Sort-Object sort_key, file)) {
        $fileName = Split-Path -Leaf $record.file
        $link = ConvertTo-RelativeMarkdownLink -FileName $fileName
        $recordTitle = ConvertTo-MarkdownTableCell -Value $record.title
        $linkLabel = ConvertTo-MarkdownLinkLabel -Value $fileName
        $raw = $rawByFile[$record.file]

        $md.Add("")
        $md.Add("### $($record.section) - $recordTitle")
        $md.Add("")
        $md.Add("Source: [$linkLabel]($link)")
        if (-not [string]::IsNullOrWhiteSpace($record.original_file)) {
            $md.Add("Original export: ``$($record.original_file)``")
        }
        $md.Add("")
        $md.Add("<!-- GDD_SOURCE_TEXT_BEGIN $($record.file) -->")
        foreach ($line in ($raw -split "\r?\n")) {
            $md.Add($line)
        }
        $md.Add("<!-- GDD_SOURCE_TEXT_END $($record.file) -->")
    }

    $jsonObject = [ordered]@{
        generated_by = "scripts/build-gdd-index.ps1"
        source_root = $sourceRootPortable
        markdown_index = "docs/index/GDD_SOURCE_INDEX.md"
        full_text_snapshot = "docs/index/GDD_SOURCE_INDEX.md#full-text-search-snapshot"
        markdown_file_count = $records.Count
        sections = $sectionSummaries
        files = $records
    }

    return [pscustomobject]@{
        Markdown = (($md -join [Environment]::NewLine) + [Environment]::NewLine)
        Json = (($jsonObject | ConvertTo-Json -Depth 6) + [Environment]::NewLine)
    }
}

$index = New-GddIndex

if ($Check) {
    if (-not (Test-Path -LiteralPath $markdownIndexPath)) {
        throw "Missing generated Markdown index: $markdownIndexPath"
    }
    if (-not (Test-Path -LiteralPath $jsonIndexPath)) {
        throw "Missing generated JSON index: $jsonIndexPath"
    }

    $currentMarkdown = Get-Content -LiteralPath $markdownIndexPath -Raw
    $currentJson = Get-Content -LiteralPath $jsonIndexPath -Raw

    if ($currentMarkdown -ne $index.Markdown) {
        throw "GDD Markdown index is stale. Run scripts\build-gdd-index.ps1."
    }
    if ($currentJson -ne $index.Json) {
        throw "GDD JSON index is stale. Run scripts\build-gdd-index.ps1."
    }

    Write-Host "GDD index check passed: $($index.Json.Length) JSON chars"
    exit 0
}

New-Item -ItemType Directory -Force -Path $indexRoot | Out-String | Write-Verbose
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($markdownIndexPath, $index.Markdown, $utf8NoBom)
[System.IO.File]::WriteAllText($jsonIndexPath, $index.Json, $utf8NoBom)
Write-Host "wrote $markdownIndexPath"
Write-Host "wrote $jsonIndexPath"
