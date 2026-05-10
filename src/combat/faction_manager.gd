## Faction Manager - manages reputation for three factions
extends Node

signal reputation_changed(faction: String, value: int)
signal faction_unlocked(faction: String)

enum Faction { ARCHITECTS, RESONATORS, SILENT }

# Reputation: -100 to 100
var reputation: Dictionary = {
	"architects": 0,
	"resonators": 0,
	"silent": 0
}

# What each faction offers in the shop
const FACTION_SHOPS = {
	"architects": {
		"items": ["architect_key"],
		"upgrades": ["barrier_upgrade", "pattern_mastery"],
		"min_reputation": 10
	},
	"resonators": {
		"items": ["resonator_song"],
		"upgrades": ["rhythm_bonus", "melody_shield"],
		"min_reputation": 10
	},
	"silent": {
		"items": [],
		"upgrades": ["patience_mastery", "void_walk"],
		"min_reputation": 20
	}
}

func change_reputation(faction: String, amount: int) -> void:
	if not reputation.has(faction):
		return
	reputation[faction] = clamp(reputation[faction] + amount, -100, 100)
	reputation_changed.emit(faction, reputation[faction])
	RechoEvents.faction_reputation_changed.emit(faction, reputation[faction])

func get_reputation(faction: String) -> int:
	return reputation.get(faction, 0)

func can_access_shop(faction: String) -> bool:
	var min_rep = FACTION_SHOPS.get(faction, {}).get("min_reputation", 0)
	return get_reputation(faction) >= min_rep

func get_faction_name(faction: String) -> String:
	match faction:
		"architects": return "Architects"
		"resonators": return "Resonators"
		"silent": return "Silent"
	return faction

func save() -> Dictionary:
	return {"reputation": reputation.duplicate()}

func load_data(data: Dictionary) -> void:
	reputation = data.get("reputation", {"architects": 0, "resonators": 0, "silent": 0})
