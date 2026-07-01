# Codex GDD Navigation

This repo is a source archive, not the implementation backlog. Use this file first to keep context small when working with the large GDD export.

## Fast Path

1. Read `README.md` for repo purpose.
2. Read `docs/GDD_ORGANIZATION.md` for source surfaces and ownership rules.
3. Use `docs/index/GDD_SOURCE_INDEX.md` to find the smallest relevant source files.
4. Use `merged_gdd.txt` for broad keyword search when the index is not enough.
5. Open files in `markdown_export/` only after narrowing the question to a section or topic.

## Search Surfaces

- `docs/index/GDD_SOURCE_INDEX.md`: compact, generated table of contents by source section.
- `docs/index/gdd_source_index.json`: structured version of the same index for scripts and tooling.
- `merged_gdd.txt`: full-text aggregate for keyword search across the export.
- `markdown_export/`: authoritative working Markdown export.
- `Notion_backup/`: archive-only zip; not a normal search surface.

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

- Keep raw export filenames stable so links and provenance remain valid.
- Put implementation TODOs and normalized design briefs in `F:\dev\infinite-worlds`, not here.
- Add curation notes under `docs/` when they help navigation or retention decisions.
- Regenerate the index with `.\scripts\build-gdd-index.ps1` after source files change.
