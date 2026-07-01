# Codex GDD Navigation

This repo is the Infinite Worlds GDD source repository. Use this file first so Codex can work from a compact map before opening the full source set.

## Fast Path

1. Read `README.md` for repo purpose.
2. Read `docs/GDD_STANDARDS.md` for naming, numbering, and curation rules.
3. Read `docs/GDD_TARGET_STRUCTURE.md` before reorganizing content.
4. Use `docs/index/GDD_SOURCE_INDEX.md` for broad keyword discovery and to find the smallest relevant source files.
5. Use `docs/index/GDD_CONTENT_AUDIT.md` to find duplicate, incomplete, merge, removal, and target-area candidates.
6. Open files in `docs/game_design_document/` after narrowing the question to a section or topic.

## Search Surfaces

- `docs/index/GDD_SOURCE_INDEX.md`: generated table of contents plus full-text source snapshot for keyword search.
- `docs/index/GDD_CONTENT_AUDIT.md`: generated content audit for organization, duplication, stubs, overlap, and merge/remove review.
- `docs/index/gdd_source_index.json`: structured version of the same index for scripts and tooling.
- `docs/index/gdd_content_audit.json`: structured content audit for scripts and future curation tooling.
- `docs/index/gdd_filename_migration.json`: old Notion export names mapped to current sortable names.
- `docs/game_design_document/`: authoritative working Markdown source set.

## Section Map

- `0`: root GDD table of contents.
- `1`: game overview, pitch, vision, player goals, influences.
- `2`: core gameplay systems.
- `3`: simulation and world systems.
- `4`: magic, psionics, rituals.
- `5`: combat, detection, stealth.
- `6`: crafting, construction, settlement.
- `7`: artificial intelligence, NPCs, relationships.
- `8`: art and visual design.
- `9`: narrative and emergent storytelling.
- `10`: UI, UX, immersion.
- `11`: technical implementation.
- `12`: community and monetization.
- `13`: accessibility and UX.
- `14`: project management and publishing.
- `15`: appendices and references.

## Working Rules

- Keep source files under `docs/game_design_document/`.
- Preserve provenance through `docs/index/gdd_filename_migration.json`.
- Use `docs/GDD_TARGET_STRUCTURE.md` as the curated library target.
- Do not put Unreal implementation TODOs in this repo; those belong in `F:\dev\infinite-worlds`.
- Regenerate indexes with `.\scripts\build-gdd-index.ps1` and `.\scripts\build-gdd-content-audit.ps1` after source files change.
- Use `.\scripts\codex-verify.ps1` before committing GDD repo changes.
