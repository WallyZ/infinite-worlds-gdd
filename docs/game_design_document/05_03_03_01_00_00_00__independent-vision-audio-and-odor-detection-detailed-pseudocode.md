# 5.3.3.1 Independent Vision, Audio & Odor Detection Detailed Pseudocode

## 🎯 **Goal**

Model AI behavior where:

- Each **sense independently evaluates the player**
- Based on detection thresholds per sense, AI **reacts accordingly**
- Allows for **partial detection**, misdirection, or combo responses

---

## 🧠 **Detection Logic Pseudocode (Modular Perception)**

```cpp
// Enums for AI state
enum class EAIState
{
    Idle,
    Tracking,
    Investigating,
    Alerted
};

// AI Properties
FVector AIPosition;
FVector AIFacingDirection;
float VisionRange = 1200.f;
float HearingRange = 800.f;
float SmellRange = 600.f;
float AlertLevel = 0.f;
EAIState CurrentAIState = EAIState::Idle;

// Thresholds
const float VisionThreshold = 0.6f;
const float HearingThreshold = 0.5f;
const float SmellThreshold = 0.4f;
const float AlertDecayRate = 0.1f;
const float WindAlignmentThreshold = 0.6f;

// Placeholder for wind direction
FVector WindDirection;

// Player State (input values would be computed by gameplay systems)
FVector PlayerPosition;
FString MovementState; // "Idle", "Walking", "Running", "Sneaking"
FClothingProfile PlayerClothing; // Includes visual, noise, scent
float LightLevel; // 0.0 (dark) to 1.0 (bright)
float EnvironmentNoiseLevel; // e.g., wind, rain

// Utility Functions
float GetDistance(const FVector& A, const FVector& B)
{
    return (A - B).Size();
}

float DotProduct(const FVector& A, const FVector& B)
{
    return FVector::DotProduct(A.GetSafeNormal(), B.GetSafeNormal());
}

bool IsInFieldOfView(const FVector& AIPos, const FVector& AIDir, const FVector& Target, float Angle)
{
    FVector ToTarget = (Target - AIPos).GetSafeNormal();
    return FMath::RadiansToDegrees(acosf(FVector::DotProduct(AIDir, ToTarget))) < (Angle / 2.0f);
}

// Main Sensory Checks

bool CheckVision()
{
    if (IsInFieldOfView(AIPosition, AIFacingDirection, PlayerPosition, 120.f))
    {
        float VisibilityScore = CalculateVisibility(PlayerClothing, LightLevel);
        float Distance = GetDistance(AIPosition, PlayerPosition);

        if (VisibilityScore > VisionThreshold && Distance < VisionRange)
        {
            return true;
        }
    }
    return false;
}

bool CheckHearing()
{
    float MovementNoise = GetMovementNoise(MovementState, PlayerClothing);
    float EffectiveNoise = MovementNoise - EnvironmentNoiseLevel;
    float Distance = GetDistance(AIPosition, PlayerPosition);

    if (EffectiveNoise > HearingThreshold && Distance < HearingRange)
    {
        return true;
    }
    return false;
}

bool CheckSmell()
{
    float ScentStrength = PlayerClothing.ScentLevel;
    float Distance = GetDistance(AIPosition, PlayerPosition);
    FVector DirectionToPlayer = (PlayerPosition - AIPosition).GetSafeNormal();

    if (DotProduct(WindDirection, DirectionToPlayer) > WindAlignmentThreshold)
    {
        if (ScentStrength > SmellThreshold && Distance < SmellRange)
        {
            return true;
        }
    }
    return false;
}

// Detection Handler
void UpdateDetection()
{
    bool bSawPlayer = CheckVision();
    bool bHeardPlayer = CheckHearing();
    bool bSmelledPlayer = CheckSmell();

    if (bSawPlayer)
    {
        AlertLevel += 3.0f;
        CurrentAIState = EAIState::Alerted;
        FocusTarget(PlayerPosition);
        UE_LOG(LogTemp, Log, TEXT("AI sees player"));
    }
    else if (bHeardPlayer)
    {
        AlertLevel += 2.0f;
        CurrentAIState = EAIState::Investigating;
        FocusTarget(PlayerPosition);
        UE_LOG(LogTemp, Log, TEXT("AI heard something"));
    }
    else if (bSmelledPlayer)
    {
        AlertLevel += 1.0f;
        CurrentAIState = EAIState::Tracking;
        FocusTarget(PlayerPosition);
        UE_LOG(LogTemp, Log, TEXT("AI smells something nearby"));
    }
    else
    {
        AlertLevel = FMath::Max(0.f, AlertLevel - AlertDecayRate);
        if (AlertLevel == 0.f)
        {
            CurrentAIState = EAIState::Idle;
        }
    }
}

// Tick Loop
void Tick(float DeltaTime)
{
    UpdateDetection();
    UpdateAIBehavior(CurrentAIState);
}

```

