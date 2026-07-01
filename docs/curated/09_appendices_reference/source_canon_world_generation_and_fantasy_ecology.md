# Source Canon: World Generation And Fantasy Ecology

## Purpose

This curated appendix collects sources that can inform Infinite Worlds world generation, natural-process simulation, biome/ecology rules, and fantasy-system overlays.

Use this page as a starting source canon, not as a permission to import external data. Before copying data, tables, text, images, names, or rules into the game, verify the source license and record the exact dataset/version used.

## Use Rules

- Prefer official, academic, public-domain, open-data, or clearly licensed sources.
- Use sources to derive generator variables, constraints, and validation checks instead of copying surface flavor.
- Natural systems should be modeled first. Fantasy elements should usually modify, stress, amplify, or bend those systems instead of replacing them with arbitrary exceptions.
- Source-backed implementation tasks belong in `F:\dev\infinite-worlds`; this GDD repo keeps source context and curation notes.
- When a source affects implementation, map it in `F:\dev\infinite-worlds\docs\design\GDD_TO_TODO_MAP.md`.

## Worldgen Model To Build Toward

1. Planet skeleton: seed, scale, rotation assumptions, oceans, continents, and broad plate-like boundaries.
2. Tectonics and terrain: mountain chains, rifts, basins, volcanic arcs, caves, mineral regions, and erosion tendencies.
3. Water systems: ocean exposure, prevailing winds, rainfall, watersheds, rivers, lakes, wetlands, coasts, aquifers, and floods.
4. Climate and biomes: latitude, altitude, temperature, precipitation, seasonality, rain shadows, soil, disturbance, and local modifiers.
5. Ecology: plant communities, herbivores, predators, decomposers, parasites, disease pressure, succession, competition, and migration.
6. Evolution and adaptation: traits emerge from habitat pressure, diet, reproduction, predation, isolation, convergence, and mutation rate.
7. Culture and settlement: people settle near water, food, trade routes, defensible terrain, sacred places, resources, hazards, and political pressure.
8. Fantasy overlay: magic, planar influence, divine/cosmic events, curses, ancient ruins, and sentient forces become explicit fields or rules that interact with the natural model.

## Natural Process Source Map

