# 5.3 Stealth & Detection

### ✅ Separate Detection Modalities

Each sensory channel — **Vision**, **Hearing**, **Smell** — gets its own:

- **Detection radius**
- **Modifiers (based on player state, clothing, environment)**
- **Interval (how often it's checked)**
- **Perception cone or volume**

This lets stealth feel deep, skillful, and reactive.

---

## 🧠 Example of Separated Perception System

### 🧿 Vision Detection

- **Field of View**: 120° cone forward
- **Affected by**:
    - Clothing camo vs. environment
    - Player movement speed/posture (crouch = harder to spot)
    - Lighting (night, shadows, flash effects)
    - Obstruction (foliage, walls, terrain)
    - Distance (with falloff)

### 👂 Audio Detection

- **Sphere around AI** (radius = hearing range)
- **Affected by**:
    - Footstep volume (sprinting vs. sneaking)
    - Clothing sound profile (e.g., metal armor vs. cloth)
    - Environmental noise (wind, rain, birds, rivers)
    - Actions (jumping, landing, unsheathing weapon)

### 👃 Scent Detection

- **Scent trail** or cone carried by **wind direction**
- **Affected by**:
    - Weather (rain masks scent)
    - Time since passing (scent fades over time)
    - Clothing odor profile (dirty, bloodied, perfumed)
    - Creatures might track *you* instead of detecting immediately
    - Wind direction and speed

---

### 🧩 Implementation Suggestion (Unreal Engine 5)

Use UE5's **AI Perception System** with modular senses:

```cpp
cpp
CopyEdit
UAISense_Sight
UAISense_Hearing
UAISense_Smell // Custom – implement or extend

```

Each AI registers these:

```cpp
cpp
CopyEdit
PerceptionComponent->ConfigureSense(SightConfig);
PerceptionComponent->ConfigureSense(HearingConfig);
PerceptionComponent->ConfigureSense(SmellConfig); // custom

```

And when detecting a player:

```cpp
cpp
CopyEdit
if (HasLineOfSightTo(Player) && IsPlayerVisible(Player)) {
    AlertLevel += SightScore;
}
if (CanHear(PlayerNoise)) {
    AlertLevel += HearingScore;
}
if (CanSmell(PlayerScent)) {
    AlertLevel += SmellScore;
}

```

> Each of these can trigger different behaviors:
> 
- Vision: Raise weapon, alert call
- Hearing: Turn toward sound, investigate
- Smell: Start tracking or set an ambush

---

### 📈 Benefits of Independent Systems

| Feature | Result |
| --- | --- |
| Monster blind but with strong smell? | Still deadly in the dark |
| Ranged weapons from stealth | Don’t alert enemies unless seen or heard |
| Wind-based stealth gameplay | Downwind = danger, upwind = advantage |
| Dynamic environment effects | Rain hides sound/smell, fog blocks vision |
| Clothing loadout matters | Leather boots > metal greaves for sneaking |

---

### 🎮 Gameplay Example

**You're in a swamp**:

- You're wearing brown muddy robes (good visual camo)
- You're sneaking (low sound) but your clothing smells like blood
- A predator with bad vision and excellent smell is **upwind** of you

> It smells you before it sees or hears you, and starts circling to find your trail.
> 

[5.3.1 Stealth Core Systems](05_03_01_00_00_00_00__stealth-core-systems.md)

[5.3.2 Detection Logic](05_03_02_00_00_00_00__detection-logic.md)

[5.3.3 Pseudocode Examples](05_03_03_00_00_00_00__pseudocode-examples.md)