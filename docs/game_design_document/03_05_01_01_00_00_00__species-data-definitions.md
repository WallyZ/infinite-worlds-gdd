# 3.5.1.1 Species Data Definitions

High-level architecture plus concrete Blueprint & C++ recipes for a “living ecosystem” in UE5.6—no more hard spawn tables, everything truly breeds, ages, dies and interacts. Treat it as both design doc and jump-start code outline.

## 1. Core Concepts & Data Architecture

1.1   Data-Driven Species Definitions
    • Use a DataTable (`CSV` or `JSON`) keyed by `FName SpeciesID`
    • Columns:
      – `ParentSpeciesID` (for inheritance)
      – `ReproductionType` (Sexual, Asexual)
      – `LitterSizeMin/Max`, `MaturityAge`
      – `MaxLifespan`, `GestationTime`
      – `DietType` (Herbivore, Carnivore, Omnivore, Energy, Matter)
      – `PreferredEnvTags` (Tags: Forest, Wetland, Rocky…)
      – `AggressionLevel` (0–1 float)
      – `ParentalCare` (None, Minimal, Extended)

1.2   Runtime Tracking by `AEcosystemManager`
    • Singleton Actor placed in World
    • Holds lists: `TSet<AAnimalBase*> AllAnimals;`
    • Per-tick or timed update: population counts, carrying capacity checks
    • Exposes EQS/Volumes to steer where births/spreads happen

## 2. `AAnimalBase` C++ Class Outline

cpp

`// AnimalBase.h
UENUM() enum class EReproType { Sexual, Asexual };
UENUM() enum class EDietType { Herbivore, Carnivore, Omnivore, Energy, Matter };
UENUM() enum class EParentalCare { None, Minimal, Extended };

UCLASS(Abstract) class AAnimalBase : public ACharacter
{
  GENERATED_BODY()

public:
  // DataTable row
  UPROPERTY(EditAnywhere) FName SpeciesID;

  // Runtime state
  UPROPERTY(BlueprintReadOnly) int32 AgeDays;
  UPROPERTY(BlueprintReadOnly) bool bIsAdult;
  UPROPERTY(BlueprintReadOnly) bool bIsPregnant;
  UPROPERTY(BlueprintReadOnly) float Hunger;        // 0–1
  UPROPERTY(BlueprintReadOnly) float Thirst;        // 0–1

  // Parents
  UPROPERTY() AAnimalBase* Mother;
  UPROPERTY() AAnimalBase* Father; // null if asexual

  // Components
  UPROPERTY() ULifeCycleComponent* LifeCycleComp;
  UPROPERTY() UBehaviorComponent* BehaviorComp;
  UPROPERTY() UReproductionComponent* ReproComp;

  virtual void BeginPlay() override;
  virtual void Tick(float Delta) override;
};`

**Key Modules (as ActorComponents)**
 • `ULifeCycleComponent`
    – Tracks `Age`, flips `bIsAdult`, kills at `MaxLifespan`

- `UReproductionComponent` – When adult & conditions met (`bHasMateNearby`, resource levels, season), spawns child Actors via `AEcosystemManager->SpawnAnimal()`
- `UBehaviorComponent` – Implements simple state-machine: Forage, Hunt (if carnivore), Flee, Patrol Nest, Sleep

## 3. Blueprint Patterns

3.1   Spawning Children
• In Blueprint: call `Event Custom: OnCanReproduce` → `Spawn Animal Actor from Class` with same `SpeciesID` → set `Mother/Father` → register with `EcosystemManager`

3.2   Environment Queries (EQS)
• Use EQS to find suitable patch volumes by `PreferredEnvTags` → returns array of `FVector` → move there to forage, nest, birth

3.3   Population Control
• On reproduction, `EcosystemManager` checks:

blueprint

`if (PopulationOfSpecies < MaxPerArea && TotalPlantsNearby > LitterSize) AllowBirth;
else DelayNextBirth();`

3.4   Tracking Death & Overpopulation
• On death (`Health<=0` or old age), unregister from manager
• Manager periodically runs logistic growth check:

math

`NewCarryingCapacity = BaseCap * (1 – (CurrentPop / HabitatCap));`

- If `CurrentPop > HabitatCap`, increase Hunger/Thirst depletion rate

## 4. Habitat & Resources

4.1   Plant & Matter/Energy Eaters
• Create `AResourceNode` Actors (e.g., berry bush, magical ley line) with `GRR_ResourceComponent` storing `ResourceAmount`
• Herbivores query nearest nodes via EQS, consume resource → node’s `ResourceAmount -= IntakeRate`

4.2   Predator-Prey Links
• On spawn, each animal’s `BehaviorComp` can register into manager’s Kd-tree or `TMap<SpeciesID, TArray<AAnimalBase*>>`
• When hunting: `EQS_FindClosest(PreySpeciesID)` → chase & attack

## 5. Performance & Tuning

- **Tick Group**: move heavy updates into `TCAsyncTask` or `FTSTicker` every few seconds
• **Spatial Partitioning**: subdivide world into `UGridSubsystem` for localized pop checks
• **LOD**: beyond `X` meters, switch to crowd-boids or disable behaviors

## 6. In-Game Bestiary UI

- On first encounter, snapshot `SpeciesDataRow` into a save-game table
• Display traits: – ReproType, Diet, Lifespan, Aggression, ParentalCare
• Show live stats: current population vs. carrying capacity

## 7. Free 5.6-Specific Learning Links

- C++ ActorComponent Patterns:
• EQS for Ecology:
• Population & Logistics Tutorial (community):
• Behavior Trees w/ dynamic targets:
• DataTables & CSV import:
• VR Performance (for many Actors):

    https://docs.unrealengine.com/5.0/en-US/creating-actors-and-components-in-unreal-engine/

    https://dev.epicgames.com/documentation/en-us/unreal-engine/environment-query-system

    https://kumiyama.com/unreal-ecosystem-tutorial/

    https://docs.unrealengine.com/5.0/en-US/behavior-tree-overview-in-unreal-engine/

    https://docs.unrealengine.com/5.0/en-US/working-with-tables-in-unreal-engine/

    https://www.unrealengine.com/en-US/onlinelearning-courses/optimizing-your-game-for-performance


By combining a **data-driven** species database, a **manager** to oversee births/deaths, and **modular components** for lifecycle, reproduction and behavior, you’ll end up with a truly organic ecosystem—one that can collapse, explode or self-regulate based on in-world conditions.

[3.5.1.1.1 Species Data](03_05_01_01_01_00_00__species-data.md)
