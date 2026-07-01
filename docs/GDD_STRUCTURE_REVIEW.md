# GDD Structure Review

## Summary

The source set is now easier to search, but the conceptual structure still needs curation.

For the current generated audit, use `docs/index/GDD_CONTENT_AUDIT.md`.

Current findings:

- 648 Markdown source pages.
- Maximum hierarchy depth: 7.
- 0 duplicate section numbers after the first duplicate-number cleanup pass.
- 0 orphaned sections after the `2.1.2.13.1.1` branch was rehomed under `11.2.3`.
- 280 very small pages with 20 words or fewer.

## Numbering Issues

Resolved duplicate section numbers:

| Old Section | Decision |
| --- | --- |
| `3.4.5` | Absorbed the two heading-only disease treatment and contagion-response stubs into `3.4 Disease, Poison & Afflictions`. |
| `3.12.1` - `3.12.3` | Absorbed heading-only persistent-simulation stubs into `3.12 Persistent World Simulation`; rehomed distinct Underworld children under `3.13.1` - `3.13.5`. |
| `8.1.1` - `8.1.3` | Absorbed visual mood, references, and VR aesthetic notes into `8.1.3 Visual Tone & Art Style`. |
| `8.7` | Absorbed the redundant iconography/fonts stub into `8.1.4 Iconography & Symbol Language`; kept `8.7 Procedural & AI Tools Summary` as the canonical art-tooling/VFX parent. |
| `8.7.1` | Absorbed the procedural-tools stub into `8.4 Environment Design & Procedural Tools`; kept `8.7.1 Magic & Spell VFX`. |
| `8.7.2` - `8.7.3` | Kept the distinct VFX pages at `8.7.2` and `8.7.3`; rehomed AI-enhanced design tools to `8.7.5` and texture/material authoring to `8.7.6`. |
| `12.8` | Kept `12.8 AI-Powered Lore Expansion Toolkits`; rehomed the full Substack page under `12.6.7 Marketing & Outreach`. |

Resolved orphaned section:

| Old Section | New Section | Decision |
| --- | --- | --- |
| `2.1.2.13.1.1` | `11.2.3.1` | Rehomed as `Ethereal Phasing and Visibility System`, because the content is a full Unreal Blueprint/C++ implementation note for ghost-phase and plane visibility. |
| `2.1.2.13.1.1.1` | `11.2.3.1.1` | Rehomed as the ghost NPC setup child page under the same technical system. |

This is not a duplicate of `3.10.5 Ethereal Plane`: that page owns world, lore, simulation, and player-facing design, while `11.2.3` owns implementation architecture and testing.

## Overlap Candidates

These areas should be reviewed before changing section numbers:

- Accessibility appears in section `13`, UI/UX section `10`, visual design section `8`, and appendix section `15`.
- AI, NPC relationships, dialogue, companion story, and emergent narrative overlap across sections `7` and `9`.
- Magic, psionics, ritual systems, magic tables, and psionics inspiration overlap across sections `4`, `5`, `6`, and `15`.
- Technical implementation and gameplay integration overlap between sections `2`, `3`, `7`, and `11`.
- Art, VFX, audio, UI, and generated asset tooling overlap across sections `8`, `10`, `11`, and `15`.
- Community, monetization, publishing, and roadmap material is split between sections `12` and `14`.

## Recommended Curation Order

1. Merge or annotate pages with 20 words or fewer.
2. Decide canonical homes for accessibility, AI/social simulation, magic/psionics, technical implementation, and production/community.
3. Consolidate duplicate title groups and similar-title candidates.
4. Create curated summary pages for the canonical taxonomy in `docs/GDD_STANDARDS.md`.

## Do Not Do Automatically

- Do not merge design pages solely because titles are similar.
- Do not delete tiny pages until their parent page has absorbed or explicitly rejected the idea.
- Do not rewrite implementation tasks in this repo; create or update TODOs in `F:\dev\infinite-worlds`.
