# 11.5 Save & Cloud Sync

Saving an Earth-sized world without creating an unwieldy monster of a save file is a fun technical challenge—and definitely solvable with smart data structuring and prioritization. Here’s how you could tackle it:

🧠 **Chunk-Based World Segmentation**

Break your world into manageable “chunks” or “regions” (similar to how *Minecraft* handles terrain). Each chunk should:

- Only save when it has been changed or interacted with.
- Store only delta states (differences from default) rather than full data sets.
- Be asynchronously loaded/unloaded as needed based on player proximity.

💾 **State Prioritization & LOD for Save Data**

Just like Levels of Detail (LOD) in rendering, apply a **"Save LOD" system**:

- **High detail**: For nearby areas or regions where changes recently occurred.
- **Mid detail**: Summarized state (e.g. "tree chopped down", “enemy settlement weakened”) for mid-range zones.
- **Low detail**: Simply track timestamps, player visits, or scripted events—defer full regeneration until accessed.

🧰 **Use Procedural Regeneration with Seeds**

If your world uses procedural generation:

- Store seed data and alteration overlays separately.
- Only persist changes (buildings placed, terrain modified, NPC moved) while referencing procedural rules to rebuild unchanged areas dynamically.

🧩 **Entity-Based Save Architecture**

Instead of saving static world files, you could:

- Track entities (NPCs, player data, quests, objects) in a database-style format.
- Assign unique IDs to dynamically loaded world zones and entities, so state is tied to them, not geography.

🧼 **Compression & Serialization**

- Use a compact binary format like Protocol Buffers or FlatBuffers.
- Apply compression like LZ4 or Zstandard to keep files lightweight.
- Serialize only what’s needed (e.g., don’t save unchanged inventory or physics states unless flagged).

📦 **Modular Save Files**

Split your save data:

- Core player data (character, inventory, meta)
- World state by region
- Quest progression
- AI/NPC state changes

Each can load independently, reducing memory overhead and allowing cloud sync or partial restores later.

Broken it into layers to for a modular workflow and Blueprint-first approach:

🧱 **1. World Partition Integration**

**Goal:** Dynamically stream world chunks based on player location, ideal for massive worlds.

- **Enable World Partition** in project settings; organize world content into **data layers** and **grid cells**.
- Add **Data Layer Volumes** to categorize interactable areas (e.g., cities, wilderness, dungeons).
- Pair streaming behavior with **Level Streaming Volumes**, so you can load data as-needed.
- For saving: Tag streamed zones with unique IDs, and save just the modified actors or overlays using those references.

📁 **2. Data Assets for Static Metadata**

**Goal:** Store reusable default world state, biome data, or zone configurations.

Create custom Blueprintable **Data Asset** classes for:

- **Biome or Region Templates** (`UDataAsset_RegionTemplate`)
- **Default NPC Spawn States**
- **Environmental Details (e.g., seasonal overrides, climate settings)**
- Store these under `/Game/DataAssets` and load on-demand when building procedural segments.

You don’t save the asset—you save *overrides* to the asset state, using lightweight deltas in your save structure.

💡 **3. Actor-based Save Blueprint (Delta Logic)**

Use a **Save Component** Blueprint attached to dynamic actors (e.g., props, enemies, quest givers).

**Core functionality:**

- On Begin Play, compare to default Data Asset or procedural template.
- If differences exist (e.g., NPC died, object moved), flag for save.
- Store only:
    - Actor Class
    - World Partition Cell ID
    - Transform
    - Modified variables (e.g., HP, Inventory)

Implement a **SaveGame Object subclass** (`UGlobalWorldSave`) that aggregates this modular data. This can be serialized per region or streamed based on player movement.

🧠 **4. Save LOD System**

Use player proximity + recent interaction timestamps to tier save detail:

| Zone State | Save Contents |
| --- | --- |
| Active | Full actor data, quest flags, dialogue states |
| Recently Visited | Summarized state: altered objects + triggers |
| Distant | Timestamp + interaction breadcrumbs only |

Blueprints can track a “last modified” stamp per region and downgrade detail during cleanup passes. You can run this in background async tasks.

🧰 **Optional Enhancements**

