# 2.1.2.13.1.1 Blueprint and C++

# 🌀 Ethereal Phasing & Visibility System

*For Unreal Engine 5.6 (Blueprint and C++)*

---

## 🎯 **Design Goals**

1. **Allow actors (players/NPCs) to shift between Material and Ethereal Planes**
2. **Control visibility and interaction between phased and non-phased actors**
3. **Simulate layered perception and collisions**
4. **Support timed or conditional phase states**
5. **Enable player abilities tied to phase detection or interaction**

---

## 🏗️ Core Concepts & Components

| Component/Class | Purpose |
| --- | --- |
| `UEtherealComponent` | Core logic for phasing in/out, attached to any actor |
| `EPlaneState` Enum | Enum for defining current plane: Material, Ethereal |
| `AEtherealManager` | Global subsystem to manage phase transitions & overlap |
| `IEtherealDetectable` | Interface for actors that are visible in the Ethereal |
| `BP_PostProcessEthereal` | Blueprint for ethereal vision FX |
| `UEtherealPerception` | Optional system for veil-sight / psionic detection |

---

## 🌌 1. Enum: `EPlaneState`

```cpp
cpp
CopyEdit
UENUM(BlueprintType)
enum class EPlaneState : uint8
{
    Material UMETA(DisplayName = "Material"),
    Ethereal UMETA(DisplayName = "Ethereal")
};

```

---

## 🔄 2. Component: `UEtherealComponent`

Attached to **any actor** that can phase.

```cpp
cpp
CopyEdit
UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class YOURGAME_API UEtherealComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    UEtherealComponent();

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    EPlaneState CurrentPlane;

    UFUNCTION(BlueprintCallable)
    void EnterEthereal();

    UFUNCTION(BlueprintCallable)
    void ExitEthereal();

    UFUNCTION(BlueprintCallable)
    bool IsInEtherealPlane() const;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    float MaxEtherealDuration;

protected:
    FTimerHandle PhaseTimerHandle;
    void RevertToMaterial();
};

```

**Key Functions:**

- **EnterEthereal()**:
    - Changes state
    - Applies ghost visual material
    - Sets collision to `NoCollision` or overlap only
    - Disables gravity if needed
- **ExitEthereal()**:
    - Restores normal physics, visibility, AI perception
- **RevertToMaterial()**:
    - Triggered after timer if temporary

---

## 🧠 3. Interface: `IEtherealDetectable`

Marks objects that should only be visible/interactive while in Ethereal.

```cpp
cpp
CopyEdit
UINTERFACE(BlueprintType)
class UEtherealDetectable : public UInterface
{
    GENERATED_BODY()
};

class IEtherealDetectable
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable, BlueprintNativeEvent)
    void OnEnterEtherealView();

    UFUNCTION(BlueprintCallable, BlueprintNativeEvent)
    void OnExitEtherealView();
};

```

Examples:

- Hidden pathways
- Ghost NPCs
- Echoes of memory

---

## 🧭 4. Global Manager: `AEtherealManager`

Coordinates transitions globally, used for:

- Multiplayer syncing
- Environmental overlap checks
- Shared shader effect triggering

```cpp
cpp
CopyEdit
UCLASS()
class YOURGAME_API AEtherealManager : public AActor
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable)
    void RegisterPhasedActor(AActor* Actor);

    UFUNCTION(BlueprintCallable)
    void UnregisterPhasedActor(AActor* Actor);

    UPROPERTY(BlueprintReadOnly)
    TArray<AActor*> CurrentlyPhasedActors;
};

```

---

## 🌀 5. Blueprint Setup (Visual Layering)

### Player Pawn:

- Add `EtherealComponent`
- Add `PostProcessComponent` → tie to material blend (for Ethereal Vision FX)
- On Input (gesture, button, psionic focus):
    - Call `EnterEthereal()`
    - Start FX (e.g. dissolve into mist)
    - Disable regular movement logic (optionally replace with flying/floating)

### Ghost Actors (e.g., BP_GhostNPC):

- Implement `IEtherealDetectable`
- On `OnEnterEtherealView`, enable visibility & AI
- On `OnExitEtherealView`, disable or hide

---

## 🎮 6. VR-Specific Considerations

- Use **motion controller input** (e.g., gesture or grip) to phase.
- Adjust **VR camera fog, chromatic distortion, and audio** when phasing.
- In Ethereal, use **floating directional movement** or gaze-based teleport.
- Allow players to “peek” into the Ethereal Plane using psionic focus (via slow veil shift).

---

## 🔒 7. Optional: Ethereal Perception & Vision Toggling

- Use a custom material or stencil buffer to show Ethereal-only actors.
- If using Enhanced Input:
    - Set up a binding for **Veil-Sight Toggle** to change post-process materials on the camera.
- Layer audio: subtle reverb, whispering echoes when sight is toggled.

---

## 🌐 8. Network Considerations (Multiplayer)

- Replicate `EPlaneState` with `OnRep` functions.
- Only replicate `EtherealComponent` effects to clients with veil access or if phased.
- Use `bOnlyRelevantToOwner` flag for ghost entities to manage network bandwidth.

---

## 🧪 Testing Checklist

| Feature | Test Notes |
| --- | --- |
| Player phase in/out | Duration, animation, collision |
| Actor visibility rules | Ghosts only seen while phased |
| Perception overlap (AI & player) | Ghosts detectable only with Veil-Sight |
| VR input binding | Gesture or controller-based phase toggle |
| World geometry layering | Ghost overlays do not block player while phased |
| Physics in Ethereal | Gravity toggle, ghost movement, phasing walls |

[2.1.2.13.1.1.1 Sample Ghost NPC Blueprint Setup](02_01_02_13_01_01_01__sample-ghost-npc-blueprint-setup.md)
