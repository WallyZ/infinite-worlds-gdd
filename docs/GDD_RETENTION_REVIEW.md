# GDD Retention Review

## Current Inventory

Observed on 2026-07-01:

| Surface | Files | Bytes | Decision |
| --- | ---: | ---: | --- |
| `markdown_export/` | 666 | 5,782,983 | Keep as working source export. |
| `Notion_backup/` | 1 | 5,450,891 | Archive-only; candidate for later removal. |
| `merged_gdd.txt` | 1 | 855,746 | Keep as lightweight full-text search aggregate. |

## Notion Backup Comparison

`Notion_backup/` contains one zip:

`1a215901-5fc5-4268-a48f-0c04648c75cc_Export-f49257be-d289-4ccb-9b7c-0f21e91fc50d.zip`

The zip contains:

- 658 Markdown files
- 3 PNG files
- 1 C++ file
- 1 text file

Comparison against `markdown_export/`:

- Markdown counts match: 658 zip Markdown files and 658 export Markdown files.
- Shared file sizes match.
- The zip has `Game Design Document (GDD) Infinite Worlds ... .md`.
- `markdown_export/` has the same root file with a `0 ` prefix.
- `markdown_export/` also contains `check_path.py`, `merge_files.py`, and `visited.json`, which are not in the zip.

## Keep

- `markdown_export/`: main raw source surface.
- `merged_gdd.txt`: broad keyword search and quick review.
- `docs/index/`: generated search map for Codex.
- `docs/*.md`: retention and navigation decisions.

## Candidate Remove

- `Notion_backup/`: remove only after confirming that Git history or another off-machine backup is enough for the original zip.

## Do Not Move Here

- Unreal project files.
- Implementation TODOs.
- QA-live specs for runtime systems.
- Normalized design briefs that are meant to drive active development.

Those belong in `F:\dev\infinite-worlds`.
