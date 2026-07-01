# GDD Organization

## Purpose

This repository preserves the Infinite Worlds GDD source package and provides lightweight navigation files so Codex can work from a small, searchable map before opening raw export pages.

The Unreal implementation repo remains `F:\dev\infinite-worlds`.

## Source Surfaces

| Path | Role | Keep | Notes |
| --- | --- | --- | --- |
| `markdown_export/` | Authoritative working Markdown export | Yes | Use for source reads after narrowing by section. Do not rename files casually because Notion IDs are part of provenance. |
| `merged_gdd.txt` | Full-text search aggregate | Yes | Useful for broad keyword discovery. It is not the authority when it differs from source Markdown. |
| `Notion_backup/` | Original Notion zip backup | Candidate archive/remove | The current zip matches the Markdown export by file count and size except for the root file name prefix, and does not include helper export artifacts. Keep until off-machine backup or deletion approval is confirmed. |
| `docs/index/` | Generated navigation index | Yes | Regenerate with `scripts/build-gdd-index.ps1`. |
| `docs/` | Curation, retention, navigation notes | Yes | Derived documentation only. |

## Desired Layout

```text
README.md
AGENTS.md
merged_gdd.txt
markdown_export/
Notion_backup/
docs/
  CODEX_GDD_NAVIGATION.md
  GDD_ORGANIZATION.md
  GDD_RETENTION_REVIEW.md
  index/
    GDD_SOURCE_INDEX.md
    gdd_source_index.json
scripts/
  codex-verify.ps1
  build-gdd-index.ps1
```

## Organization Policy

- Keep raw exports intact until a cleanup decision is explicit and backed by an inventory comparison.
- Prefer generated indexes and curation docs over physically reorganizing raw files.
- Keep the GDD source repo private.
- Do not copy implementation backlog files into this repo.
- When extracting implementation tasks, write them in `F:\dev\infinite-worlds`.

## Current Working Decision

The working source surface should be `markdown_export/` plus `merged_gdd.txt`.

`Notion_backup/` is useful as a short-term provenance backup, but it is not useful for normal Codex search. It is safe to treat it as a removal candidate once an external backup or Git history retention decision is confirmed.
