# 2.1.4 VR to K&M Fallback Controls

### ✅ **How to Translate VR Controls to Keyboard & Mouse**

| **VR Mechanic** | **Keyboard & Mouse Equivalent** | **Expanded Explanation** |
| --- | --- | --- |
| **Hand Tracking / Grabbing** | `E`, `F`, or `Left Mouse Button` (LMB) | Hold to maintain grip. Combine with mouse to move held object. |
| **Two-Hand Interaction** | `1`/`2` to switch hands + LMB/RMB | Allow switching active hand; use both buttons for two-handed actions (e.g. bow). |
| **Gestures (e.g., Spellcasting)** | `Q/W/E` + mouse movement or rhythm-based combos | Gesture arcs simulated via directional drag, circle mouse for rune drawing, or key rhythm patterns. |
| **Free Hand Movement** | Mouse + hand toggle (`Tab`, `Q`) | Cursor becomes a “floating hand.” Toggle mode to interact with the world or menus. |
| **Teleport Movement** | `Right Click` for targeting + release to move, or `Shift + Click` | Simulates VR teleport arc; optional cooldown for balance. |
| **Smooth Locomotion** | `WASD` + mouse | Standard movement. Optional stamina drain on sprint to match VR immersion. |
| **Turning / Snap Rotation** | Mouse for free look, `Q/E` or arrow keys for snap | Snap with small angle (45° default), or hold for smooth. Good for accessibility. |
| **Crouching / Prone** | `C` for crouch, `Z` for prone, hold for smooth transition | Optional: camera lowers smoothly to simulate physicality. |
| **Climbing / Pulling Up** | `W` near ledge + `Space` to mantle | Optionally require holding `Shift` to simulate exertion. |
| **Physical Inventory Interaction** | Tab or `I` opens inventory grid; drag/drop with mouse | Diegetic inventory (e.g. belt slots) can become UI slots or hotbars. |
| **Hotbar Activation** | Number keys `1-0` | Assign quick access to tools/spells previously holstered in VR. |
| **Object Inspection (Rotate, Zoom)** | `Right Click + Drag` to rotate, scroll wheel to zoom | Replicates holding and examining an item in VR. Add lighting cue or detail view. |
| **Throwing / Aiming** | Hold `LMB` to charge, release to throw | Simulate physical throw arcs with charging meter and mouse aim. |
| **Bow / Slingshot Pull** | Hold `RMB` to draw, `LMB` to release | Pull strength bar for feedback. Optional: arrow trajectory preview toggle. |
| **Potion Mixing / Alchemy** | Click and drag ingredients; timed or combo-based interface | Time-based stirring, simulated pouring via drag direction, or multi-input mini-games. |

---

### 🧩 Additional Interaction Mapping Concepts

| **VR Feature** | **Keyboard/Mouse Strategy** |
| --- | --- |
| **Fine Motor Tasks (e.g., lockpicking, tinkering)** | Precision mouse control, drag minigames, or key-tap rhythm games |
| **Menu Navigation (Diegetic Menus)** | Map wrist/menu to a key like `M` or `Esc`, use mouse to interact |
| **Dual-Hand Physics Puzzles** | Combine inputs (e.g., `1 + LMB` and `2 + RMB`) with on-screen feedback to simulate multi-hand pressure |
| **Push / Pull Objects** | Use `F` to grab, move mouse to simulate effort, use scroll or `W/S` to add force |

---

### 🧠 Best Practices for Desktop Emulation of VR

### 🎯 **1. Preserve Physical Feedback via Audio/Visual Cues**

- Add particle effects, shake, and whooshes for object interaction.
- Emphasize **on-hover cues** like glow, highlighting, or sound when interactables are nearby.

### 👁️ **2. Contextual UI for Hand Actions**

- Cursor proximity = visual hand reach.
- Tooltip overlays (brief, diegetic) replace proximity gestures in VR.
- Example: hover over a cauldron and press `F` to “stir,” `R` to “add item.”

### ✍️ **3. Gesture & Spell Input Design**

**Three methods:**

1. **Mouse Arc Detection** – Detect directional movements to trace symbols.
2. **Key Sequences** – Timed key inputs (e.g., `Q`, `W`, `E`) in pattern unlock spell.
3. **Rune Drawing Mode** – Hold a key (like `Shift`) to enter spell trace mode with the mouse.

Include visual feedback: glow trails, spark lines, incorrect gesture rejection.

---

### 🧪 Optional Immersive Enhancements

| Enhancement | Implementation |
| --- | --- |
| **Cinematic Camera Bob** | Light camera sway on sprint, climb, or crawl to simulate weight |
| **Transition Animations** | Fade-ins when switching hands/inventory, slow-zoom for inspection |
| **Audio Cues** | Use positional sounds for interaction (e.g., pick up = slight rattle, unlock = click) |
| **Ambient Cursor** | Animate cursor when near interactable objects to simulate hand "reach" or twitch |

---

### 🛠️ Unreal Engine Tips

### 💡 Input Abstraction Blueprint

Create an InputContext manager that allows switching between VR and Flat modes dynamically.

**Blueprint Input Mapping Context Tips:**

- Use “Enhanced Input System” to define contexts (VR, Desktop).
- Map actions like `Interact`, `Grab`, `CastSpell`, `SwitchHand` to both control sets.
- Avoid hardcoding—use tags or enums (`EHand::Left`, `EMode::VR`) for flexibility.

```
blueprint
CopyEdit
Event InputAction_Interact
→ Branch (IsInVR?)
   → VRController_Interact()
   → Keyboard_Interact()

```

### 💬 Context-Aware Hints

Example implementation in C++:

```cpp
cpp
CopyEdit
void UInteractionComponent::TickComponent(...) {
    if (bIsDesktopMode && IsInteractableInRange()) {
        ShowPrompt("Press E to grab " + Interactable->GetName());
    }
}

```

---

### 🎮 Reference Games Breakdown (Expanded)

| Game | What They Did Well | Ideas to Steal |
| --- | --- | --- |
| **The Walking Dead: S&S** | Inventory works both as hotbar & physical bag | Use combo hotkeys + visual inventory for hybrid immersion |
| **Half-Life: Alyx (mods)** | Gesture-based gravity glove modded for mouse flick | Repurpose spell grab system via mouse flick + `R` |
| **Boneworks (fan ports)** | Gesture replacement with input “hold zones” | Use regions of screen (corners/sides) to simulate hand reach |
| **Skyrim (modded)** | Full spell hotkey support | Combine spell schools into radial menus or macro chains |

---

### 🧩 Final Thoughts

> The goal is not to mimic VR perfectly, but to preserve intention, rhythm, and feel.
> 

Where VR is about physicality and space, KB&M is about timing, cursor flow, and tactile responsiveness through feedback. Focus on clarity, responsiveness, and intuitive metaphors over 1:1 fidelity.