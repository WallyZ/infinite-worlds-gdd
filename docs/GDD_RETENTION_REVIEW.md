# GDD Retention Review

## Current Inventory

Observed on 2026-07-01 after source migration:

| Surface | Files | Bytes | Decision |
| --- | ---: | ---: | --- |
| `docs/game_design_document/` | 666 | 5,765,066 | Keep as working GDD source set. |
| `docs/index/GDD_SOURCE_INDEX.md` | 1 | generated | Keep as generated section index and full-text search snapshot. |
| `docs/index/gdd_filename_migration.json` | 1 | generated | Keep for old-name to new-name provenance. |
| `Notion_backup/` | 0 | 0 | Removed by owner; no longer required by verifier. |

## Removed Backup Decision

The previous `Notion_backup/` zip was archive-only. Its contents matched the Markdown export by Markdown file count and shared file sizes, except for a root filename prefix difference, and it did not include helper export artifacts.

Now that the GDD source has moved to `docs/game_design_document/`, the backup is no longer part of the repo contract.

## Removed Merged Text Decision

The previous root `merged_gdd.txt` duplicated source Markdown for broad keyword discovery. Its search role now lives in the generated `docs/index/GDD_SOURCE_INDEX.md` full-text snapshot, so the standalone root file is no longer part of the repo contract.

## Keep

- `docs/game_design_document/`: main source surface.
- `docs/index/GDD_SOURCE_INDEX.md`: broad keyword search, quick review, and section map.
- `docs/index/`: generated structured source map and provenance.
- `docs/*.md`: standards, retention, structure review, and navigation decisions.

## Do Not Move Here

- Unreal project files.
- Implementation TODOs.
- QA-live specs for runtime systems.
- Normalized implementation design briefs.

Those belong in `F:\dev\infinite-worlds`.