- Implement a **Save Manager Subsystem** to handle save/load requests across regions.
- Use **Gameplay Tags** to track categories of changes (e.g. `Destroyed.Structure`, `Modified.DialogueNode`).
- Consider Level Instance Blueprints for localized save-heavy regions, like towns.

Persisting NPC evolution without relying on the player’s presence turns your game into more of a simulation, and it opens the door for emergent storytelling. Here's how you could realistically handle this, combining efficiency and believability:

🧠 **Simulated Runtime via "Scheduled Simulation"**

Instead of running actual AI logic when offscreen, **simulate outcomes periodically**:

1. **Track NPC State & Goals**: Each NPC has a lightweight “life record”—job, personality traits, location, relationships.
2. **Schedule Simulation Ticks**: When that NPC's region is unloaded, periodically (or on load) simulate:
- Their last known goals
- Stats like hunger, energy, happiness, influence
- Relationships evolving via rules (e.g., “+1 trust if interacted recently”)

You’re essentially running a **logic update**, not full AI behavior trees.

🗓️ **Asynchronous Time-Based Playback**

When the player re-enters the region:

- Query the NPC’s last interaction timestamp.
- Fast-forward a simulation based on elapsed time using outcome tables (e.g., work succeeded, married another NPC, moved town).
- Flag events worth logging ("NPC X formed a rival faction") and tie them into your world state/save system.

This balances immersion with CPU sanity.

🧩 **Modular “Life Modules”**

Use modular components to guide NPC behavior evolution:

| Module | Simulated Behavior |
| --- | --- |
| Job Role | Income accumulation, skill increase |
| Social Behavior | Relationship decay/growth, event triggers |
| Faction Politics | Influence changes, policy votes |
| Exploration | Change of region, discovery flags |

These update probabilistically based on traits + recent events.

💾 **Storage Strategy**

Use something like `UNPCStateSave` objects:

- Store only deltas: trait changes, relationship values, flags like `HasChild` or `MovedTo=Zone_42`
- Save periodically or on major state change
- Serialize as part of zone-independent NPC system, since they can cross regions

This keeps your save files tidy but meaningful.

🔄 **Hook Into World Partition Events**

When a region streams in:

- Query NPCs “meant” to be there.
- Reconstruct their state and inject into the scene.

When it streams out:

- Collect those NPCs’ most recent actions → run quick extrapolations
- Update their save record
- Destroy or cache actor as needed

You’re essentially swapping between **live actors** and **lightweight simulation records**.

Conceptual blueprint of a **UNPCManagerSubsystem** that can be built entirely in Unreal's Blueprint system. The idea is to periodically update an offline simulation “record” for each NPC, then apply those changes when the NPC’s region is loaded. Here’s one way to structure it:

**1. Create a Blueprintable Subsystem**

- **Subclass**: Create a new Blueprint class based on `GameInstanceSubsystem` (or, if you prefer C++–backed functionality exposed to Blueprints, derive from `UGameInstanceSubsystem` and set it as Blueprintable). Name it **BP_NPCManagerSubsystem**.
- **Purpose**: This subsystem manages the simulation ticks for NPCs that aren’t “live” in the world, processing their life data in the background.

**2. Define an NPC Simulation Record Struct**

Create a struct (e.g., **NPC_SimRecord**) with fields such as:

- **NPC_ID** (Unique identifier)
- **LastSimulationTime** (Timestamp of last simulation update)
- **CurrentState** (An enum or flags that indicate states such as `Idle`, `Working`, `Socializing`, etc.)
- **Attributes** (Values like health, mood, energy)
- **LocationReference** (A simple key indicating which region or cell the NPC belongs to)
- **Other Data** (Relationships, events, progression markers)

This struct represents each NPC's state when not actively simulated.

**3. In the Subsystem’s Event Graph**

**a. Event Initialization**

- **Event BeginPlay (or OnSubsystemInitialized)**:
- Set a **Timer by Function Name** that calls a function (say, `SimulateNPCs`) on a fixed interval (e.g., every 60 seconds or as desired).
- You can expose the simulation interval as a public variable for tweaking.

**b. The SimulateNPCs Function**

This function is the heart of the simulation logic:

1. **For Each NPC Record**
    - Use a **For Each Loop** iterate over an array of `NPC_SimRecord` (stored as a variable in your subsystem).
