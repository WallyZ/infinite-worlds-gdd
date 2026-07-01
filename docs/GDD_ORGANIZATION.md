# GDD Organization

## Purpose

This repository preserves the Infinite Worlds GDD source package and provides lightweight navigation files so Codex can work from a small, searchable map before opening source pages.

The Unreal implementation repo remains `F:\dev\infinite-worlds`.

## Source Surfaces

| Path | Role | Keep | Notes |
| --- | --- | --- | --- |
| `docs/game_design_document/` | Authoritative working GDD source set | Yes | Sortable, normalized filenames. Source bodies remain export-derived. |
| `merged_gdd.txt` | Full-text search aggregate | Yes | Useful for broad keyword discovery. It is not the authority when it differs from source Markdown. |
| `docs/index/` | Generated navigation and provenance indexes | Yes | Regenerate with `scripts/build-gdd-index.ps1`. |
| `docs/` | Curation, standards, retention, navigation notes | Yes | Derived documentation only. |
| `Notion_backup/` | Removed owner-side backup | No | Removed after confirming it duplicated the Markdown export. |

## Current Layout

```text
README.md
AGENTS.md
merged_gdd.txt
docs/
  CODEX_GDD_NAVIGATION.md
  GDD_ORGANIZATION.md
  GDD_RETENTION_REVIEW.md
  GDD_STANDARDS.md
  GDD_STRUCTURE_REVIEW.md
  game_design_document/
    NN_NN_NN_NN_NN_NN_NN__kebab-case-title.md
  index/
    GDD_SOURCE_INDEX.md
    gdd_source_index.json
    gdd_filename_migration.json
scripts/
  codex-verify.ps1
  build-gdd-index.ps1
```

## Organization Policy

- Keep the GDD source repo private.
- Prefer generated indexes and curation docs over large manual rewrites.
- Keep implementation backlog files in `F:\dev\infinite-worlds`.
- Preserve source provenance through the migration map and generated index.
- Fix numbering and structure deliberately; do not silently merge or delete design concepts.

## Current Working Decision

`docs/game_design_document/` plus `merged_gdd.txt` is the active source surface.

The next cleanup lane is conceptual curation: resolve duplicate section numbers, orphaned sections, tiny placeholder docs, and cross-section overlap identified in `docs/GDD_STRUCTURE_REVIEW.md`.
