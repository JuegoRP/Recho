## Inventory system for RECHO
## Stores Fragments, Resonance (currency), and items
extends Node

signal item_added(item_id: String, amount: int)
signal item_removed(item_id: String, amount: int)
signal resonance_changed(total: int)
signal sockets_updated

# Resonance = main currency
var resonance: int = 0

# Equipped Fragments (The Socket System)
var sockets: Array = ["", "", "", ""] # Max 4 fragments drilled into the body
var faction_counts: Dictionary = {"ascence": 0, "entropy": 0, "symphony": 0}

# Items: { "item_id": amount }
var items: Dictionary = {}

# Fragment Definitions
const FRAGMENT_DATA = {
	"glass_stabilizer": {
		"name": "Glass Stabilizer",
		"faction": "ascence",
		"stats": {"damage_mult": 0.2, "cooldown_mult": -0.1},
		"desc": "Sterile purity. Stabilizes the shell."
	},
	"glitch_trigger": {
		"name": "Glitch Trigger",
		"faction": "entropy",
		"stats": {"damage_mult": 0.5, "hp_mult": -0.2},
		"desc": "Beautiful chaos. Hurts to use."
	},
	"harmonic_core": {
		"name": "Harmonic Core",
		"faction": "symphony",
		"stats": {"speed_mult": 0.2, "range_mult": 0.2},
		"desc": "A perfect tone. Repairs the world."
	}
}

func add_resonance(amount: int) -> void:
	resonance += amount
	resonance_changed.emit(resonance)
	RechoEvents.resonance_changed.emit(resonance)

func spend_resonance(amount: int) -> bool:
	if resonance < amount:
		return false
	resonance -= amount
	resonance_changed.emit(resonance)
	RechoEvents.resonance_changed.emit(resonance)
	return true

func socket_fragment(fragment_id: String, index: int) -> bool:
	if index < 0 or index >= sockets.size():
		return false
	
	# If something was there, remove it
	if sockets[index] != "":
		_update_faction_count(sockets[index], -1)
	
	sockets[index] = fragment_id
	if fragment_id != "":
		_update_faction_count(fragment_id, 1)
	
	sockets_updated.emit()
	return true

func _update_faction_count(fragment_id: String, change: int) -> void:
	if FRAGMENT_DATA.has(fragment_id):
		var faction = FRAGMENT_DATA[fragment_id].faction
		faction_counts[faction] += change
		RechoEvents.faction_reputation_changed.emit(faction, faction_counts[faction])

func get_active_synergies() -> Array:
	var synergies = []
	if faction_counts["entropy"] >= 3:
		synergies.append("entropy_overload")
	if faction_counts["ascence"] >= 3:
		synergies.append("ascence_stasis")
	if faction_counts["symphony"] >= 3:
		synergies.append("grand_harmony")
	
	# Balatro Moment: Mixed synergy
	if faction_counts["entropy"] >= 2 and faction_counts["symphony"] >= 1:
		synergies.append("unplanned_resonance")
	
	return synergies

func add_item(item_id: String, amount: int = 1) -> void:
	items[item_id] = items.get(item_id, 0) + amount
	item_added.emit(item_id, amount)

func has_item(item_id: String, amount: int = 1) -> bool:
	return items.get(item_id, 0) >= amount

func save() -> Dictionary:
	return {
		"resonance": resonance,
		"items": items.duplicate(),
		"sockets": sockets.duplicate()
	}

func load_data(data: Dictionary) -> void:
	resonance = data.get("resonance", 0)
	items = data.get("items", {})
	sockets = data.get("sockets", ["", "", "", ""])
	# Recalculate faction counts
	faction_counts = {"ascence": 0, "entropy": 0, "symphony": 0}
	for frag in sockets:
		if frag != "": _update_faction_count(frag, 1)
