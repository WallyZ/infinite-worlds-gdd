# 1.3.6 Sample Pseudocode for a Legacy Trigger System

```
function HandlePlayerDeath(PlayerCharacter):
		LogDeathLocation(PlayerCharacter.Position)
		SaveInventoryToWorld(PlayerCharacter.Inventory)

foreach (NPC in World):
    if NPC has RelationshipWith(PlayerCharacter):
        NPC.Memory.LogEvent("PlayerDied", EmotionalWeight, Context)
        UpdateNPCDialogue(NPC)

WorldMemory.RegisterLegacyEvent(PlayerCharacter, CauseOfDeath, NotableActions)

if HeroicDeath:
    SpawnStatueAtLocation(PlayerCharacter.Position)
    TriggerFestivalEventInLinkedTowns()

```