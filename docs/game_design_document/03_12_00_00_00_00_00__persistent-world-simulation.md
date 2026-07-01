# 3.12 Persistent World Simulation

The world of *Infinite Worlds* operates under a deep simulation framework, supporting continuous evolution of its systems to provide an authentic and responsive living world. This simulation adapts intelligently based on the game mode — whether single-player or multiplayer — to balance immersion, performance, and player agency.

### **Simulation Modes**

- **Single-Player (Local World State)**
    - In single-player mode, the game simulation is **paused** when the player is not actively playing.
    - Upon resuming the game, all systems resume from the exact point they were left.
    - This ensures consistent performance and gives players full control over pacing without missed developments.
    - Despite the pause, the same simulation systems are active while the game is running, including diplomacy, migration, weather, and NPC aging.
- **Multiplayer / Server-Hosted (Persistent World State)**
    - On dedicated or hosted servers, the world continues to evolve **in real-time**, even when no players are online.
    - Time moves forward regardless of player activity, allowing the world to experience events, climate shifts, migrations, or historical developments autonomously.
    - Server-side simulation enables large-scale changes, faction wars, market shifts, and dynastic turnovers to happen naturally and continuously.
    - Server logs and in-world journals can provide updates on major events that occurred during player absence.

### **Core Simulation Features**

- **Ongoing World State**
    - Time progresses globally — affecting seasons, ecosystems, politics, aging, and more — governed by a unified simulation clock.
    - Simulation fidelity scales depending on proximity and relevance: nearby regions are simulated in detail; distant areas may update in abstracted batches for performance.
- **Systems-Driven Simulation**
    - **Economy**: A dynamic economy with regional supply/demand, trade routes, inflation, and scarcity. Players can create or collapse markets.
    - **Diplomacy**: AI factions engage in negotiations, wars, alliances, and betrayals according to their histories, goals, and changing world state.
    - **Culture & Religion**: Beliefs, rituals, languages, and values shift across generations or due to external influence. Syncretic religions may form over time.
    - **Migration & Settlement**: Entire populations may abandon areas or settle new lands due to opportunity, conflict, or disaster.
    - **Climate & Weather**: Simulated both short-term (daily/seasonal) and long-term (climate cycles). Catastrophic weather events and climate change are possible.
    - **Historical Memory**: Major events become part of the world’s recorded or oral history, influencing art, politics, and even game mechanics (e.g., laws or taboos).
- **NPC Continuity**
    - **Aging & Mortality**: NPCs age, suffer illness or injury, and die of natural causes, accidents, or violence.
    - **Inheritance & Legacy**: NPCs pass on wealth, land, titles, skills, or vendettas to their descendants or rivals.
    - **Memory of Player Actions**: NPCs track interactions over time and pass reputations to others. Villages remember your kindness — or your cruelty.
    - **Skills & Professions**: NPCs evolve careers, develop skills, join or leave factions, and seek opportunity based on their goals and environment.
    - **Agency & Autonomy**: Each NPC has personal goals and reacts to changes in the world, capable of forging destinies entirely independent of the player.

### **Gameplay Impact**

- Returning to a previously visited location may reveal a transformed settlement, ruined village, or thriving capital depending on simulation progression.
- Player actions can cause ripple effects that may not fully manifest until years later, or even across generations.
- Legacy content such as books, tombstones, oral stories, and architecture reflect both world history and player involvement.
- Dynamic quest lines and faction goals may arise or expire based on the changing simulation.

### **Integration and References**

- **Cross-reference with [5. Behavioral Integration]**: NPC behavior is shaped by simulation events, player reputation, and inherited memory.
- **See also**:
    - [Procedural World Generation]: Foundation upon which simulation builds, including tectonics, climate, and civilizations.
    - [Faction Systems]: Emergent AI goals and group behavior influenced by simulation outputs.
    - [Historical Tracking & Lore]: Persistent, system-recorded events stored for NPC and player reference.
    - [Player Impact Memory System]: Simulation-driven memory and recognition of player deeds, across time and geography.

[3.12.1 World Persists Without Player Input](03_12_01_00_00_00_00__world-persists-without-player-input.md)

[3.12.2 Systems Interact Autonomously](03_12_02_00_00_00_00__systems-interact-autonomously.md)

[3.12.3 Server/Local Performance & Memory Optimization](03_12_03_00_00_00_00__server-local-performance-and-memory-optimization.md)