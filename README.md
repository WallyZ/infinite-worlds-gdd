# Infinite Worlds GDD Source

Private source repository for the Infinite Worlds game design document exports.

## Purpose

This repo preserves the GDD source material separately from the Unreal game repo at `F:\dev\infinite-worlds`.

Keep this repo focused on source provenance:

- sortable GDD source Markdown files
- generated indexes and a full-text search snapshot
- source images included with the export
- minimal scripts/docs needed to verify the source package

Canonical implementation plans, normalized design briefs, QA specs, and Unreal project files belong in `F:\dev\infinite-worlds`.

## Layout

- `docs/game_design_document/`: authoritative GDD source files with sortable names.
- `docs/CODEX_GDD_NAVIGATION.md`: smallest practical starting point for Codex work.
- `docs/GDD_ORGANIZATION.md`: source surfaces, ownership rules, and desired layout.
- `docs/GDD_RETENTION_REVIEW.md`: current keep/remove assessment for source material.
- `docs/GDD_STANDARDS.md`: adopted GDD naming, numbering, and curation standards.
- `docs/GDD_TARGET_STRUCTURE.md`: RPG-book-informed target structure for curated GDD material.
- `docs/GDD_STRUCTURE_REVIEW.md`: current redundancy, numbering, and overlap findings.
- `docs/index/GDD_SOURCE_INDEX.md`: generated section index and full-text search snapshot.
- `docs/index/GDD_CONTENT_AUDIT.md`: generated content audit for duplication, incomplete pages, merge/remove review, and target-area mapping.
- `docs/index/gdd_source_index.json`: structured source index for scripts/tools.
- `docs/index/gdd_content_audit.json`: structured content audit for scripts/tools.
- `docs/index/gdd_filename_migration.json`: old export filenames mapped to current source names.
- `scripts/build-gdd-index.ps1`: regenerates or checks the source index.
- `scripts/build-gdd-content-audit.ps1`: regenerates or checks the content audit.
- `scripts/markdown_format_guard.py`: repo-kit Markdown whitespace/fence/frontmatter guard.
- `scripts/codex-verify.ps1`: source package verification.

## Codex Search Workflow

Start with:

```powershell
Get-Content .\docs\CODEX_GDD_NAVIGATION.md
```

Then use `docs/index/GDD_SOURCE_INDEX.md` for broad keyword discovery, `docs/index/GDD_CONTENT_AUDIT.md` for curation candidates, and `docs/GDD_TARGET_STRUCTURE.md` for the target curated organization.

## Verification

Use:

```powershell
.\scripts\codex-verify.ps1
```

The verifier checks that expected source folders/files exist, Markdown formatting follows the repo-kit guard, Markdown filenames follow the repo standard, generated indexes and audits are fresh, the legacy root `merged_gdd.txt` file is absent, and logs are written under `.codex-cache\logs\`.
