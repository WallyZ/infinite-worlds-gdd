# GDD Standards

## References Reviewed

These references were reviewed for general GDD expectations and template coverage:

- Nuclino Game Design Document template: `https://www.nuclino.com/templates/game-design-document`
- GameDeveloper design document guidance: `https://www.gamedeveloper.com/design/the-anatomy-of-a-design-document-part-1-documentation-guidelines-for-the-game-concept-and-proposal`
- Sloperama game design document examples and guidance: `https://www.sloperama.com/advice/specs.html`
- Game Dev Beginner GDD article: `https://gamedevbeginner.com/how-to-write-a-game-design-document-with-examples/`
- Milanote game design template page: `https://www.milanote.com/templates/game-design`

## Adopted Standards

The Infinite Worlds GDD should optimize for source fidelity, searchability, and low-context Codex use.

- Keep source pages in `docs/game_design_document/`.
- Keep implementation TODOs in `F:\dev\infinite-worlds`, not this repo.
- Preserve old export provenance in generated indexes instead of Notion IDs in filenames.
- Use parent-before-child filename sorting.
- Keep one canonical home for each concept, with cross-links for related topics.
- Do not merge or delete ideas without a curation note.

## Filename Standard

Markdown source files use:

```text
NN_NN_NN_NN_NN_NN_NN__kebab-case-title.md
```

Rules:

- Seven two-digit numeric slots are reserved for the deepest current hierarchy.
- Unused levels are `00`.
- Parent pages sort before children, for example `01_00_...` before `01_01_...`.
- The title slug is lowercase ASCII kebab-case.
- Notion export IDs do not appear in filenames.
- Old export names and source IDs are preserved in `docs/index/gdd_filename_migration.json`.
- When a source page is absorbed into a canonical parent, its migration entry should use `status: absorbed` and `absorbed_into` to point at the current canonical page.

Examples:

```text
01_00_00_00_00_00_00__game-overview.md
01_01_00_00_00_00_00__game-summary.md
01_01_01_00_00_00_00__elevator-marketing-pitch.md
```

## Heading Standard

Each source Markdown file should have one H1:

```text
# <section-number> <clear title>
```

Allowed top-level exception:

```text
# Game Design Document (GDD) Infinite Worlds
```

The filename section key and H1 section number must agree.

## Title And Content Fit Standard

Each source page should keep its H1, filename slug, and main body aligned:

- The H1 title should describe the page's actual topic.
- The filename slug should describe the same topic as the H1.
- Body content should either support the title directly or be treated as a stub/thin page needing expansion, absorption, or relocation review.
- Use `docs/index/GDD_DOCUMENT_FIT_AUDIT.md` to find title-only stubs, thin pages, and conservative title/content review candidates.

## Document Size And Splitting Standard

Use page size to reduce context load without scattering ideas too early:

- `0-75` body words: stub or index-only page. Expand it, absorb it into a parent, or mark why it should remain link-only.
- `150-350` body words: acceptable for a narrow concept, glossary-style note, or pure parent/index page with child links.
- `300-900` body words: target range for most atomic design pages.
- `900-1,500` body words: acceptable for broad parent concepts, system overviews, reference pages, or pages with tables.
- `1,500+` body words: review for splitting, but split only when the sections can stand alone and will be searched or implemented separately.

Split a page only when it contains two or more durable topics with different owners, implementation surfaces, test harnesses, or TODO lanes. Do not split just to make a weak page look organized. Expand weak content first, then split only when the page has enough substance to justify independent children.

Implementation-relevant GDD pages should include enough mapping cues for the game repo:

- likely runtime system or feature area
- likely prototype or harness
- related implementation TODO lane in `F:\dev\infinite-worlds`
- unresolved questions that need design or prototype evidence

## Parent Link Standard

Every page with direct subdocuments should link those direct child pages from the parent page.

- Existing contextual links count when they point to the direct child file.
- When a parent is missing child links, add or update a generated `## Subdocuments` block.
- The generated child-link block is bounded by `GDD_CHILD_LINKS_BEGIN` and `GDD_CHILD_LINKS_END` comments so future scripts can refresh it without disturbing the rest of the page.
- `.\scripts\codex-verify.ps1` enforces that no parent page is missing direct child links.

## Markdown Format Standard

This repo imports the dependency-free Markdown guard from `F:\dev\00-repo-kit`.

Markdown files must:

- use UTF-8 text
- have no trailing whitespace outside fenced code blocks
- use spaces instead of tabs outside fenced code blocks
- end with a final newline
- have balanced fenced code blocks
- have terminated YAML frontmatter when frontmatter is present

Run the formatter before committing broad Markdown edits:

```powershell
python .\scripts\markdown_format_guard.py --fix README.md AGENTS.md docs
```

The verifier runs the same guard in check mode through `.\scripts\codex-verify.ps1`.

## Content Standard For Curated Pages

When source pages are promoted from raw export material into curated GDD pages, they should answer:

- Purpose: what this page is for.
- Player experience: what the player should feel or do.
- System rules: concrete mechanics, constraints, and state.
- Dependencies: related systems, assets, tools, or implementation surfaces.
- MVP scope: the smallest version worth building or testing.
- Open questions: unresolved choices that need design or prototype evidence.

## Section Taxonomy Standard

Use the current source hierarchy as a source archive, but use `docs/GDD_TARGET_STRUCTURE.md` as the target structure when creating curated or reorganized pages.

Target taxonomy:

| Canonical Area | Purpose |
| --- | --- |
| Design Control and Product Vision | Pitch, pillars, audience, platform goals, scope rules, source-of-truth rules. |
| Player Handbook | Player experience, core loop, movement, controls, onboarding, progression, accessibility, VR comfort. |
| Systems Compendium | Combat, stealth, inventory, equipment, crafting, building, magic, psionics, rituals, survival mechanics. |
| World and Simulation Guide | World generation, biomes, time, weather, ecology, civilization, economy, persistence, terrain. |
| Bestiary, NPC, and Faction Codex | Creature roles, enemy types, species data, NPC behavior, relationships, factions, dialogue, companion systems. |
| Narrative and Lore Bible | Themes, mythology, history, emergent story, quests, player legacy, religions, symbolic systems. |
| Art, Audio, UI, and UX Bible | Visual direction, audio direction, VFX, interface, diegetic UX, accessibility presentation, asset naming and style guides. |
| Technical, Tooling, and QA Bible | Unreal architecture, data model, networking, persistence, automation, generated assets, QA, debug tools, modding, performance. |
| Production, Community, and Publishing Plan | Roadmap, milestones, funding, community, storefronts, marketing, localization, risk management. |
| Appendices and Reference | Glossary, tables, formulas, diagrams, example seeds, source citations, index-only reference material. |

## Review Standard

Every structural cleanup should record:

- pages moved or merged
- old section numbers
- new section numbers
- reason for the move
- whether implementation TODOs need updates in `F:\dev\infinite-worlds`