---

## 🔍 Expandable Parts (You Can Define Elsewhere)

- `CalculateVisibility(...)` – factors in clothing, camo, light, environment.
- `GetMovementNoise(...)` – considers footwear, movement type, gear.
- `PlayerClothing` struct or class with fields:

    ```cpp
    cpp
    CopyEdit
    struct FClothingProfile
    {
        float VisualCamoRating; // 0 to 1
        float NoiseLevel;       // 0 to 1
        float ScentLevel;       // 0 to 1
    };
    
    ```

- `FocusTarget(FVector Target)` – stores AI focus or destination.

## 🔄 **AI Behavioral States Based on Sense**

| Sense Triggered | AI State | Action Taken |
| --- | --- | --- |
| Vision | `Alerted` | Immediate pursuit or attack |
| Hearing | `Investigating` | Moves to last heard location, cautious |
| Smell | `Tracking` | Begins scent-tracking or circling |
| None | `Idle` | Patrols or stays still |

You can **combine senses** for escalation:

- **Hearing + Smell** but no vision = *AI becomes suspicious, creeps toward sound*
- **Smell only** = *slow stalking behavior*
- **Heard → Smelled → Saw** = *full alert and combat mode*

---

## 🧰 Optional Add-Ons

- Add **memory of last known position** to simulate searching
- Add **false alerts**: e.g., creature investigates but doesn’t immediately attack
- Add **thresholds per creature**: some may be deaf, others blind

Compare **Blueprints** vs **Behavior Trees (BTs)** specifically for this kind of **multi-sense detection logic**.

---

## 🧠 TL;DR:

| Method | Best For |
| --- | --- |
| **Blueprints** | Fine-tuned control, debugging, prototyping, or small-scale enemies |
| **Behavior Trees** | Scalable, readable AI decision-making; designer-friendly logic; best for full AI systems |
| ✅ **Best Overall** | **Use Behavior Trees for AI states**, but handle **sensing and detection logic in Blueprints or C++** and feed results to the BT |

---

## ✅ Recommended Hybrid Approach (Best of Both Worlds)

> 🔧 Do sensing (vision/hearing/smell) in Blueprints or C++
>
>
> 🧠 **Drive decision-making in the Behavior Tree based on those results**
>

This keeps your detection logic modular, testable, and adjustable without spaghetti BT logic.

---

### 🧩 Blueprint Logic Handles:

- **Sight, Hearing, Smell detection** (via `AI Perception` system or custom logic)
- Sets **Blackboard values** like:
    - `CanSeePlayer` (bool)
    - `CanHearPlayer` (bool)
    - `CanSmellPlayer` (bool)
    - `AlertLevel` (float)
    - `LastKnownPlayerLocation` (vector)

You could do this in:

- A custom **AI Controller**
- A **Service Node** (runs every tick or interval)
- A **Blueprint Function Library** for reusability

---

### 🧠 Behavior Tree Handles:

- **Deciding what to do based on perception states**:

    ```
    text
    CopyEdit
    IF CanSeePlayer → Chase & Attack
    ELSE IF CanHearPlayer → Investigate Location
    ELSE IF CanSmellPlayer → Follow Scent Trail
    ELSE → Idle or Patrol
    
    ```

- The BT stays **clean**, readable, and logic-driven, while the complex calculations are offloaded.

---

## 💡 Why Not All in Blueprints?

- Blueprint-only AI gets messy fast as logic complexity increases (you’ll end up recreating decision trees by hand).
- It’s harder to reuse and tweak behavior without copy-pasting logic all over.
- Designers can't easily change logic without deep knowledge of the BP web.

---

## 💡 Why Not All in Behavior Trees?

- BTs are **not great at raw calculation**, vector math, or custom detection rules (like dot product wind logic).
- You’d need tons of custom decorators or services for niche senses, making them harder to manage.

---

## 🛠️ Suggested Unreal Setup

1. **Custom AI Controller**
    - Holds variables like `AlertLevel`, `DetectedSenses`
    - Has perception components for Sight, Hearing
    - Custom Smell logic in Blueprint or C++
2. **Blackboard**
    - Keys: `CanSeePlayer`, `CanHearPlayer`, `CanSmellPlayer`, `AlertLevel`, `TargetLocation`, `TargetActor`
3. **Behavior Tree**
    - Uses those keys to drive behavior states: patrol, track, search, chase, combat
4. **Optional Debug Widget**
    - Display current sense states and alert level in-game for tuning.

---

###