| Domain | Sources | Use In Infinite Worlds |
| --- | --- | --- |
| Plate tectonics and geologic structure | [USGS: This Dynamic Earth](https://pubs.usgs.gov/gip/dynamic/dynamic.html); [USGS Earthquake Hazards: Plate Tectonics](https://www.usgs.gov/programs/earthquake-hazards/plate-tectonics); [OneGeology Portal](https://portal.onegeology.org/) | Plate-lite continent layout, mountain/rift/volcanic rules, mineral regions, cave/ruin placement, tectonic hazard tags. |
| Terrain and elevation references | [NASA Earthdata SRTM](https://www.earthdata.nasa.gov/data/instruments/srtm); [Natural Earth](https://www.naturalearthdata.com/); [GEBCO](https://www.gebco.net/) | Heightfield inspiration, landform categories, coast/ocean basin references, map debug layers. |
| Hydrology and water cycle | [USGS Water Science School](https://www.usgs.gov/special-topics/water-science-school); [HydroSHEDS](https://www.hydrosheds.org/); [NOAA JetStream](https://www.weather.gov/jetstream/) | Watershed generation, river/lake/wetland rules, floodplains, erosion pressure, water availability for settlements and biomes. |
| Weather, climate, and atmospheric circulation | [NOAA Climate.gov](https://www.climate.gov/); [NASA Earth Observatory](https://earthobservatory.nasa.gov/); [UCAR Center for Science Education](https://scied.ucar.edu/) | Prevailing winds, rain shadows, seasonal shifts, storm tracks, climate debug views, weather test harness expectations. |
| Climate classification and climate data | [Koppen-Geiger Climate Classification Maps](https://www.gloh2o.org/koppen/); [WorldClim](https://www.worldclim.org/) | Biome thresholds, climate envelopes, temperature/precipitation bands, source-backed biome table ranges. |
| Biomes and ecoregions | [WWF Terrestrial Ecoregions of the World](https://www.worldwildlife.org/publications/terrestrial-ecoregions-of-the-world); [EPA Ecoregions](https://www.epa.gov/eco-research/ecoregions); [FAO Global Ecological Zones](https://www.fao.org/forest-resources-assessment/remote-sensing/global-ecological-zones-gez-mapping/en/) | Biome families, ecotones, edge blending, region tags, reference categories for generated codex output. |
| Soil and substrate | [SoilGrids](https://soilgrids.org/); [USDA NRCS Soils](https://www.nrcs.usda.gov/conservation-basics/natural-resource-concerns/soils) | Plant suitability, crop/foraging potential, erosion, construction materials, underground resource modifiers. |
| Biodiversity and species distributions | [GBIF](https://www.gbif.org/); [World Flora Online](https://www.worldfloraonline.org/); [IUCN Red List](https://www.iucnredlist.org/) | Species-range inspiration, plant/creature habitat tags, rarity, invasive pressure, conservation-style world-state signals. |
| Ecology and evolution fundamentals | [OpenStax Biology 2e](https://openstax.org/details/books/biology-2e); [UC Berkeley Understanding Evolution](https://evolution.berkeley.edu/) | Food webs, succession, selection pressure, adaptation, convergent evolution, mutation, population dynamics. |
| Procedural map generation | [Red Blob Games: Map Generation](https://www.redblobgames.com/maps/mapgen2/); [Red Blob Games: Terrain From Noise](https://www.redblobgames.com/maps/terrain-from-noise/); [PCG Wiki](https://pcg.wikidot.com/) | Prototype algorithms, map-debug thinking, seed visualization, biome/terrain iteration tools. |
| Noise and generator implementation | [FastNoiseLite](https://github.com/Auburn/FastNoiseLite); [Unreal Engine PCG Framework](https://dev.epicgames.com/documentation/en-us/unreal-engine/procedural-content-generation-framework-in-unreal-engine) | Noise choices, deterministic generation experiments, Unreal PCG prototyping, content-validation targets. |

## Fantasy And Mythic Source Map

| Source Area | Sources | Use In Infinite Worlds |
| --- | --- | --- |
| Magic-system design principles | [Brandon Sanderson's Laws of Magic](https://faq.brandonsanderson.com/knowledge-base/what-are-sandersons-laws-of-magic/) | Consistency checks for hard/soft magic, cost, limitation, player understanding, and consequence. |
| Open fantasy rules taxonomy | [Dungeons & Dragons SRD](https://dnd.wizards.com/resources/systems-reference-document); [Basic Fantasy RPG Downloads](https://www.basicfantasy.org/downloads.html) | Broad fantasy category inspiration only. Do not copy protected setting identity, monsters, spells, or text without license review. |
| Public-domain myth and ritual | [Project Gutenberg: The Golden Bough](https://www.gutenberg.org/ebooks/3623); [Internet Sacred Text Archive](https://www.sacred-texts.com/); [Wikisource](https://en.wikisource.org/) | Ritual structure, taboo, sacrifice, omen systems, sacred sites, seasonal festivals, symbolic correspondences. |
| Mythology indexes and summaries | [Theoi Greek Mythology](https://www.theoi.com/); [World History Encyclopedia](https://www.worldhistory.org/) | Creature/archetype motifs, divine domains, legendary-place patterns, culture-specific inspiration checks. |
| Folklore and public-domain tales | [Open Folklore](https://openfolklore.org/); [Project Gutenberg: The Mabinogion](https://www.gutenberg.org/ebooks/5160); [Project Gutenberg: Le Morte d'Arthur](https://www.gutenberg.org/ebooks/1251); [Project Gutenberg: The Kalevala](https://www.gutenberg.org/ebooks/5186) | Quest motifs, enchanted landscapes, heroic cycles, curses, bargains, fae logic, mythic travel, legendary artifacts. |

## Fantasy Overlay Rules

- Magical biomes need a natural baseline, magical cause, visible symptoms, resource effects, creature effects, and recovery or spread rules.
- Magical resource nodes should be generated from geology, hydrology, celestial alignment, ruins, death/war history, planar fields, or repeated spell use.
- Planar influence should behave like a field with intensity, gradient, edge effects, periodicity, hazards, and entity adaptation.
- Fantastical creatures still need habitat logic: food source, shelter, reproduction or origin, predator/prey pressure, migration, and failure cases.
- Spellcasting consequences should update environmental fields: heat, pressure, contamination, growth, decay, weather instability, spirit attention, or social memory.
- Mythic content should be transformed into original systems and motifs, not imported as named real-world religions or copyrighted setting elements.

## Initial TODO Mapping

| Source Canon Area | GDD Source Owners | Game TODO Lane | First Implementation Artifact |
| --- | --- | --- | --- |
| Plate-lite terrain and geology | `3.1`, `3.13`, `15.5` | `TODO_11` | Worldgen layer brief for plate boundaries, elevation classes, mountains, rifts, caves, and mineral tags. |
| Climate, weather, and biomes | `3.1`, `3.2`, `15.4`, `15.5` | `TODO_11`, `TODO_15` | Biome table schema with latitude, altitude, temperature, precipitation, wind exposure, and rain-shadow inputs. |
| Ecology and evolution | `3.3`, `3.5`, `15.4` | `TODO_11`, `TODO_12` | Habitat/spawn-condition schema that can explain why a plant, creature, or faction appears in a region. |
| Fantasy ecology and magical anomalies | `3.9`, `3.10`, `4`, `15.8`, `15.13` | `TODO_11`, `TODO_13` | Magical field modifier schema for resource nodes, contamination zones, planar influence, and spellcasting blowback. |
| Provenance and validation | `15`, curated appendices | `TODO_09`, `TODO_11`, `TODO_16` | Source-reference field in generated world summaries and validation output. |

## Next GDD Curation Targets

Expand or curate these source pages next when working on world-generation depth:

- `03_01_01_00_00_00_00__procedural-terrain-and-seed-rules.md`
- `03_01_02_00_00_00_00__biome-diversity-and-composition-climate-altitude-terrain-types.md`
- `03_02_02_00_00_00_00__weather-climate-and-natural-disasters.md`
- `03_03_00_00_00_00_00__ecosystems-flora-fauna-microbes-and-food-webs.md`
- `03_03_05_00_00_00_00__mutation-evolution-and-adaptation.md`
- `03_09_00_00_00_00_00__magical-ecology-and-anomalies.md`
- `03_10_16_00_00_00_00__planar-influence-on-ecosystems-magic-and-npcs.md`
- `15_04_00_00_00_00_00__biome-tables.md`
- `15_05_00_00_00_00_00__world-generation-settings-and-tables.md`
