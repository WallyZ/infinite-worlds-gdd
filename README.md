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
- `Notion_backup/`: original Notion backup material.
- `merged_gdd.txt`: merged text export for search/review.
- `scripts/codex-verify.ps1`: source package verification.

## Verification

Use:

```powershell
.\scripts\codex-verify.ps1
```

The verifier checks that the expected source folders/files exist, that Markdown files are present, and that verification logs are written under `.codex-cache\logs\`.
