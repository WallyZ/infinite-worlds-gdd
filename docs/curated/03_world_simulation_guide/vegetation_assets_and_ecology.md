# Vegetation Assets And Ecology

## Provenance

Source inputs:

- `docs/game_design_document/03_01_02_00_00_00_00__biome-diversity-and-composition-climate-altitude-terrain-types.md`
- `docs/game_design_document/03_03_00_00_00_00_00__ecosystems-flora-fauna-microbes-and-food-webs.md`
- `docs/game_design_document/03_03_01_00_00_00_00__species-behaviors-life-cycles-and-territory.md`
- `docs/game_design_document/08_03_01_00_00_00_00__biome-visual-language.md`
- `docs/game_design_document/08_08_02_00_00_00_00__architecture-and-biome-guidelines.md`
- `docs/game_design_document/15_04_00_00_00_00_00__biome-tables.md`
- `docs/game_design_document/01_10_04_00_00_00_00__mythologies-philosophies-and-real-world-systems.md`

Implementation surfaces:

- `F:\dev\infinite-worlds\docs\design\VEGETATION_ASSET_ECOLOGY_CONTRACT.md`
- `F:\dev\infinite-worlds\docs\todo\TODO_24_realistic_vegetation_assets_and_ecology.md`
- `F:\dev\infinite-worlds\docs\production\vegetation\vegetation_v0_catalog.json`
- `F:\dev\infinite-worlds\docs\production\ASSET_GENERATION_PIPELINE.md`

## Purpose

This curated page is the GDD bridge for vegetation assets and plant ecology.

The raw GDD already has strong flora lifecycle notes in `3.3`, biome placement logic in `3.1.2`, visual signals in `8.3.1`, and plant/herbal inspiration notes in `1.10.4`. The missing implementation-facing layer is a single place that turns those ideas into asset requirements, ecological traits, and TODO-backed validation.

## Player Experience

Vegetation should look like it belongs where it grows.

Grass in dry steppe should be short, tufted, and drought stressed. Wetland sedges should cluster along saturated banks. Forest trees should express root stability, canopy shade, wood quality, and seasonal change. Plants should respond to water, sunlight, soil, weather, wind, grazing, harvesting, disease, fire, and magical stress in ways players can learn through observation.

The player should eventually infer useful knowledge from the world: which plant indicates wet soil, which tree gives flexible wood, which bark or resin might matter for crafting or medicine, and which lookalikes are risky without training.

## System Rules

- Every vegetation asset needs ecological data, not just a mesh.
- Water need, sunlight need, soil preference, drainage, nutrient demand, and pH range are required plant traits.
- Roots are gameplay data: depth, spread, anchoring, erosion control, water access, and microbial relationships.
- Trees and woody plants define wood quality, bark/sap/resin/fruit/seed products, fuel value, and crafting suitability.
- Grasses and reeds define fiber, thatch, forage, tinder, erosion, and wetland indicator properties where relevant.
- Plant-use and medicinal tags are design possibilities, not real medical instructions; they require future expert/design review before gameplay promotion.
- Vegetation consumes weather, water, terrain, sunlight, soil, biome, and magic/planar facts. It does not own those facts.
- Unsupported plant placement should fail validation unless a fantasy overlay explains the exception.

## First Asset Families

Grass and herbaceous forms:

- temperate meadow grass
- wetland sedge or reed
- dry bunchgrass
- future herbs, mosses, fungi, vines, aquatic plants, and crop plants

Tree and woody forms:

- temperate broadleaf tree
- conifer pioneer tree
- riparian willow-like sapling
- future shrubs, fruit trees, deadwood, stumps, roots, and fallen logs

## Dependencies

Vegetation depends on:

- environmental fields for wind, sunlight, shade, humidity, temperature, and soil moisture
- water and hydrology for flooding, drought, water uptake, and streambank rules
- terrain and soil for slope, texture, depth, drainage, pH, nutrients, and root obstruction
- biome/worldgen for placement suitability and source-backed explanation
- magic and planar fields for fantasy exceptions, mutations, and visible stress
- asset generation and Blender post-process for mesh provenance and Unreal import readiness

Consumers:

- worldgen and foliage placement
- crafting, construction, fuel, and material systems
- medicine, poison, disease, and status systems
- AI herbivory, foraging, and habitat logic
- codex, knowledge, mentor, and discovery systems
- visual progress capture and QA-live

## MVP Scope

Vegetation MVP:

- six prototype grass/tree assets
- source OBJ, Blender-normalized FBX, metadata, and intake records
- water, sunlight, soil, root, lifecycle, wind/water stress, wood/fiber, and plant-use metadata
- deterministic validator and QA-live dry-run spec
- clear deferral of native Unreal growth simulation and final art

## Open Questions

- Which real-world botanical sources become approved reference sources for species-like data?
- How abstract should plant taxonomy be before the game has real biomes and art direction?
- How should seasonal changes affect mesh swaps, material states, and harvest quality?
- How should players learn plant uses through mentorship, experiment, books, and mistakes?
- What expert review is needed before real-world medicinal analogues become in-game effects?
- How should fantasy ecology alter natural plant rules without making every unsupported placement arbitrary?
