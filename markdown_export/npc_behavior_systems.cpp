// === SYSTEM 1: Tactical Autonomy in Combat ===

// PersonalityComponent.h
UENUM(BlueprintType)
enum class EPersonalityType : uint8 {
    Brave, Cautious, Selfish, Protective
};

UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class YOURGAME_API UPersonalityComponent : public UActorComponent {
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    EPersonalityType PersonalityType;
};

// AIController_Companion.cpp (snippet)
void AAIController_Companion::DecideCombatAction() {
    if (!PersonalityComp) return;

    switch (PersonalityComp->PersonalityType) {
        case EPersonalityType::Brave:
            EngageClosestEnemy();
            break;
        case EPersonalityType::Cautious:
            MoveToCover();
            break;
        case EPersonalityType::Selfish:
            if (LootNearby()) Loot();
            else DelayCombat();
            break;
        case EPersonalityType::Protective:
            MoveToProtectAlly();
            break;
    }
}

// === SYSTEM 2: Relationship & Downtime System ===

// RelationshipComponent.h
USTRUCT(BlueprintType)
struct FRelationshipStatus {
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    AActor* Target;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    float Affinity; // Range -100 to 100
};

UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class YOURGAME_API URelationshipComponent : public UActorComponent {
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    TArray<FRelationshipStatus> Relationships;

    float GetAffinityTo(AActor* Other);
};

// CompanionCharacter.cpp (snippet)
void ACompanionCharacter::HandleCampBehavior() {
    switch (CurrentMood) {
        case EMood::Relaxed:
            PlayAnimation("WriteJournal");
            break;
        case EMood::Restless:
            PatrolCampArea();
            break;
        case EMood::Angry:
            IsolateFromGroup();
            break;
    }

    if (ShouldStartConversation())
        StartCampDialogue();
}

// === SYSTEM 3: Dialogue & Emotional Engine ===

// EmotionComponent.h
UENUM(BlueprintType)
enum class EMood : uint8 {
    Relaxed, Restless, Depressed, Angry, Inspired
};

UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class YOURGAME_API UEmotionComponent : public UActorComponent {
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    EMood CurrentMood;
};

// DialogueManager.cpp (snippet)
TArray<FString> UDialogueManager::GetAvailableDialogue(AActor* NPC, AActor* Player) {
    auto EmotionComp = NPC->FindComponentByClass<UEmotionComponent>();
    auto RelationComp = NPC->FindComponentByClass<URelationshipComponent>();

    float Affinity = RelationComp->GetAffinityTo(Player);
    EMood Mood = EmotionComp->CurrentMood;

    TArray<FString> Lines;

    if (Affinity > 50 && Mood == EMood::Relaxed) {
        Lines.Add("Hey, thanks for always having my back.");
    } else if (Affinity < -50 && Mood == EMood::Angry) {
        Lines.Add("Why are you even talking to me?");
    } else {
        Lines.Add("We should keep moving.");
    }

    return Lines;
}
