# Infinite Worlds GDD Source

Private source repository for the Infinite Worlds game design document exports.

## Purpose

This repo preserves the raw and merged GDD source material separately from the Unreal game repo at `F:\dev\infinite-worlds`.

Keep this repo focused on source provenance:

- raw Notion export files
- Markdown export files
- merged text exports
- source images included with the export
- minimal scripts/docs needed to verify the source package

Canonical implementation plans, normalized design briefs, QA specs, and Unreal project files belong in `F:\dev\infinite-worlds`.

## Layout

- `markdown_export/`: Notion-style Markdown export and linked media/code snippets.
- `Notion_backup/`: original Notion backup material; archive-only and not the normal search surface.
- `merged_gdd.txt`: merged text export for search/review.
- `docs/CODEX_GDD_NAVIGATION.md`: smallest practical starting point for Codex work.
- `docs/GDD_ORGANIZATION.md`: source surfaces, ownership rules, and desired layout.
- `docs/GDD_RETENTION_REVIEW.md`: current keep/remove assessment for source material.
- `docs/index/GDD_SOURCE_INDEX.md`: generated section index for fast source lookup.
- `docs/index/gdd_source_index.json`: structured source index for scripts/tools.
- `scripts/build-gdd-index.ps1`: regenerates or checks the source index.
- `scripts/codex-verify.ps1`: source package verification.

## Codex Search Workflow

Start with:

```powershell
Get-Content .\docs\CODEX_GDD_NAVIGATION.md
```

Then use `docs/index/GDD_SOURCE_INDEX.md` to identify the smallest relevant raw Markdown files. Use `merged_gdd.txt` only for broad keyword discovery.

## Verification

Use:

```powershell
.\scripts\codex-verify.ps1
```

The verifier checks that the expected source folders/files exist, that Markdown files are present, and that verification logs are written under `.codex-cache\logs\`.
