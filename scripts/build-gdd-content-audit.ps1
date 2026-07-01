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
$sourceIndexJsonPath = Join-Path $indexRoot "gdd_source_index.json"
$auditMarkdownPath = Join-Path $indexRoot "GDD_CONTENT_AUDIT.md"
$auditJsonPath = Join-Path $indexRoot "gdd_content_audit.json"

$targetAreaOrder = @(
    "Design Control and Overview",
    "Player Core Rules and Experience",
    "World and Simulation",
    "Magic and Supernatural Systems",
    "Combat and Encounter Systems",
    "Items, Crafting, and Settlement",
    "AI, NPCs, and Factions",
    "Narrative, Lore, and Quests",
    "Art, Audio, UI, and UX",
    "Technical, Tooling, and QA",
    "Production, Community, and Publishing",
    "Appendix and Reference"
)

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
    param([Parameter(Mandatory)][string]$PortablePath)

    $fileName = Split-Path -Leaf $PortablePath
    return "../game_design_document/$([uri]::EscapeDataString($fileName))"
}

function Get-SortKey {
    param([Parameter(Mandatory)][string]$Section)

    return ((@($Section -split "\.") | ForEach-Object { "{0:D4}" -f [int]$_ }) -join ".")
}

function Get-TitleTokens {
    param([Parameter(Mandatory)][string]$Value)

    $stopWords = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($word in @(
        "a", "an", "and", "are", "as", "at", "based", "by", "core", "design", "for", "from", "in", "into",
        "is", "of", "on", "or", "system", "systems", "the", "to", "ui", "ux", "vr", "with"
    )) {
        [void]$stopWords.Add($word)
    }

    $tokens = [System.Collections.Generic.List[string]]::new()
    foreach ($match in [regex]::Matches($Value.ToLowerInvariant(), "[a-z0-9]+")) {
        $token = $match.Value
        if ($token.Length -lt 2) {
            continue
        }
        if ($stopWords.Contains($token)) {
            continue
        }
        $tokens.Add($token)
    }

    return @($tokens | Select-Object -Unique)
}

function Get-NormalizedTitleKey {
    param([Parameter(Mandatory)][string]$Title)

    $tokens = Get-TitleTokens -Value $Title
    if ($tokens.Count -eq 0) {
        return $Title.ToLowerInvariant()
    }

    return ($tokens -join " ")
}

function Get-NormalizedBody {
    param([Parameter(Mandatory)][string]$Raw)

    $withoutHeadings = [regex]::Replace($Raw, "(?m)^#+\s+.*$", " ")
    $withoutLinks = [regex]::Replace($withoutHeadings, "\[([^\]]+)\]\([^)]+\)", " $1 ")
    $withoutComments = [regex]::Replace($withoutLinks, "<!--.*?-->", " ", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $lower = $withoutComments.ToLowerInvariant()
    return ([regex]::Replace($lower, "\s+", " ")).Trim()
}

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Value)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
        $hash = $sha.ComputeHash($bytes)
        return (($hash | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    finally {
        $sha.Dispose()
    }
}

function Test-AnyPattern {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($Text -match $pattern) {
            return $true
        }
    }

    return $false
}

