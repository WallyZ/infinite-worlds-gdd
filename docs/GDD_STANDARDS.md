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

## Content Standard For Curated Pages

When source pages are promoted from raw export material into curated GDD pages, they should answer:

- Purpose: what this page is for.
- Player experience: what the player should feel or do.
- System rules: concrete mechanics, constraints, and state.
- Dependencies: related systems, assets, tools, or implementation surfaces.
- MVP scope: the smallest version worth building or testing.
- Open questions: unresolved choices that need design or prototype evidence.

## Section Taxonomy Standard

Use the current source hierarchy as a source archive, but use this target taxonomy when creating curated or reorganized pages:

| Canonical Area | Purpose |
| --- | --- |
| Overview and pillars | Pitch, vision, audience, platforms, pillars. |
| Player experience | Core loop, progression, onboarding, comfort, accessibility. |
| Gameplay systems | Interaction, inventory, skills, combat, crafting, magic. |
| World simulation | Biomes, time, weather, ecology, PCG, persistence. |
| AI and social simulation | NPC cognition, routines, factions, relationships, dialogue. |
| Narrative and lore | world history, themes, quests, emergent story, player legacy. |
| Art, audio, UI, UX | Visual direction, sound, interface, feedback, accessibility presentation. |
| Technical and tooling | Engine, architecture, data, networking, save, automation, QA. |
| Production and community | roadmap, publishing, community, monetization, marketing. |
| Appendix/reference | Glossary, tables, diagrams, examples, citations. |

## Review Standard

Every structural cleanup should record:

- pages moved or merged
- old section numbers
- new section numbers
- reason for the move
- whether implementation TODOs need updates in `F:\dev\infinite-worlds`
