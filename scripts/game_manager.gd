extends Node

var player: Node = null

# Resonance Integrity (as per GDD)
var resonance_integrity: float = 1.0 # 1.0 = 100%
var total_deaths: int = 0

var all_upgrades = [
	{"id": "glass_stabilizer", "name": "Glass Stabilizer", "desc": "Ascence fragment: +Damage, -Cooldown", "icon": "⬡", "faction": "ascence"},
	{"id": "glitch_trigger", "name": "Glitch Trigger", "desc": "Entropy fragment: ++Damage, --HP", "icon": "♪", "faction": "entropy"},
	{"id": "harmonic_core", "name": "Harmonic Core", "desc": "Symphony fragment: +Speed, +Range", "icon": "✦", "faction": "symphony"},
]

func _ready() -> void:
	add_to_group("game_manager")
	call_deferred("find_player")
	RechoEvents.player_died.connect(_on_player_died)

func find_player() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player_group")
	if player:
		player.connect("level_up", _on_player_level_up)
		# Start intro quest
		QuestManager.start_quest("intro_awaken")

func _on_player_died() -> void:
	total_deaths += 1
	resonance_integrity -= 0.1 # Every death costs 10% integrity
	resonance_integrity = clamp(resonance_integrity, 0.0, 1.0)
	
	print("Player died. Total deaths: ", total_deaths, " Integrity: ", resonance_integrity)
	
	if resonance_integrity <= 0.6:
		print("Tuner is starting to glitch...")
	if resonance_integrity <= 0.2:
		print("Tuner is cracked.")

func _on_player_level_up(new_level: int) -> void:
	get_tree().paused = true
	await get_tree().process_frame
	var upgrade_ui = get_tree().get_first_node_in_group("upgrade_ui")
	if upgrade_ui:
		upgrade_ui.show_upgrades(get_random_upgrades(3))

func get_random_upgrades(count: int) -> Array:
	var upgrades = all_upgrades.duplicate()
	upgrades.shuffle()
	return upgrades.slice(0, min(count, upgrades.size()))

func apply_upgrade(upgrade_id: String) -> void:
	# In the new Socket system, applying an upgrade means finding an empty socket
	for i in range(Inventory.sockets.size()):
		if Inventory.sockets[i] == "":
			Inventory.socket_fragment(upgrade_id, i)
			break
	
	get_tree().paused = false
