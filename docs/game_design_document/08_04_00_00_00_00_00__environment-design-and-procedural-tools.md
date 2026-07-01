# 8.4 Environment Design & Procedural Tools

**🗺️ Terrain Generation:**

- Houdini, World Machine, and Gaia for base terrain sculpting with erosion, sedimentation, and river logic
- Seamless spherical world support using **3D icosphere tile logic**
- Terrain textures driven by slope, biome, moisture, sunlight exposure, and age

**🪴 Flora & Biomes:**

- Procedural foliage and biome distribution using UE5’s **PCG system**, Houdini Engine, and Foliage Tools
- Biomes support dynamic species spread and scarcity, driven by an **AI ecosystem layer** (e.g., predator-prey balance, seasonal cycles, player overharvesting)

**🏰 Architecture & Civilizations:**

- Modular, snap-based historical architecture kits (medieval, tribal, mystical)
- AI or rule-based layout generation (villages, ruins, towers)
- Dynamic environmental wear: cracked stone, soot from fireplaces, moss and ivy growth based on climate

**🌦️ Environmental Simulation:**

- Weathering via Runtime Virtual Textures (RVT): snow accumulation, soot buildup, trampled grass, mud trails
- Exposure-based wear systems using AI agents to track asset use, enabling *living environments*

**🧰 Tools for Environment Art & Simulation:**

| Task | Free Tools | Paid Tools |
| --- | --- | --- |
| Terrain Generation | Unreal PCG, Gaea Community, Blender Geo Nodes | World Machine, Houdini Indie, Gaea Pro |
| Foliage Placement | Unreal Foliage Tool, PCG Graph | SpeedTree (paid for export), Houdini |
| Texture Blending | Quixel Mixer (free with UE), Blender Shader Editor | Substance Designer, Materialize |
| Weathering/Procedural Damage | Unreal RVTs, Vertex Painting | Quixel Smart Materials, Substance Painter |
| Architecture Generation | Blender + Snap Utilities, Dungeon Architect (trial) | Houdini, Modular Snap Plugin, CityEngine |

The look and feel of the living world, both static and dynamic.

[8.3.1 Biome Visual Language](08_03_01_00_00_00_00__biome-visual-language.md)

[8.3.2 Settlement & Culture Design](08_03_02_00_00_00_00__settlement-and-culture-design.md)

[8.3.3 Dungeon, Ruin & Underground Style](08_03_03_00_00_00_00__dungeon-ruin-and-underground-style.md)

[8.3.4 Procedural Tools & Terrain Generation](08_03_04_00_00_00_00__procedural-tools-and-terrain-generation.md)