function Get-TargetArea {
    param(
        [Parameter(Mandatory)]$Record,
        [Parameter(Mandatory)][string]$Raw
    )

    $top = [int]$Record.top_section
    $haystack = "$($Record.title) $($Record.file)".ToLowerInvariant()

    if ($top -eq 0 -or $top -eq 1) {
        return "Design Control and Overview"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("accessib", "comfort", "motion sickness", "tutorial", "onboarding", "player persona", "archetype", "learning", "progression", "movement", "interaction", "immersion", "locomotion")) {
        return "Player Core Rules and Experience"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("roadmap", "publishing", "funding", "community", "monetization", "store", "marketing", "kickstarter", "patreon", "social media", "press kit", "localization", "risk", "milestone", "team structure")) {
        return "Production, Community, and Publishing"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("engine", "unreal", "blueprint", "network", "save", "cloud", "architecture", "debug", "testing", "analytics", "security", "anti-cheat", "performance", "modding", "automation", "tool", "qa", "fsm")) {
        return "Technical, Tooling, and QA"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("glossary", "appendix", "reference", "table", "chart", "diagram", "database", "example", "wireframe", "flowchart", "parameter", "persona", "guide")) {
        return "Appendix and Reference"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("art", "visual", "vfx", "animation", "audio", "sound", "music", "hud", "interface", "font", "icon", "palette", "brand", "texture", "material", "feedback", "haptic")) {
        return "Art, Audio, UI, and UX"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("combat", "stealth", "detection", "weapon", "armor", "enemy", "boss", "status effect", "condition", "tactical", "encounter", "projectile", "grappling")) {
        return "Combat and Encounter Systems"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("craft", "building", "settlement", "inventory", "equipment", "item", "material", "recipe", "resource", "construction", "repair", "container", "bag", "weight")) {
        return "Items, Crafting, and Settlement"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("magic", "psionic", "ritual", "spell", "artifact", "astral", "dream", "soul", "mana", "rune", "planar", "plane", "aether", "enchant")) {
        return "Magic and Supernatural Systems"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("npc", "ai", "dialogue", "relationship", "faction", "companion", "routine", "social", "behavior", "emotion", "personality", "reputation", "memory", "gossip")) {
        return "AI, NPCs, and Factions"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("narrative", "story", "lore", "myth", "quest", "legend", "timeline", "religion", "symbol", "history", "deed")) {
        return "Narrative, Lore, and Quests"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("world", "biome", "weather", "time", "ecology", "civilization", "economy", "terrain", "underworld", "disease", "poison", "affliction", "species", "environment", "procedural", "generation")) {
        return "World and Simulation"
    }

    if (Test-AnyPattern -Text $haystack -Patterns @("pitch", "vision", "pillar", "audience", "platform", "philosophy", "goal")) {
        return "Design Control and Overview"
    }

    switch ($top) {
        2 { return "Player Core Rules and Experience" }
        3 { return "World and Simulation" }
        4 { return "Magic and Supernatural Systems" }
        5 { return "Combat and Encounter Systems" }
        6 { return "Items, Crafting, and Settlement" }
        7 { return "AI, NPCs, and Factions" }
        8 { return "Art, Audio, UI, and UX" }
        9 { return "Narrative, Lore, and Quests" }
        10 { return "Art, Audio, UI, and UX" }
        11 { return "Technical, Tooling, and QA" }
        12 { return "Production, Community, and Publishing" }
        13 { return "Player Core Rules and Experience" }
        14 { return "Production, Community, and Publishing" }
        15 { return "Appendix and Reference" }
        default { return "Appendix and Reference" }
    }
}

function Get-StateFlags {
    param(
        [Parameter(Mandatory)]$Record,
        [Parameter(Mandatory)][string]$Raw,
        [Parameter(Mandatory)][AllowEmptyString()][string]$NormalizedBody
    )

    $flags = [System.Collections.Generic.List[string]]::new()
    $wordCount = [int]$Record.words
    $linkCount = [regex]::Matches($Raw, "\[[^\]]+\]\([^)]+\)").Count
    $bodyWords = [regex]::Matches($NormalizedBody, "\S+").Count

    if ($wordCount -le 20) {
        $flags.Add("stub-20-words-or-less")
    }
    elseif ($wordCount -le 75) {
        $flags.Add("thin-75-words-or-less")
    }

    if ($linkCount -ge 3 -and $bodyWords -le 70) {
        $flags.Add("link-index-page")
    }

    if ($Raw -match "(?i)\b(tbd|todo|placeholder|coming soon|not yet|to be defined|needs update|needs expansion|stub)\b") {
        $flags.Add("explicit-incomplete-marker")
    }

    if ($bodyWords -le 5) {
        $flags.Add("heading-only-or-nearly-empty")
    }

    return @($flags)
}

