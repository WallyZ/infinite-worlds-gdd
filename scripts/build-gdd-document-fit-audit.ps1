[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path,
    [switch]$Check,
    [switch]$FixParentLinks
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$sourceRootRelative = "docs\game_design_document"
$sourceRoot = Join-Path $repoRoot $sourceRootRelative
$indexRoot = Join-Path $repoRoot "docs\index"
$sourceIndexJsonPath = Join-Path $indexRoot "gdd_source_index.json"
$auditMarkdownPath = Join-Path $indexRoot "GDD_DOCUMENT_FIT_AUDIT.md"
$auditJsonPath = Join-Path $indexRoot "gdd_document_fit_audit.json"

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
    param([Parameter(Mandatory)][string]$PortablePath)

    $fileName = Split-Path -Leaf $PortablePath
    return "../game_design_document/$([uri]::EscapeDataString($fileName))"
}

function Get-SourcePath {
    param([Parameter(Mandatory)][string]$PortablePath)

    return Join-Path $repoRoot ($PortablePath -replace "/", "\")
}

function Get-ParentSection {
    param([Parameter(Mandatory)][string]$Section)

    $parts = @($Section -split "\.")
    if ($parts.Count -le 1) {
        return ""
    }

    return ($parts[0..($parts.Count - 2)] -join ".")
}

function Get-SortKey {
    param([Parameter(Mandatory)][string]$Section)

    return ((@($Section -split "\.") | ForEach-Object { "{0:D4}" -f [int]$_ }) -join ".")
}

function Get-TitleTokens {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Value)

    $stopWords = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($word in @(
        "a", "an", "and", "are", "as", "at", "based", "by", "core", "design", "for", "from", "game",
        "in", "into", "is", "of", "on", "or", "player", "players", "specific", "system", "systems",
        "the", "to", "ui", "ux", "vr", "with"
    )) {
        [void]$stopWords.Add($word)
    }

    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $tokens = [System.Collections.Generic.List[string]]::new()
    foreach ($match in [regex]::Matches($Value.ToLowerInvariant(), "[a-z0-9]+")) {
        $token = $match.Value
        if ($token.Length -le 1) {
            continue
        }
        if ($stopWords.Contains($token)) {
            continue
        }
        if ($seen.Add($token)) {
            $tokens.Add($token)
        }
    }

    return @($tokens)
}

