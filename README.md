# Infinite Worlds GDD Source

Private source repository for the Infinite Worlds game design document exports.

## Purpose

This repo preserves the raw and merged GDD source material separately from the Unreal game repo at `F:\dev\infinite-worlds`.

Keep this repo focused on source provenance:

- sortable GDD source Markdown files
- merged text exports
- source images included with the export
- minimal scripts/docs needed to verify the source package

Canonical implementation plans, normalized design briefs, QA specs, and Unreal project files belong in `F:\dev\infinite-worlds`.

## Layout

- `docs/game_design_document/`: authoritative GDD source files with sortable names.
- `merged_gdd.txt`: merged text export for search/review.
- `docs/CODEX_GDD_NAVIGATION.md`: smallest practical starting point for Codex work.
- `docs/GDD_ORGANIZATION.md`: source surfaces, ownership rules, and desired layout.
- `docs/GDD_RETENTION_REVIEW.md`: current keep/remove assessment for source material.
- `docs/GDD_STANDARDS.md`: adopted GDD naming, numbering, and curation standards.
- `docs/GDD_STRUCTURE_REVIEW.md`: current redundancy, numbering, and overlap findings.
- `docs/index/GDD_SOURCE_INDEX.md`: generated section index for fast source lookup.
- `docs/index/gdd_source_index.json`: structured source index for scripts/tools.
- `docs/index/gdd_filename_migration.json`: old export filenames mapped to current source names.
- `scripts/build-gdd-index.ps1`: regenerates or checks the source index.
- `scripts/codex-verify.ps1`: source package verification.

## Codex Search Workflow

Start with:

```powershell
Get-Content .\docs\CODEX_GDD_NAVIGATION.md
```

Then use `docs/index/GDD_SOURCE_INDEX.md` to identify the smallest relevant source files. Use `merged_gdd.txt` only for broad keyword discovery.

## Verification

Use:

```powershell
.\scripts\codex-verify.ps1
```

The verifier checks that expected source folders/files exist, Markdown filenames follow the repo standard, generated indexes are fresh, and logs are written under `.codex-cache\logs\`.