function New-GddContentAudit {
    if (-not (Test-Path -LiteralPath $sourceRoot)) {
        throw "Missing GDD source root: $sourceRoot"
    }
    if (-not (Test-Path -LiteralPath $sourceIndexJsonPath)) {
        throw "Missing source index JSON: $sourceIndexJsonPath"
    }

    $sourceIndex = Get-Content -LiteralPath $sourceIndexJsonPath -Raw | ConvertFrom-Json
    $sourceRecords = @($sourceIndex.files)
    if ($sourceRecords.Count -eq 0) {
        throw "Source index contains no files."
    }

    $records = [System.Collections.Generic.List[object]]::new()
    foreach ($record in ($sourceRecords | Sort-Object sort_key, file)) {
        $filePath = Join-Path $repoRoot ($record.file -replace "/", "\")
        if (-not (Test-Path -LiteralPath $filePath)) {
            throw "Indexed source file is missing: $($record.file)"
        }

        $raw = Get-Content -LiteralPath $filePath -Raw
        $normalizedBody = Get-NormalizedBody -Raw $raw
        $area = Get-TargetArea -Record $record -Raw $raw
        $flags = Get-StateFlags -Record $record -Raw $raw -NormalizedBody $normalizedBody
        $titleKey = Get-NormalizedTitleKey -Title $record.title

        $records.Add([pscustomobject]@{
            section = [string]$record.section
            sort_key = [string]$record.sort_key
            top_section = [int]$record.top_section
            depth = [int]$record.depth
            title = [string]$record.title
            file = [string]$record.file
            words = [int]$record.words
            bytes = [int]$record.bytes
            target_area = $area
            title_key = $titleKey
            content_hash = if ($normalizedBody.Length -ge 120) { Get-Sha256 -Value $normalizedBody } else { "" }
            normalized_body_chars = $normalizedBody.Length
            link_count = [regex]::Matches($raw, "\[[^\]]+\]\([^)]+\)").Count
            flags = $flags
        })
    }

    $sectionSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($record in $records) {
        [void]$sectionSet.Add($record.section)
    }

    $duplicateSections = @(
        $records |
            Group-Object section |
            Where-Object { $_.Count -gt 1 } |
            Sort-Object { Get-SortKey -Section $_.Name } |
            ForEach-Object {
                [pscustomobject]@{
                    section = $_.Name
                    count = $_.Count
                    titles = @($_.Group | Sort-Object sort_key, file | ForEach-Object { $_.title })
                    files = @($_.Group | Sort-Object sort_key, file | ForEach-Object { $_.file })
                }
            }
    )

    $orphans = @(
        foreach ($record in ($records | Where-Object { $_.depth -gt 1 } | Sort-Object sort_key, file)) {
            $parts = @($record.section -split "\.")
            $parent = ($parts[0..($parts.Count - 2)] -join ".")
            if (-not $sectionSet.Contains($parent)) {
                [pscustomobject]@{
                    section = $record.section
                    missing_parent = $parent
                    title = $record.title
                    file = $record.file
                }
            }
        }
    )

    $titleDuplicates = @(
        $records |
            Group-Object title_key |
            Where-Object { $_.Count -gt 1 -and -not [string]::IsNullOrWhiteSpace($_.Name) } |
            Sort-Object -Property @{ Expression = "Count"; Descending = $true }, @{ Expression = "Name"; Ascending = $true } |
            ForEach-Object {
                [pscustomobject]@{
                    title_key = $_.Name
                    count = $_.Count
                    entries = @($_.Group | Sort-Object sort_key, file | ForEach-Object {
                        [pscustomobject]@{
                            section = $_.section
                            title = $_.title
                            file = $_.file
                            target_area = $_.target_area
                            words = $_.words
                        }
                    })
                }
            }
    )

    $contentDuplicates = @(
        $records |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_.content_hash) } |
            Group-Object content_hash |
            Where-Object { $_.Count -gt 1 } |
            Sort-Object Count -Descending |
            ForEach-Object {
                [pscustomobject]@{
                    content_hash = $_.Name
                    count = $_.Count
                    entries = @($_.Group | Sort-Object sort_key, file | ForEach-Object {
                        [pscustomobject]@{
                            section = $_.section
                            title = $_.title
                            file = $_.file
                            target_area = $_.target_area
                            words = $_.words
                        }
                    })
                }
            }
    )

    $contentDuplicateHashes = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($group in $contentDuplicates) {
        [void]$contentDuplicateHashes.Add($group.content_hash)
    }

    $titleInfos = @($records | ForEach-Object {
        [pscustomobject]@{
            record = $_
            tokens = @(Get-TitleTokens -Value $_.title)
        }
    })

    $similarTitles = [System.Collections.Generic.List[object]]::new()
    for ($i = 0; $i -lt $titleInfos.Count; $i++) {
        $a = $titleInfos[$i]
        if ($a.tokens.Count -lt 2) {
            continue
        }

        $aSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        foreach ($token in $a.tokens) {
            [void]$aSet.Add($token)
        }

        for ($j = $i + 1; $j -lt $titleInfos.Count; $j++) {
            $b = $titleInfos[$j]
            if ($b.tokens.Count -lt 2) {
                continue
            }
            if ($a.record.title_key -eq $b.record.title_key) {
                continue
            }

            $bSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
            foreach ($token in $b.tokens) {
                [void]$bSet.Add($token)
            }

            $intersection = 0
            foreach ($token in $aSet) {
                if ($bSet.Contains($token)) {
                    $intersection++
                }
            }
            if ($intersection -lt 2) {
                continue
            }

            $union = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
            foreach ($token in $aSet) {
                [void]$union.Add($token)
            }
            foreach ($token in $bSet) {
                [void]$union.Add($token)
            }

            $score = [math]::Round(($intersection / [double]$union.Count), 3)
            if (($score -ge 0.67) -or ($intersection -ge 3 -and $score -ge 0.5)) {
                $similarTitles.Add([pscustomobject]@{
                    score = $score
                    shared_tokens = $intersection
                    left_section = $a.record.section
                    left_title = $a.record.title
                    left_file = $a.record.file
                    left_area = $a.record.target_area
                    right_section = $b.record.section
                    right_title = $b.record.title
                    right_file = $b.record.file
                    right_area = $b.record.target_area
                })
            }
        }
    }

    $similarTitles = @(
        $similarTitles |
            Sort-Object -Property @{ Expression = "score"; Descending = $true }, @{ Expression = "shared_tokens"; Descending = $true }, "left_section", "right_section" |
            Select-Object -First 150
    )

    $incompleteCandidates = @(
        $records |
            Where-Object { $_.flags.Count -gt 0 } |
            Sort-Object words, sort_key, file |
            ForEach-Object {
                [pscustomobject]@{
                    section = $_.section
                    title = $_.title
                    file = $_.file
                    target_area = $_.target_area
                    words = $_.words
                    flags = @($_.flags)
                }
            }
    )

    $removalCandidates = @(
        $records |
            Where-Object {
                ($_.flags -contains "heading-only-or-nearly-empty") -or
                ($_.flags -contains "stub-20-words-or-less") -or
                (-not [string]::IsNullOrWhiteSpace($_.content_hash) -and $contentDuplicateHashes.Contains($_.content_hash))
            } |
            Sort-Object words, sort_key, file |
            ForEach-Object {
                [pscustomobject]@{
                    section = $_.section
                    title = $_.title
                    file = $_.file
                    target_area = $_.target_area
                    words = $_.words
                    recommended_action = "merge-or-remove-after-parent-absorption"
                    reason = (@($_.flags) -join "; ")
                }
            }
    )

    $areaInventory = @(
        foreach ($area in $targetAreaOrder) {
            $group = @($records | Where-Object { $_.target_area -eq $area })
            if ($group.Count -eq 0) {
                [pscustomobject]@{
                    target_area = $area
                    files = 0
                    words = 0
                    current_top_sections = @()
                    stub_or_thin = 0
                    duplicate_title_groups = 0
                }
                continue
            }

            $titleDupesInArea = @($titleDuplicates | Where-Object {
                $entryAreas = @($_.entries | ForEach-Object { $_.target_area } | Select-Object -Unique)
                $entryAreas -contains $area
            })

            [pscustomobject]@{
                target_area = $area
                files = $group.Count
                words = (($group | Measure-Object -Property words -Sum).Sum)
                current_top_sections = @($group | ForEach-Object { $_.top_section } | Sort-Object -Unique)
                stub_or_thin = @($group | Where-Object { $_.flags -contains "stub-20-words-or-less" -or $_.flags -contains "thin-75-words-or-less" }).Count
                duplicate_title_groups = $titleDupesInArea.Count
            }
        }
    )

    $topSectionAreaMatrix = @(
        $records |
            Group-Object top_section |
            Sort-Object { [int]$_.Name } |
            ForEach-Object {
                $top = [int]$_.Name
                $areaBreakdown = @(
                    $_.Group |
                        Group-Object target_area |
                        Sort-Object -Property @{ Expression = "Count"; Descending = $true }, @{ Expression = "Name"; Ascending = $true } |
                        ForEach-Object {
                            [pscustomobject]@{
                                target_area = $_.Name
                                files = $_.Count
                                words = (($_.Group | Measure-Object -Property words -Sum).Sum)
                            }
                        }
                )
                [pscustomobject]@{
                    top_section = $top
                    title = (@($sourceIndex.sections | Where-Object { [int]$_.section -eq $top } | Select-Object -First 1).title)
                    files = $_.Count
                    words = (($_.Group | Measure-Object -Property words -Sum).Sum)
                    target_area_breakdown = $areaBreakdown
                }
            }
    )

    $nonMarkdownAssets = @(
        Get-ChildItem -LiteralPath $sourceRoot -File |
            Where-Object { $_.Extension -ne ".md" } |
            Sort-Object Extension, Name |
            ForEach-Object {
                [pscustomobject]@{
                    file = Get-PortablePath -Path ($sourceRootRelative + "\" + $_.Name)
                    extension = if ([string]::IsNullOrWhiteSpace($_.Extension)) { "(none)" } else { $_.Extension.ToLowerInvariant() }
                    bytes = $_.Length
                }
            }
    )

    $summary = [ordered]@{
        markdown_files = $records.Count
        total_words = (($records | Measure-Object -Property words -Sum).Sum)
        target_areas = $targetAreaOrder.Count
        duplicate_section_numbers = $duplicateSections.Count
        orphaned_sections = $orphans.Count
        duplicate_title_groups = $titleDuplicates.Count
        exact_content_duplicate_groups = $contentDuplicates.Count
        similar_title_candidates = $similarTitles.Count
        incomplete_or_stub_candidates = $incompleteCandidates.Count
        removal_or_merge_candidates = $removalCandidates.Count
        non_markdown_assets = $nonMarkdownAssets.Count
    }

    $md = [System.Collections.Generic.List[string]]::new()
    $md.Add("# GDD Content Audit")
    $md.Add("")
    $md.Add("Generated by `scripts/build-gdd-content-audit.ps1`. Regenerate after source or source-index changes.")
    $md.Add("")
    $md.Add("## Summary")
    $md.Add("")
    foreach ($key in $summary.Keys) {
        $label = ($key -replace "_", " ")
        $md.Add("- ${label}: $($summary[$key])")
    }
    $md.Add("")
    $md.Add("## How To Use This Audit")
    $md.Add("")
    $md.Add("- Use `docs/index/GDD_SOURCE_INDEX.md` for full-text search and section lookup.")
    $md.Add("- Use this audit to choose curation work: renumbering, merging, stub expansion, or removal after parent absorption.")
    $md.Add("- Treat every removal candidate as review-required; this repo preserves source material unless a curation note says where the idea moved.")
    $md.Add("- Keep implementation TODO updates in `F:\dev\infinite-worlds`.")
    $md.Add("")
    $md.Add("## Target Area Inventory")
    $md.Add("")
    $md.Add("| Target Area | Files | Words | Current Top Sections | Stub/Thin | Duplicate Title Groups |")
    $md.Add("| --- | ---: | ---: | --- | ---: | ---: |")
    foreach ($area in $areaInventory) {
        $tops = if ($area.current_top_sections.Count -gt 0) { (@($area.current_top_sections) -join ", ") } else { "" }
        $areaName = ConvertTo-MarkdownTableCell -Value $area.target_area
        $md.Add("| $areaName | $($area.files) | $($area.words) | $tops | $($area.stub_or_thin) | $($area.duplicate_title_groups) |")
    }
    $md.Add("")
    $md.Add("## Current Sections Versus Target Areas")
    $md.Add("")
    $md.Add("| Current Section | Title | Files | Words | Largest Target Area | Secondary Areas |")
    $md.Add("| ---: | --- | ---: | ---: | --- | --- |")
    foreach ($top in $topSectionAreaMatrix) {
        $breakdown = @($top.target_area_breakdown)
        $largest = $breakdown | Select-Object -First 1
        $secondary = @($breakdown | Select-Object -Skip 1 | ForEach-Object { "$($_.target_area) ($($_.files))" })
        $title = ConvertTo-MarkdownTableCell -Value $top.title
        $largestLabel = if ($largest) { "$(ConvertTo-MarkdownTableCell -Value $largest.target_area) ($($largest.files))" } else { "" }
        $secondaryLabel = ConvertTo-MarkdownTableCell -Value ($secondary -join "; ")
        $md.Add("| $($top.top_section) | $title | $($top.files) | $($top.words) | $largestLabel | $secondaryLabel |")
    }
    $md.Add("")
    $md.Add("## Structural Issues")
    $md.Add("")
    $md.Add("### Duplicate Section Numbers")
    $md.Add("")
    if ($duplicateSections.Count -eq 0) {
        $md.Add("None.")
    }
    else {
        $md.Add("| Section | Count | Titles |")
        $md.Add("| --- | ---: | --- |")
        foreach ($dupe in $duplicateSections) {
            $titles = ConvertTo-MarkdownTableCell -Value (@($dupe.titles) -join "; ")
            $md.Add("| $($dupe.section) | $($dupe.count) | $titles |")
        }
    }
    $md.Add("")
    $md.Add("### Orphaned Sections")
    $md.Add("")
    if ($orphans.Count -eq 0) {
        $md.Add("None.")
    }
    else {
        $md.Add("| Section | Missing Parent | Title | Source |")
        $md.Add("| --- | --- | --- | --- |")
        foreach ($orphan in $orphans) {
            $title = ConvertTo-MarkdownTableCell -Value $orphan.title
            $fileName = Split-Path -Leaf $orphan.file
            $link = ConvertTo-RelativeMarkdownLink -PortablePath $orphan.file
            $label = ConvertTo-MarkdownLinkLabel -Value $fileName
            $md.Add("| $($orphan.section) | $($orphan.missing_parent) | $title | [$label]($link) |")
        }
    }
    $md.Add("")
    $md.Add("## Duplication And Overlap")
    $md.Add("")
    $md.Add("### Duplicate Title Groups")
    $md.Add("")
    if ($titleDuplicates.Count -eq 0) {
        $md.Add("None.")
    }
    else {
        $md.Add("| Title Key | Count | Entries |")
        $md.Add("| --- | ---: | --- |")
        foreach ($group in ($titleDuplicates | Select-Object -First 80)) {
            $entries = @($group.entries | ForEach-Object { "$($_.section) $($_.title)" })
            $entryText = ConvertTo-MarkdownTableCell -Value ($entries -join "; ")
            $key = ConvertTo-MarkdownTableCell -Value $group.title_key
            $md.Add("| $key | $($group.count) | $entryText |")
        }
    }
    $md.Add("")
    $md.Add("### Exact Content Duplicate Groups")
    $md.Add("")
    if ($contentDuplicates.Count -eq 0) {
        $md.Add("None found above the 120-character normalized-body threshold.")
    }
    else {
        $md.Add("| Count | Entries |")
        $md.Add("| ---: | --- |")
        foreach ($group in ($contentDuplicates | Select-Object -First 40)) {
            $entries = @($group.entries | ForEach-Object { "$($_.section) $($_.title)" })
            $entryText = ConvertTo-MarkdownTableCell -Value ($entries -join "; ")
            $md.Add("| $($group.count) | $entryText |")
        }
    }
    $md.Add("")
    $md.Add("### Similar Title Candidates")
    $md.Add("")
    if ($similarTitles.Count -eq 0) {
        $md.Add("None found at the current threshold.")
    }
    else {
        $md.Add("| Score | Left | Right | Areas |")
        $md.Add("| ---: | --- | --- | --- |")
        foreach ($candidate in ($similarTitles | Select-Object -First 80)) {
            $left = ConvertTo-MarkdownTableCell -Value "$($candidate.left_section) $($candidate.left_title)"
            $right = ConvertTo-MarkdownTableCell -Value "$($candidate.right_section) $($candidate.right_title)"
            $areas = ConvertTo-MarkdownTableCell -Value "$($candidate.left_area) -> $($candidate.right_area)"
            $md.Add("| $($candidate.score) | $left | $right | $areas |")
        }
    }
    $md.Add("")
    $md.Add("## Incomplete Or Thin Pages")
    $md.Add("")
    $md.Add("### Candidate Counts By Target Area")
    $md.Add("")
    $md.Add("| Target Area | Candidates |")
    $md.Add("| --- | ---: |")
    foreach ($group in ($incompleteCandidates | Group-Object target_area | Sort-Object -Property @{ Expression = "Count"; Descending = $true }, @{ Expression = "Name"; Ascending = $true })) {
        $areaName = ConvertTo-MarkdownTableCell -Value $group.Name
        $md.Add("| $areaName | $($group.Count) |")
    }
    $md.Add("")
    $md.Add("### First 120 Candidates")
    $md.Add("")
    if ($incompleteCandidates.Count -eq 0) {
        $md.Add("None.")
    }
    else {
        $md.Add("| Words | Flags | Section | Title | Source |")
        $md.Add("| ---: | --- | --- | --- | --- |")
        foreach ($candidate in ($incompleteCandidates | Select-Object -First 120)) {
            $flags = ConvertTo-MarkdownTableCell -Value (@($candidate.flags) -join "; ")
            $title = ConvertTo-MarkdownTableCell -Value $candidate.title
            $fileName = Split-Path -Leaf $candidate.file
            $link = ConvertTo-RelativeMarkdownLink -PortablePath $candidate.file
            $label = ConvertTo-MarkdownLinkLabel -Value $fileName
            $md.Add("| $($candidate.words) | $flags | $($candidate.section) | $title | [$label]($link) |")
        }
    }
    $md.Add("")
    $md.Add("## Merge Or Removal Review Candidates")
    $md.Add("")
    $md.Add("These are not automatic deletes. Merge/remove only after preserving the idea in a parent or canonical page.")
    $md.Add("")
    if ($removalCandidates.Count -eq 0) {
        $md.Add("None.")
    }
    else {
        $md.Add("| Words | Section | Title | Reason |")
        $md.Add("| ---: | --- | --- | --- |")
        foreach ($candidate in ($removalCandidates | Select-Object -First 120)) {
            $title = ConvertTo-MarkdownTableCell -Value $candidate.title
            $reason = ConvertTo-MarkdownTableCell -Value $candidate.reason
            $md.Add("| $($candidate.words) | $($candidate.section) | $title | $reason |")
        }
    }
    $md.Add("")
    $md.Add("## Non-Markdown Export Assets")
    $md.Add("")
    if ($nonMarkdownAssets.Count -eq 0) {
        $md.Add("None.")
    }
    else {
        $md.Add("| Extension | Bytes | Source |")
        $md.Add("| --- | ---: | --- |")
        foreach ($asset in $nonMarkdownAssets) {
            $fileName = Split-Path -Leaf $asset.file
            $source = ConvertTo-MarkdownTableCell -Value $fileName
            $md.Add("| $($asset.extension) | $($asset.bytes) | $source |")
        }
    }
    $md.Add("")
    $md.Add("## Recommended Curation Queue")
    $md.Add("")

    if (($duplicateSections.Count -gt 0) -and ($orphans.Count -gt 0)) {
        $md.Add("1. Fix duplicate section numbers and the orphaned branch without changing page content.")
    }
    elseif ($duplicateSections.Count -gt 0) {
        $md.Add("1. Fix duplicate section numbers without changing page content.")
    }
    elseif ($orphans.Count -gt 0) {
        $md.Add("1. Fix orphaned branches without changing page content.")
    }
    else {
        $md.Add("1. Review the next highest-impact structural issue before changing source content.")
    }
    $md.Add("2. Mark link-index pages as parent summaries or absorb them into stronger parent pages.")
    $md.Add("3. Consolidate duplicate title groups and high-score similar title candidates.")
    $md.Add("4. Expand or absorb stub/thin pages, starting with pages under 20 words.")
    $md.Add("5. Use `docs/GDD_TARGET_STRUCTURE.md` as the target library when moving curated pages.")
    $md.Add("6. Mirror implementation-impacting decisions into TODOs in `F:\dev\infinite-worlds`.")

    $jsonObject = [ordered]@{
        generated_by = "scripts/build-gdd-content-audit.ps1"
        source_index = "docs/index/gdd_source_index.json"
        source_root = $sourceRootPortable
        target_area_order = $targetAreaOrder
        summary = $summary
        target_area_inventory = $areaInventory
        current_section_target_area_matrix = $topSectionAreaMatrix
        duplicate_section_numbers = $duplicateSections
        orphaned_sections = $orphans
        duplicate_title_groups = $titleDuplicates
        exact_content_duplicate_groups = $contentDuplicates
        similar_title_candidates = $similarTitles
        incomplete_or_stub_candidates = $incompleteCandidates
        merge_or_removal_review_candidates = $removalCandidates
        non_markdown_assets = $nonMarkdownAssets
        files = @($records | Sort-Object sort_key, file | ForEach-Object {
            [pscustomobject]@{
                section = $_.section
                title = $_.title
                file = $_.file
                target_area = $_.target_area
                words = $_.words
                flags = @($_.flags)
            }
        })
    }

    return [pscustomobject]@{
        Markdown = (($md -join [Environment]::NewLine) + [Environment]::NewLine)
        Json = (($jsonObject | ConvertTo-Json -Depth 9) + [Environment]::NewLine)
    }
}

