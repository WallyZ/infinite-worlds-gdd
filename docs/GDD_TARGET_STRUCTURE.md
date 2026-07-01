# GDD Target Structure

## Purpose

This document defines the target organization for curated Infinite Worlds GDD material.

The source archive remains `docs/game_design_document/`. Do not mass-move source pages during audit work. Use this target structure when promoting, merging, renumbering, or rewriting source pages into curated design documents.

## RPG Book Structure Review

The current source organization was partly modeled on role-playing game books, and that is a good instinct for Infinite Worlds. RPG books are useful because they are reference-first: readers can jump to character rules, combat, equipment, magic, world lore, bestiary entries, GM guidance, and appendices without reading linearly.

What to adopt:

- Separate player-facing rules from designer/GM/simulation guidance.
- Keep stable chapter numbers and descriptive headings.
- Put reusable tables, entity lists, diagrams, and formulas in appendices or codices.
- Give each concept one canonical home, then cross-link related chapters.
- Preserve a glossary and index because the setting and simulation vocabulary will grow.

What not to copy directly:

- Do not scatter the same rule across multiple "supplement" style chapters.
- Do not bury implementation architecture inside player-facing rules.
- Do not let lore, mechanics, art direction, QA, and production planning share one chapter just because they mention the same subject.
- Do not keep empty leaf pages as standalone curated pages unless they carry real design decisions.

## Target Library

| Code | Curated Book | Owns | Current Source Inputs |
| --- | --- | --- | --- |
| `00` | Design Control and Product Vision | Pitch, pillars, audience, platform goals, scope rules, source-of-truth rules. | Sections `0`, `1`, selected `14`. |
| `01` | Player Handbook | Player experience, core loop, movement, controls, onboarding, progression, accessibility, VR comfort. | Sections `2`, `10`, `13`, selected `1`. |
| `02` | Systems Compendium | Combat, stealth, inventory, equipment, crafting, building, magic, psionics, rituals, survival mechanics. | Sections `4`, `5`, `6`, selected `2`, `10`, `15`. |
| `03` | World and Simulation Guide | World generation, biomes, time, weather, ecology, civilization, economy, persistence, terrain, planar effects as simulation. | Section `3`, selected `11`, selected `15`. |
| `04` | Bestiary, NPC, and Faction Codex | Creature roles, enemy types, species data, NPC behavior, relationships, factions, dialogue, companion systems. | Sections `3`, `5`, `7`, selected `9`, selected `15`. |
| `05` | Narrative and Lore Bible | Themes, mythology, history, emergent story, quests, player legacy, religions, symbolic systems, story tools. | Section `9`, selected `1`, `3`, `4`, `7`, `15`. |
| `06` | Art, Audio, UI, and UX Bible | Visual direction, audio direction, VFX, interface, diegetic UX, accessibility presentation, asset naming and style guides. | Sections `8`, `10`, selected `13`, selected `15`. |
| `07` | Technical, Tooling, and QA Bible | Unreal architecture, data model, networking, persistence, automation, generated assets, QA, debug tools, modding, performance. | Section `11`, selected `14`, selected implementation notes from other sections. |
| `08` | Production, Community, and Publishing Plan | Roadmap, milestones, funding, community, storefronts, marketing, localization, risk management. | Sections `12`, `14`. |
| `09` | Appendices and Reference | Glossary, tables, formulas, diagrams, example seeds, source citations, index-only reference material. | Section `15`, table/database content from all sections. |

## Best Structure Assessment

Use a two-layer organization:

1. Source archive: `docs/game_design_document/` remains the full export-derived evidence set.
2. Curated library: future curated pages should follow the target library above.

This keeps Codex efficient: broad search starts in generated indexes, source verification stays stable, and curated work can happen book-by-book without losing provenance.

The RPG-book model should be retained for player-facing and reference-heavy material, but technical, art, QA, and production material need their own books. That avoids the biggest current problem: a subject like magic, AI, accessibility, or factions appears in gameplay, lore, art, tech, and appendices with no clear owner.

## Canonical Ownership Rules

- Player-facing behavior belongs in `01 Player Handbook`.
- Detailed mechanics and tunable rules belong in `02 Systems Compendium`.
- Simulation state and autonomous world behavior belong in `03 World and Simulation Guide`.
- Entities, creatures, NPC psychology, factions, and relationship behavior belong in `04 Bestiary, NPC, and Faction Codex`.
- Story meaning, world history, myths, quest logic, and symbolic interpretation belong in `05 Narrative and Lore Bible`.
- Presentation, visual/audio feedback, UI, and usability presentation belong in `06 Art, Audio, UI, and UX Bible`.
- Engine architecture, automation, QA, data, and performance belong in `07 Technical, Tooling, and QA Bible`.
- Publishing, funding, community, marketing, and milestones belong in `08 Production, Community, and Publishing Plan`.
- Tables, diagrams, formulas, and pure reference artifacts belong in `09 Appendices and Reference`, unless they are the primary design for a system.

## High-Priority Reorganization Lanes

1. Numbering repair: fix the 12 duplicate section numbers and the orphaned `2.1.2.13.1.1` branch before any larger moves.
2. Stub handling: review pages under 20 words first; absorb empty concept labels into parent pages unless they need real design expansion.
3. Accessibility consolidation: make `01 Player Handbook` the canonical owner for accessibility and comfort rules, with presentation details cross-linked to `06 Art, Audio, UI, and UX Bible`.
4. Magic consolidation: keep magic/psionics/ritual mechanics in `02 Systems Compendium`, supernatural metaphysics in `05 Narrative and Lore Bible`, VFX in `06 Art, Audio, UI, and UX Bible`, and implementation architecture in `07 Technical, Tooling, and QA Bible`.
5. AI and narrative split: put behavior, memory, dialogue systems, factions, and companions in `04 Bestiary, NPC, and Faction Codex`; put emergent story meaning and quest/narrative tools in `05 Narrative and Lore Bible`.
6. Production consolidation: merge community, monetization, publishing, roadmap, and risk material into `08 Production, Community, and Publishing Plan`.
7. Appendix cleanup: keep appendices as reference, not as a dumping ground for underdeveloped design decisions.

## Future Curated File Naming

When curated pages are introduced, use a separate curated area instead of renaming the source archive:

```text
docs/curated/
  00_design_control/
  01_player_handbook/
  02_systems_compendium/
  03_world_simulation_guide/
  04_bestiary_npc_faction_codex/
  05_narrative_lore_bible/
  06_art_audio_ui_ux_bible/
  07_technical_tooling_qa_bible/
  08_production_community_publishing/
  09_appendices_reference/
```

Curated pages should include a short provenance block listing source files consumed or superseded. Do not delete source pages until the curation decision records where the idea moved.

## Indexes To Use

- `docs/index/GDD_SOURCE_INDEX.md`: full-text search and source section lookup.
- `docs/index/GDD_CONTENT_AUDIT.md`: human-readable audit of organization, duplication, stubs, incomplete pages, and merge/remove candidates.
- `docs/index/gdd_content_audit.json`: structured audit for future tooling.
