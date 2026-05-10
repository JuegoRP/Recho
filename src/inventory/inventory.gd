## Inventory systém pro Paletu
## Uchovává předměty, Resonance (měnu) a vybavení
extends Node

signal item_added(item_id: String, amount: int)
signal item_removed(item_id: String, amount: int)
signal resonance_changed(total: int)
signal equipment_changed(slot: String, item_id: String)

# Resonance = hlavní měna
var resonance: int = 0

# Předměty: { "item_id": amount }
var items: Dictionary = {}

# Vybavení: { "weapon": "", "armor": "", "accessory": "" }
var equipment: Dictionary = {
	"weapon": "",
	"armor": "",
	"accessory": ""
}

# Definice předmětů
const ITEM_DATA = {
	"resonance_shard": {
		"name": "Fragment Rezonance",
		"desc": "Kousek energie zanechaný entitou.",
		"icon": "✦",
		"stackable": true
	},
	"memory_echo": {
		"name": "Ozvěna vzpomínky",
		"desc": "Fragment minulosti. Frakce za ni zaplatí.",
		"icon": "◈",
		"stackable": true
	},
	"architect_key": {
		"name": "Klíč Architektů",
		"desc": "Otevírá jejich skryté místnosti.",
		"icon": "⬡",
		"stackable": false
	},
	"resonator_song": {
		"name": "Píseň Rezonátorů",
		"desc": "Uložená melodie. Použij v boji.",
		"icon": "♪",
		"stackable": true
	},
}

func add_resonance(amount: int) -> void:
	resonance += amount
	resonance_changed.emit(resonance)
	PaletaEvents.resonance_changed.emit(resonance)

func spend_resonance(amount: int) -> bool:
	if resonance < amount:
		return false
	resonance -= amount
	resonance_changed.emit(resonance)
	PaletaEvents.resonance_changed.emit(resonance)
	return true

func add_item(item_id: String, amount: int = 1) -> void:
	if not ITEM_DATA.has(item_id):
		push_warning("Unknown item: " + item_id)
		return
	items[item_id] = items.get(item_id, 0) + amount
	item_added.emit(item_id, amount)

func remove_item(item_id: String, amount: int = 1) -> bool:
	if items.get(item_id, 0) < amount:
		return false
	items[item_id] -= amount
	if items[item_id] <= 0:
		items.erase(item_id)
	item_removed.emit(item_id, amount)
	return true

func has_item(item_id: String, amount: int = 1) -> bool:
	return items.get(item_id, 0) >= amount

func get_item_count(item_id: String) -> int:
	return items.get(item_id, 0)

func equip(slot: String, item_id: String) -> void:
	if equipment.has(slot):
		equipment[slot] = item_id
		equipment_changed.emit(slot, item_id)

func get_item_name(item_id: String) -> String:
	return ITEM_DATA.get(item_id, {}).get("name", item_id)

func save() -> Dictionary:
	return {
		"resonance": resonance,
		"items": items.duplicate(),
		"equipment": equipment.duplicate()
	}

func load_data(data: Dictionary) -> void:
	resonance = data.get("resonance", 0)
	items = data.get("items", {})
	equipment = data.get("equipment", {"weapon": "", "armor": "", "accessory": ""})