function Get-NormalizedBody {
    param([Parameter(Mandatory)][string]$Raw)

    $text = [regex]::Replace($Raw, "(?s)<!-- GDD_CHILD_LINKS_BEGIN -->.*?<!-- GDD_CHILD_LINKS_END -->", " ")
    $text = [regex]::Replace($text, "(?m)^#+\s+.*$", " ")
    $text = [regex]::Replace($text, "\[[^\]]+\]\([^)]+\)", " ")
    $text = [regex]::Replace($text, "<!--.*?-->", " ", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    return ([regex]::Replace($text.ToLowerInvariant(), "\s+", " ")).Trim()
}

function Get-FileSlugTokens {
    param([Parameter(Mandatory)][string]$PortablePath)

    $fileName = Split-Path -Leaf $PortablePath
    $slug = ($fileName -replace "^(?:\d{2}_){6}\d{2}__", "" -replace "\.md$", "" -replace "-", " ")
    return @(Get-TitleTokens -Value $slug)
}

function Test-HasChildLink {
    param(
        [Parameter(Mandatory)][string]$Raw,
        [Parameter(Mandatory)]$Child
    )

    $fileName = Split-Path -Leaf $Child.file
    return $Raw.Contains($fileName)
}

function Get-ObjectPropertySum {
    param(
        [AllowEmptyCollection()][object[]]$Items,
        [Parameter(Mandatory)][string]$Property
    )

    if ($null -eq $Items) {
        return 0
    }
    if ($Items.Count -eq 0) {
        return 0
    }

    $sum = ($Items | Measure-Object -Property $Property -Sum).Sum
    if ($null -eq $sum) {
        return 0
    }

    return [int]$sum
}

function New-ChildLinkBlock {
    param([Parameter(Mandatory)][object[]]$Children)

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("<!-- GDD_CHILD_LINKS_BEGIN -->")
    $lines.Add("## Subdocuments")
    $lines.Add("")
    foreach ($child in ($Children | Sort-Object sort_key, file)) {
        $fileName = Split-Path -Leaf $child.file
        $label = "$($child.section) $($child.title)"
        $lines.Add("- [$label]($fileName)")
    }
    $lines.Add("<!-- GDD_CHILD_LINKS_END -->")

    return ($lines -join [Environment]::NewLine)
}

function Set-ChildLinkBlock {
    param(
        [Parameter(Mandatory)]$Parent,
        [Parameter(Mandatory)][object[]]$Children
    )

    $path = Get-SourcePath -PortablePath $Parent.file
    $raw = Get-Content -LiteralPath $path -Raw
    $block = New-ChildLinkBlock -Children $Children
    $pattern = "(?s)<!-- GDD_CHILD_LINKS_BEGIN -->.*?<!-- GDD_CHILD_LINKS_END -->"

    if ($raw -match $pattern) {
        $evaluator = [System.Text.RegularExpressions.MatchEvaluator]{
            param($match)
            return $block
        }
        $newRaw = [System.Text.RegularExpressions.Regex]::Replace($raw, $pattern, $evaluator, 1)
    }
    else {
        $newRaw = $raw.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $block + [Environment]::NewLine
    }

    if ($newRaw -ne $raw) {
        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
        [System.IO.File]::WriteAllText($path, $newRaw, $utf8NoBom)
        return $true
    }

    return $false
}

function New-GddDocumentFitAudit {
    if (-not (Test-Path -LiteralPath $sourceRoot)) {
        throw "Missing GDD source root: $sourceRoot"
    }
    if (-not (Test-Path -LiteralPath $sourceIndexJsonPath)) {
        throw "Missing source index JSON: $sourceIndexJsonPath"
    }

    $sourceIndex = Get-Content -LiteralPath $sourceIndexJsonPath -Raw | ConvertFrom-Json
    $records = @($sourceIndex.files | Sort-Object sort_key, file)
    if ($records.Count -eq 0) {
        throw "No files found in source index: $sourceIndexJsonPath"
    }

    $recordsBySection = @{}
    foreach ($record in $records) {
        $recordsBySection[$record.section] = $record
    }

    $childrenByParent = @{}
    foreach ($record in $records) {
        $parentSection = Get-ParentSection -Section $record.section
        if ([string]::IsNullOrWhiteSpace($parentSection)) {
            continue
        }
        if (-not $childrenByParent.ContainsKey($parentSection)) {
            $childrenByParent[$parentSection] = [System.Collections.Generic.List[object]]::new()
        }
        $childrenByParent[$parentSection].Add($record)
    }

    $directChildrenByParent = @{}
    foreach ($parentSection in $childrenByParent.Keys) {
        $direct = @($childrenByParent[$parentSection] | Where-Object { (Get-ParentSection -Section $_.section) -eq $parentSection } | Sort-Object sort_key, file)
        $directChildrenByParent[$parentSection] = $direct
    }

    if ($FixParentLinks) {
        $updatedParents = 0
        foreach ($parentSection in ($directChildrenByParent.Keys | Sort-Object { Get-SortKey -Section $_ })) {
            if (-not $recordsBySection.ContainsKey($parentSection)) {
                continue
            }

            $parent = $recordsBySection[$parentSection]
            $children = @($directChildrenByParent[$parentSection])
            if ($children.Count -eq 0) {
                continue
            }

            $raw = Get-Content -LiteralPath (Get-SourcePath -PortablePath $parent.file) -Raw
            $missing = @($children | Where-Object { -not (Test-HasChildLink -Raw $raw -Child $_) })
            if ($missing.Count -gt 0) {
                if (Set-ChildLinkBlock -Parent $parent -Children $children) {
                    $updatedParents++
                }
            }
        }

        Write-Host "updated parent link blocks: $updatedParents"
        $sourceIndex = Get-Content -LiteralPath $sourceIndexJsonPath -Raw | ConvertFrom-Json
        $records = @($sourceIndex.files | Sort-Object sort_key, file)
    }

    $fileAudits = [System.Collections.Generic.List[object]]::new()
    foreach ($record in $records) {
        $path = Get-SourcePath -PortablePath $record.file
        $raw = Get-Content -LiteralPath $path -Raw
        $body = Get-NormalizedBody -Raw $raw
        $bodyTokens = @(Get-TitleTokens -Value $body)
        $titleTokens = @(Get-TitleTokens -Value $record.title)
        $slugTokens = @(Get-FileSlugTokens -PortablePath $record.file)
        $matchedTitleTokens = @($titleTokens | Where-Object { $bodyTokens -contains $_ })
        $matchedSlugTokens = @($titleTokens | Where-Object { $slugTokens -contains $_ })
        $titleBodyRatio = if ($titleTokens.Count -gt 0) { $matchedTitleTokens.Count / $titleTokens.Count } else { 1 }
        $titleSlugRatio = if ($titleTokens.Count -gt 0) { $matchedSlugTokens.Count / $titleTokens.Count } else { 1 }
        $bodyWords = [regex]::Matches($body, "\S+").Count

        $contentFitStatus = "title-supported"
        if ($bodyWords -le 5) {
            $contentFitStatus = "title-only-stub"
        }
        elseif ([int]$record.words -le 75) {
            $contentFitStatus = "thin-needs-review"
        }
        elseif ($titleTokens.Count -eq 0) {
            $contentFitStatus = "no-title-tokens"
        }
        elseif (($titleBodyRatio -lt 0.34) -and ($matchedTitleTokens.Count -lt 2)) {
            $contentFitStatus = "title-needs-manual-review"
        }

        $children = @()
        if ($directChildrenByParent.ContainsKey($record.section)) {
            $children = @($directChildrenByParent[$record.section])
        }
        $missingChildren = @($children | Where-Object { -not (Test-HasChildLink -Raw $raw -Child $_) })
        $linkedChildren = $children.Count - $missingChildren.Count
        $slugStatus = if ($titleSlugRatio -ge 0.5) { "title-slug-ok" } else { "title-slug-review" }

        $fileAudits.Add([pscustomobject]@{
            section = $record.section
            sort_key = $record.sort_key
            title = $record.title
            file = $record.file
            words = [int]$record.words
            body_words = $bodyWords
            depth = [int]$record.depth
            parent_section = Get-ParentSection -Section $record.section
            direct_child_count = $children.Count
            linked_direct_child_count = $linkedChildren
            missing_direct_child_count = $missingChildren.Count
            missing_direct_children = @($missingChildren | ForEach-Object {
                [pscustomobject]@{
                    section = $_.section
                    title = $_.title
                    file = $_.file
                }
            })
            title_tokens = $titleTokens
            matched_title_tokens = $matchedTitleTokens
            title_body_token_ratio = [math]::Round($titleBodyRatio, 3)
            title_slug_token_ratio = [math]::Round($titleSlugRatio, 3)
            title_slug_status = $slugStatus
            content_fit_status = $contentFitStatus
            generated_child_link_block = ($raw -match "<!-- GDD_CHILD_LINKS_BEGIN -->")
        })
    }

    $parents = @($fileAudits | Where-Object { $_.direct_child_count -gt 0 })
    $parentsWithMissing = @($parents | Where-Object { $_.missing_direct_child_count -gt 0 })
    $missingDirectChildLinkCount = Get-ObjectPropertySum -Items $parentsWithMissing -Property "missing_direct_child_count"
    $slugReview = @($fileAudits | Where-Object { $_.title_slug_status -eq "title-slug-review" })
    $manualTitleReview = @($fileAudits | Where-Object { $_.content_fit_status -eq "title-needs-manual-review" })
    $titleOnlyStubs = @($fileAudits | Where-Object { $_.content_fit_status -eq "title-only-stub" })
    $thinReview = @($fileAudits | Where-Object { $_.content_fit_status -eq "thin-needs-review" })

    $fitGroups = @()
    foreach ($group in ($fileAudits | Group-Object content_fit_status | Sort-Object Name)) {
        $fitGroups += [pscustomobject]@{
            status = $group.Name
            count = $group.Count
        }
    }

    $md = [System.Collections.Generic.List[string]]::new()
    $md.Add("# GDD Document Fit Audit")
    $md.Add("")
    $md.Add('Generated by `scripts/build-gdd-document-fit-audit.ps1`. Regenerate after source, source-index, or parent-link changes.')
    $md.Add("")
    $md.Add("## Summary")
    $md.Add("")
    $md.Add("- markdown files: $($fileAudits.Count)")
    $md.Add("- parent documents with direct subdocuments: $($parents.Count)")
    $md.Add("- parent documents missing direct child links: $($parentsWithMissing.Count)")
    $md.Add("- missing direct child links: $missingDirectChildLinkCount")
    $md.Add("- title/filename review candidates: $($slugReview.Count)")
    $md.Add("- title-only stubs: $($titleOnlyStubs.Count)")
    $md.Add("- thin content review candidates: $($thinReview.Count)")
    $md.Add("- title/content manual review candidates: $($manualTitleReview.Count)")
    $md.Add("")
    $md.Add("## How To Use This Audit")
    $md.Add("")
    $md.Add("- Parent link coverage is verifier-enforced: every direct child page must be linked from its parent page.")
    $md.Add('- `title-only-stub` and `thin-needs-review` mean the page does not yet have enough content to judge beyond the title.')
    $md.Add('- `title-needs-manual-review` is a conservative token-overlap signal, not an automatic mismatch verdict.')
    $md.Add('- Use this audit with `docs/index/GDD_CONTENT_AUDIT.md` when deciding whether to expand, absorb, or move a page.')
    $md.Add("")
    $md.Add("## Content Fit Status Counts")
    $md.Add("")
    $md.Add("| Status | Files |")
    $md.Add("| --- | ---: |")
    foreach ($group in $fitGroups) {
        $md.Add("| $($group.status) | $($group.count) |")
    }
    $md.Add("")
    $md.Add("## Parent Link Coverage")
    $md.Add("")
    if ($parentsWithMissing.Count -eq 0) {
        $md.Add("All parent documents link their direct subdocuments.")
    }
    else {
        $md.Add("| Missing | Parent Section | Parent Title | Source |")
        $md.Add("| ---: | --- | --- | --- |")
        foreach ($parent in ($parentsWithMissing | Sort-Object @{ Expression = "missing_direct_child_count"; Descending = $true }, sort_key)) {
            $fileName = Split-Path -Leaf $parent.file
            $link = ConvertTo-RelativeMarkdownLink -PortablePath $parent.file
            $label = ConvertTo-MarkdownLinkLabel -Value $fileName
            $title = ConvertTo-MarkdownTableCell -Value $parent.title
            $md.Add("| $($parent.missing_direct_child_count) | $($parent.section) | $title | [$label]($link) |")
        }
    }
    $md.Add("")
    $md.Add("## Title And Filename Review Candidates")
    $md.Add("")
    if ($slugReview.Count -eq 0) {
        $md.Add("No title/filename token mismatches were found.")
    }
    else {
        $md.Add("| Ratio | Section | Title | Source |")
        $md.Add("| ---: | --- | --- | --- |")
        foreach ($candidate in ($slugReview | Sort-Object title_slug_token_ratio, sort_key | Select-Object -First 120)) {
            $fileName = Split-Path -Leaf $candidate.file
            $link = ConvertTo-RelativeMarkdownLink -PortablePath $candidate.file
            $label = ConvertTo-MarkdownLinkLabel -Value $fileName
            $title = ConvertTo-MarkdownTableCell -Value $candidate.title
            $md.Add("| $($candidate.title_slug_token_ratio) | $($candidate.section) | $title | [$label]($link) |")
        }
    }
    $md.Add("")
    $md.Add("## Title And Content Manual Review Candidates")
    $md.Add("")
    if ($manualTitleReview.Count -eq 0) {
        $md.Add("No title/content manual review candidates were found by the token-overlap heuristic.")
    }
    else {
        $md.Add("| Ratio | Words | Section | Title | Matched Title Tokens | Source |")
        $md.Add("| ---: | ---: | --- | --- | --- | --- |")
        foreach ($candidate in ($manualTitleReview | Sort-Object title_body_token_ratio, sort_key | Select-Object -First 120)) {
            $fileName = Split-Path -Leaf $candidate.file
            $link = ConvertTo-RelativeMarkdownLink -PortablePath $candidate.file
            $label = ConvertTo-MarkdownLinkLabel -Value $fileName
            $title = ConvertTo-MarkdownTableCell -Value $candidate.title
            $matched = ConvertTo-MarkdownTableCell -Value (($candidate.matched_title_tokens) -join ", ")
            $md.Add("| $($candidate.title_body_token_ratio) | $($candidate.words) | $($candidate.section) | $title | $matched | [$label]($link) |")
        }
    }
    $md.Add("")
    $md.Add("## First 120 Thin Or Title-Only Pages")
    $md.Add("")
    $thinOrStub = @($fileAudits | Where-Object { $_.content_fit_status -in @("title-only-stub", "thin-needs-review") } | Sort-Object body_words, sort_key)
    if ($thinOrStub.Count -eq 0) {
        $md.Add("No thin or title-only pages were found.")
    }
    else {
        $md.Add("| Body Words | Status | Section | Title | Source |")
        $md.Add("| ---: | --- | --- | --- | --- |")
        foreach ($candidate in ($thinOrStub | Select-Object -First 120)) {
            $fileName = Split-Path -Leaf $candidate.file
            $link = ConvertTo-RelativeMarkdownLink -PortablePath $candidate.file
            $label = ConvertTo-MarkdownLinkLabel -Value $fileName
            $title = ConvertTo-MarkdownTableCell -Value $candidate.title
            $md.Add("| $($candidate.body_words) | $($candidate.content_fit_status) | $($candidate.section) | $title | [$label]($link) |")
        }
    }

    $jsonObject = [ordered]@{
        generated_by = "scripts/build-gdd-document-fit-audit.ps1"
        source_index = "docs/index/gdd_source_index.json"
        source_root = "docs/game_design_document"
        summary = [ordered]@{
            markdown_files = $fileAudits.Count
            parent_documents_with_direct_subdocuments = $parents.Count
            parent_documents_missing_direct_child_links = $parentsWithMissing.Count
            missing_direct_child_links = $missingDirectChildLinkCount
            title_filename_review_candidates = $slugReview.Count
            title_only_stubs = $titleOnlyStubs.Count
            thin_content_review_candidates = $thinReview.Count
            title_content_manual_review_candidates = $manualTitleReview.Count
        }
        content_fit_status_counts = $fitGroups
        files = $fileAudits
    }

    return [pscustomobject]@{
        Markdown = (($md -join [Environment]::NewLine) + [Environment]::NewLine)
        Json = (($jsonObject | ConvertTo-Json -Depth 9) + [Environment]::NewLine)
    }
}

$audit = New-GddDocumentFitAudit

if ($Check) {
    if (-not (Test-Path -LiteralPath $auditMarkdownPath)) {
        throw "Missing generated document fit audit: $auditMarkdownPath"
    }
    if (-not (Test-Path -LiteralPath $auditJsonPath)) {
        throw "Missing generated document fit audit JSON: $auditJsonPath"
    }

    $currentMarkdown = Get-Content -LiteralPath $auditMarkdownPath -Raw
    $currentJson = Get-Content -LiteralPath $auditJsonPath -Raw
    if ($currentMarkdown -ne $audit.Markdown) {
        throw "GDD document fit audit Markdown is stale. Run scripts\build-gdd-document-fit-audit.ps1."
    }
    if ($currentJson -ne $audit.Json) {
        throw "GDD document fit audit JSON is stale. Run scripts\build-gdd-document-fit-audit.ps1."
    }

    $auditJson = $audit.Json | ConvertFrom-Json
    if ([int]$auditJson.summary.parent_documents_missing_direct_child_links -ne 0) {
        throw "GDD parent link coverage failed: $($auditJson.summary.parent_documents_missing_direct_child_links) parent documents are missing direct child links."
    }
    if ([int]$auditJson.summary.title_filename_review_candidates -ne 0) {
        throw "GDD title/filename fit failed: $($auditJson.summary.title_filename_review_candidates) documents need title/filename review."
    }

    Write-Host "GDD document fit audit check passed: $($audit.Json.Length) JSON chars"
    exit 0
}

New-Item -ItemType Directory -Force -Path $indexRoot | Out-String | Write-Verbose
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($auditMarkdownPath, $audit.Markdown, $utf8NoBom)
[System.IO.File]::WriteAllText($auditJsonPath, $audit.Json, $utf8NoBom)
Write-Host "wrote $auditMarkdownPath"
Write-Host "wrote $auditJsonPath"
