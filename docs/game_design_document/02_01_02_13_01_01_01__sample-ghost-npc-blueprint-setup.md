# 2.1.2.13.1.1.1 Sample Ghost NPC Blueprint Setup

# 👻 Sample Ghost NPC Blueprint Setup

---

## 🎯 Purpose

A haunting NPC that only manifests in the **Ethereal Plane**, invisible and intangible otherwise. Can be used for:

- Lore delivery
- Side quests
- Environmental storytelling
- Ethereal-only encounters

---

## ✅ Prerequisites

You need:

1. `UEtherealComponent` (from our earlier system)
2. `IEtherealDetectable` interface
3. Ghost-like mesh (skeletal or static)
4. Optional: custom ghost material, ambient sound, idle animation

---

## 🎓 Step-by-Step: Blueprint Setup

### 🎭 1. Create Blueprint: `BP_GhostNPC`

**Parent class:** `Character` or `AIController` depending on behavior

---

### 🧩 2. Add Components

| Component | Purpose |
| --- | --- |
| `EtherealComponent` | Manages phase visibility |
| `SkeletalMesh` | Visual ghost body |
| `GhostAudioComponent` | Ambient whispers (optional) |
| `SphereTrigger` | Detect player proximity (optional) |
| `FloatingPawnMovement` | Floaty movement in Ethereal |
| `PostProcessFadeFX` | Optional ghost glow/distortion |

---

### 🧬 3. Implement `IEtherealDetectable` Interface

### → In Class Settings:

- Add implemented interface: `IEtherealDetectable`

### → In Event Graph:

**Implement: `OnEnterEtherealView`**

```
blueprint
CopyEdit
→ Set Actor Hidden In Game: false
→ Set Collision Enabled: Query Only
→ Play animation/sound (e.g., ghost fade-in)
→ Start Idle behavior or AI tree

```

**Implement: `OnExitEtherealView`**

```
blueprint
CopyEdit
→ Set Actor Hidden In Game: true
→ Set Collision Enabled: No Collision
→ Stop animation/sound
→ Optional: Fade out or play vanish VFX

```

---

### 🎮 4. Add Idle Behavior (Optional)

In **AI Behavior Tree or Blueprint logic**, simulate ghost logic:

- Idle wander in a fixed radius
- Occasionally look toward unseen "events" (like it's stuck in time)
- Whisper dialogue snippets based on proximity or keywords

**Example:**

```
blueprint
CopyEdit
Event Begin Play → Delay Random 2–5s → Play "LookAround" Animation
→ Random Float (0–1)
   → If > 0.6 → Play Whisper Sound

```

---

### 👁 5. Visual Effects

Use a translucent material with:

- **Desaturation**
- **Sine wave panning alpha**
- **Low emissive glow**
- **Chromatic aberration**

Or a stylized outline (e.g., toon shader) in Ethereal Plane.

---

### 🧪 6. Test in the Game

- Ensure the NPC **does not appear** when not phased.
- Phase into Ethereal Plane → NPC becomes visible and interactive.
- Walk away or phase out → NPC vanishes completely.

---

## 🧠 Optional Additions

### 📜 Ghost Dialogue or Quest Trigger

```
blueprint
CopyEdit
On Player Enter Trigger → If IsInEtherealPlane
→ Display Text: “Who walks among echoes?”
→ Branch to Dialogue Widget or Journal Entry

```

---

### 🔁 Phasing Animation Example

```
blueprint
CopyEdit
→ Timeline → Control Material Opacity
→ Interp: 0 → 1 (fade in)
→ Optionally attach a “soul mist” particle effect

```

---

## 🛠 Blueprint Organization (Best Practice)

Structure your **BP_GhostNPC** like this:

```
scss
CopyEdit
BP_GhostNPC
├── EtherealComponent (logic)
├── SkeletalMesh (visuals)
├── GhostAudioComponent (looped whisper sound)
├── GhostLightFX (optional flickering point light)
├── TriggerSphere (interaction range)
└── FloatingPawnMovement

```