$audit = New-GddContentAudit

if ($Check) {
    if (-not (Test-Path -LiteralPath $auditMarkdownPath)) {
        throw "Missing generated Markdown audit: $auditMarkdownPath"
    }
    if (-not (Test-Path -LiteralPath $auditJsonPath)) {
        throw "Missing generated JSON audit: $auditJsonPath"
    }

    $currentMarkdown = Get-Content -LiteralPath $auditMarkdownPath -Raw
    $currentJson = Get-Content -LiteralPath $auditJsonPath -Raw

    if ($currentMarkdown -ne $audit.Markdown) {
        throw "GDD content audit Markdown is stale. Run scripts\build-gdd-content-audit.ps1."
    }
    if ($currentJson -ne $audit.Json) {
        throw "GDD content audit JSON is stale. Run scripts\build-gdd-content-audit.ps1."
    }

    Write-Host "GDD content audit check passed: $($audit.Json.Length) JSON chars"
    exit 0
}

New-Item -ItemType Directory -Force -Path $indexRoot | Out-String | Write-Verbose
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($auditMarkdownPath, $audit.Markdown, $utf8NoBom)
[System.IO.File]::WriteAllText($auditJsonPath, $audit.Json, $utf8NoBom)
Write-Host "wrote $auditMarkdownPath"
Write-Host "wrote $auditJsonPath"
