# GDD Structure Review

## Summary

The source set is now easier to search, but the conceptual structure still needs curation.

Current findings:

- 658 Markdown source pages.
- Maximum hierarchy depth: 7.
- 12 duplicate section numbers.
- 1 orphaned section.
- 287 very small pages with 20 words or fewer.

## Numbering Issues

Duplicate section numbers:

| Section | Titles |
| --- | --- |
| `3.4.5` | NPC & Faction Reactions to Contagion; Treatments: Alchemy, Rituals, Herbs, Surgery |
| `3.12.1` | Cave Systems, Ancient Ruins & Tectonics; World Persists Without Player Input |
| `3.12.2` | Fungal, Crystalline & Subterranean Life; Systems Interact Autonomously |
| `3.12.3` | Server/Local Performance & Memory Optimization; Underworld Physics & Mythic Layers |
| `8.1.1` | Core Themes & Emotional Pillars; Visual Tone & World Mood |
| `8.1.2` | Color Palette; Key Visual References |
| `8.1.3` | Visual Tone & Art Style; VR Aesthetic Design Considerations |
| `8.7` | Iconography, Fonts & Symbol Systems; Procedural & AI Tools Summary |
| `8.7.1` | Magic & Spell VFX; Procedural Tools Used |
| `8.7.2` | AI-Enhanced Design Tools; Planar/Anomalous Effects |
| `8.7.3` | Atmosphere & Emotion; Texture & Material Authoring |
| `12.8` | AI-Powered Lore Expansion Toolkits; Substack |

Orphaned section:

| Section | Missing Parent | File |
| --- | --- | --- |
| `2.1.2.13.1.1` | `2.1.2.13.1` | `02_01_02_13_01_01_00__blueprint-and-c-plus-plus.md` |

## Overlap Candidates

These areas should be reviewed before changing section numbers:

- Accessibility appears in section `13`, UI/UX section `10`, visual design section `8`, and appendix section `15`.
- AI, NPC relationships, dialogue, companion story, and emergent narrative overlap across sections `7` and `9`.
- Magic, psionics, ritual systems, magic tables, and psionics inspiration overlap across sections `4`, `5`, `6`, and `15`.
- Technical implementation and gameplay integration overlap between sections `2`, `3`, `7`, and `11`.
- Art, VFX, audio, UI, and generated asset tooling overlap across sections `8`, `10`, `11`, and `15`.
- Community, monetization, publishing, and roadmap material is split between sections `12` and `14`.

## Recommended Curation Order

1. Fix duplicate section numbers without moving concepts.
2. Resolve the orphaned `2.1.2.13.1.1` branch.
3. Merge or annotate pages with 20 words or fewer.
4. Decide canonical homes for accessibility, AI/social simulation, magic/psionics, technical implementation, and production/community.
5. Create curated summary pages for the canonical taxonomy in `docs/GDD_STANDARDS.md`.

## Do Not Do Automatically

- Do not merge design pages solely because titles are similar.
- Do not delete tiny pages until their parent page has absorbed or explicitly rejected the idea.
- Do not rewrite implementation tasks in this repo; create or update TODOs in `F:\dev\infinite-worlds`.