2. **Calculate Time Delta**
    - **Get CurrentTime** node – subtract the `LastSimulationTime` stored in the record.
    - Calculate the elapsed time (Δt) to determine how far the simulation should advance.
3. **Apply Simulation Rules**
    - Branch based on elapsed time:
        - **Low Δt**: Perhaps only a minor state tweak.
        - **High Δt**: Run through a series of **randomized events** (think of it as a mini “event table” for that NPC).
    - Use nodes like **Random Float in Range**, **Select**, or even **Data Tables** to decide outcomes such as attribute adjustments, state changes, or event flags (e.g., “NPC moved to a new region” or “NPC gained a relationship point”).
4. **Update the NPC Record**
- Write back the modified state, reset the `LastSimulationTime` to the current time, and flag any major changes (for logging or triggering immediate world events when the NPC streams in).

**c. Blueprint Node Sketch (Pseudocode)**

Here’s a simplified flow using Blueprint concepts:

Event BeginPlay (or OnSubsystemInitialized)
    └── Set Timer by Function Name [Function: SimulateNPCs, Interval: SimulationInterval, Looping: True]

Function SimulateNPCs
    └── For Each Loop (Over NPC_SimRecord Array)
         ├── Get NPCRecord.LastSimulationTime
         ├── Get CurrentTime (e.g., using "Get Game Time in Seconds")
         ├── DeltaTime = CurrentTime - NPCRecord.LastSimulationTime
         ├── If DeltaTime > MinimumThreshold
         │       ├── [Use a Switch on NPCRecord.CurrentState] or branch logic
         │       ├── For each attribute, simulate change:
         │       │       ├── NewValue = CurrentValue + (Random Modifier * DeltaTime)
         │       │       └── Clamp as needed
         │       ├── Optionally: Roll for a state event (e.g., job change)
         │       └── Update NPCRecord.LastSimulationTime = CurrentTime
         └── End For Each Loop



- **Visualizing the Flow:**
Imagine the **Event Graph** starting with a timer node that fires `SimulateNPCs`. Within that function, a loop iterates over each NPC record. Each iteration uses simple math nodes to compute the elapsed time, then branches (using **Branch** nodes) to decide what events or modifications occur. The updated record gets saved back into the array.

**4. Handling Region Streaming**

- **When a Region Loads**:
    - Have logic in your world partition manager or level blueprint that, upon streaming in a region, calls a function on **BP_NPCManagerSubsystem** to “hydrate” NPCs. This means reading their simulation record and spawning/updating live actor instances with the stored values.
- **When a Region Unloads**:
- Conversely, capture the current state of any live NPCs from that region and update their corresponding simulation records, then destroy or deactivate the actors.

This ensures a smooth transition between offline simulation and live actors without losing continuity.

**5. Exposing to Blueprints**

Since everything here is built as a Blueprintable subsystem:

- Mark the primary functions (`SimulateNPCs`, `HydrateNPCFromRecord`, etc.) as **BlueprintCallable**.
- Ensure the struct **NPC_SimRecord** is BlueprintType so designers can tweak simulation parameters via Data Tables or directly in the editor.
- Document in the subsystem’s comments how each piece ties together (this aids both brainstorming and team integration).

**Next Steps and Further Expansion**

- **Event Logging**: Add nodes that log important events (e.g., “NPC X has changed state drastically”) that you might use for debugging or triggering narrative events.
- **Data-Driven Decisions**: Consider integrating Data Tables for NPC behavior profiles so that changes in simulation rules can be tweaked without recompiling.
- **Multi-threading (Future Considerations)**: In high-end projects, you might offload these simulation ticks to an asynchronous thread, though initially, Blueprint timers should suffice for periodic updates.

This sketch gives you a robust starting point. Each node and branch in the Blueprint graph mirrors a deliberate aspect of the simulation, balancing efficiency with emergent behavior. You can now expand this system to log interactions or even trigger real-time events that ripple out into the environment.

Here's how you can seamlessly link your **BP_NPCManagerSubsystem** with Unreal's World Partition system to ensure NPCs transition smoothly between simulated records and live, interactive actors:

**1. Detecting Region Streaming Events**

**World Partition Manager Notifications:**

