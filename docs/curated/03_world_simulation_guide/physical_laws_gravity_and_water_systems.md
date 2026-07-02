# Physical Laws, Gravity, and Water Systems

## Provenance

Source inputs:

- `docs/game_design_document/03_10_00_00_00_00_00__world-physics-and-planar-systems.md`
- `docs/game_design_document/03_10_01_00_00_00_00__physical-laws-and-environmental-interactions.md`
- `docs/game_design_document/03_10_10_00_00_00_00__elemental-planes-fire-air-water-earth.md`
- `docs/game_design_document/03_10_16_00_00_00_00__planar-influence-on-ecosystems-magic-and-npcs.md`
- `docs/game_design_document/03_11_00_00_00_00_00__terrain-deformation-and-environmental-impact.md`
- `docs/game_design_document/05_01_01_02_00_00_00__ranged-weapons-and-projectile-physics.md`

Implementation surfaces:

- `F:\dev\infinite-worlds\docs\design\GRAVITY_SYSTEM_CONTRACT.md`
- `F:\dev\infinite-worlds\docs\design\WATER_SYSTEM_CONTRACT.md`
- `F:\dev\infinite-worlds\docs\todo\TODO_23_realistic_gravity_system.md`
- `F:\dev\infinite-worlds\docs\todo\TODO_22_realistic_water_system.md`

## Purpose

This curated page is the canonical GDD bridge for physical-law systems that need simulation ownership in the Unreal repo.

The raw GDD already names altered physics, gravity, water, elemental planes, planar influence, and physical interactions, but the dedicated physical-law child page is thin. This page keeps those ideas together so implementation can proceed without scattering gravity and water across magic, terrain, survival, and presentation chapters.

## Player Experience

Players should trust that ordinary gravity behaves like real life until the world clearly changes the law.

If a surface tips, the player should feel the downward tilt and begin sliding, stumbling, or falling according to the movement system. If a room contains localized gravity, one player can stand on the floor while another walks on the ceiling, and both should read as physically coherent from their own local frame. Gravity gradients should create a believable neutral zone where a jump can slow, float, then reverse into another gravity field.

Water should feel like a physical medium. Wind creates waves, stronger wind creates larger and rougher waves, currents move bodies on and under the surface, swimmers feel buoyancy and resistance, and underwater time creates breath pressure. Boats should float, drift, pitch, roll, and become unstable under stronger waves.

## System Rules

Gravity:

- Default gravity is real-life downward gravity.
- Disabled or missing gravity systems fall back to real-life gravity, not zero gravity.
- Local gravity can be bound to regions, volumes, surfaces, actors, planar effects, or temporary magical laws.
- Gravity gradients blend between vectors and can include a neutral midpoint.
- Magic and planar systems request gravity-law changes; gravity owns resolution, priority, fallback, and expiry.
- Character movement, camera comfort, physics bodies, damage, and magic costs remain separate consumers.

Water:

- Water owns surface, current, depth, immersion, buoyancy, drag, and oxygen-exposure facts.
- Wind and weather influence waves and currents through environmental-field queries.
- Boats and swimmers consume water facts but own their own control, damage, animation, and status changes.
- Underwater oxygen is emitted as a fact for character/status systems, not applied directly by water.
- Disabled or missing water systems return safe still-water facts.

## Dependencies

Shared dependencies:

- environmental field query contracts
- world/time/weather facts
- terrain and shoreline/depth facts
- magic and planar law requests
- diagnostics and QA telemetry

Gravity consumers:

- character movement
- physics bodies
- camera and VR comfort
- magic/planar systems
- status and damage systems

Water consumers:

- character movement and swimming
- boat or vehicle systems
- physics objects and floating debris
- oxygen/status systems
- VFX, audio, haptics, and visual progress capture

## MVP Scope

Gravity MVP:

- real-life fallback gravity
- tilted-surface downhill vector
- floor and ceiling gravity samples in one room
- floor-to-ceiling gradient with neutral midpoint
- temporary magical reverse-gravity law with expiry
- QA telemetry and deterministic contract validation

Water MVP:

- wind-to-wave scaling
- high-wind wave escalation
- surface and underwater current samples
- boat buoyancy and high-wave motion
- swimmer buoyancy, drag, current drift, and oxygen facts
- QA telemetry and deterministic contract validation

## Open Questions

- How should VR camera comfort handle rapid changes to local up without disorienting players?
- How should multiplayer prediction reconcile actors crossing gravity-gradient boundaries at different client frame rates?
- How much water simulation should be physical versus visually approximated for performance?
- Which spells can request physical-law changes, and what costs or limits prevent chaotic griefing in multiplayer?
- How should persistent planar zones alter water and gravity without making ordinary traversal unreadable?
