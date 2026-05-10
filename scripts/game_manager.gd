extends Node

var player: Node = null

var all_upgrades = [
	{"id": "speed", "name": "Rychlé nohy", "desc": "Pohyb +30", "icon": "⚡", "faction": "none"},
	{"id": "max_hp", "name": "Železné srdce", "desc": "Max HP +25", "icon": "❤", "faction": "none"},
	{"id": "attack_range", "name": "Dlouhé paže", "desc": "Dosah útoku +20", "icon": "⚔", "faction": "none"},
	{"id": "architect_style", "name": "Architektonická síla", "desc": "Pomalý ale těžký útok", "icon": "⬡", "faction": "architects"},
	{"id": "resonator_rhythm", "name": "Rytmus Rezonátoru", "desc": "Rychlé combo útoky", "icon": "♪", "faction": "resonators"},
	{"id": "silent_patience", "name": "Tiché čekání", "desc": "Nepřátelé zpomalí o 30%", "icon": "◌", "faction": "silent"},
]

func _ready() -> void:
	add_to_group("game_manager")
	call_deferred("find_player")

func find_player() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player_group")
	if player:
		player.connect("level_up", _on_player_level_up)
		# Spusť intro quest
		QuestManager.start_quest("intro_awaken")

func _on_player_level_up(new_level: int) -> void:
	get_tree().paused = true
	await get_tree().process_frame
	var upgrade_ui = get_tree().get_first_node_in_group("upgrade_ui")
	if upgrade_ui:
		upgrade_ui.show_upgrades(get_random_upgrades(3))

func get_random_upgrades(count: int) -> Array:
	var shuffled = all_upgrades.duplicate()
	shuffled.shuffle()
	return shuffled.slice(0, min(count, shuffled.size()))

func apply_upgrade(upgrade_id: String) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player_group")
	match upgrade_id:
		"speed":
			if player: player.upgrade_speed(30.0)
		"max_hp":
			if player: player.upgrade_max_hp(25)
		"attack_range":
			if player: player.attack_range += 20.0
		"architect_style":
			if player: player.attack_style = 0
		"resonator_rhythm":
			if player: player.attack_style = 1
		"silent_patience":
			# Zpomal všechny nepřátele
			for enemy in get_tree().get_nodes_in_group("enemy_group"):
				enemy.base_movement_speed *= 0.7
	get_tree().paused = false