- **Custom Region Events:** In your World Partition setup, create custom events or triggers that fire when a partition (or grid cell) is about to be streamed in or out.
- **Blueprint Hooks:** Use Level Blueprint events or World Partition’s runtime events (like `On Cell Loaded` or `On Cell Unloaded`) to notify your NPC Manager Subsystem.

**2. Hydration of NPCs on Region Load**

**Process:**

- **Trigger the Hydration Function:** When a region is loaded, the Level Blueprint or Partition Manager calls a *BlueprintCallable* function on your **BP_NPCManagerSubsystem**—for example, `HydrateNPCsForRegion`.
- **Fetch NPC Records:** This function queries your subsystem’s array of `NPC_SimRecord` items for any records that reference the now-active region (likely using a field like `LocationReference` or a region ID).
- **Spawn or Update Actors:**
    - For each matching NPC record, the system spawns an actor if it isn’t already present in the world.
    - If the actor exists overhead (revisiting a pre-loaded NPC), the subsystem updates its properties (position, state, relationships, etc.) based on the stored `SimRecord`.
- **Integration Example:**
- In Blueprints, after the cell’s `On Cell Loaded` event, call the `HydrateNPCsForRegion(RegionID)` function.
- This function loops through relevant NPC records, applies changes to an actor’s blueprint instance, and removes or flags the record as “active.”

**3. Dehydration When Regions Unload**

**Process:**

- **Capture Live State:** When a region is about to unload, the partition manager fires an event (e.g., `On Cell Unloaded`).
- **Update Simulation Records:** Before the region is removed from memory, the Level Blueprint or world partition handler calls a function such as `DepopulateRegionNPCs(RegionID)` on your **BP_NPCManagerSubsystem**.
    - This function iterates over all NPC actors in that region, extracts their current state (transform, attributes, relationships), and writes those values back to the corresponding `NPC_SimRecord`.
- **Actor Removal:** Once updated, the system safely deactivates or destroys the live NPC actors to free resources.
- **Ensuring Continuity:** This dehydration step makes sure that any ongoing simulated activity is preserved without having the NPC continuously running in a loaded state, thus maintaining performance.

**4. Blueprint Node Flow Example**

**On Region Load:**

1. **World Partition Manager (or Level Blueprint):**
    - Event: `On Cell Loaded` → Pass the **RegionID**.
2. **Call to NPC Manager Subsystem:**
    - Node: `HydrateNPCsForRegion(RegionID)`
    - Inside the function, iterate over `NPC_SimRecord` entries with a matching RegionID, then:
    - Spawn an NPC actor (if not present).
    - Update the actor’s state from the simulation record.
3. **Actor Initialization:**
- The spawned actor then fully initializes its AI, collisions, and interactive components.

**On Region Unload:**

1. **World Partition Manager (or Level Blueprint):**
    - Event: `On Cell Unloaded` → Pass the **RegionID**.
2. **Call to NPC Manager Subsystem:**
    - Node: `DepopulateRegionNPCs(RegionID)`
    - Inside the function, loop through active NPCs in that region:
    - Extract their state.
    - Update the corresponding `NPC_SimRecord` with the simulated, live data.
3. **Actor Cleanup:**
- Remove the actor from the world to reduce memory footprint.

**5. Integration Considerations**

- **Communication Methods:**
    - Use **Blueprint Interfaces** for communication between the World Partition event triggers and your NPC Manager Subsystem.
    - Alternatively, consider **Event Dispatchers** for asynchronous notifications.
- **Data Consistency:**
    - Always ensure that once an NPC is hydrated, the record is flagged or removed from your inactive pool.
    - When dehydrating, compare live changes with previously simulated values to decide if a full update is necessary.
- **Testing and Debugging:**
- Add logging (using the **Print String** node initially) to track when NPC records are hydrated and dehydrated.
- Visualize the region boundaries so you know that the correct NPCs are being processed as parts of cells load/unload.

By integrating the **BP_NPCManagerSubsystem** with your World Partition Manager, you create a fluid system where NPCs move between “simulated offscreen” states and “live” interactions seamlessly. This setup not only maintains performance in your Earth-sized world but also provides a living, evolving simulation that persists even when players aren’t nearby.

- Save file format
- Cloud compatibility (Steam, Epic, standalone)
- Syncing persistent world changes (settlements, relationships)
- Conflict resolution logic (for mods, desyncs, parallel players)
