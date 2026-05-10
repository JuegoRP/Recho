## Combat Manager pro Paletu
## Real-time boj s mechanikou tří stylů (Architect, Resonator, Silent)
extends Node

signal combat_started
signal combat_ended(victory: bool)
signal player_attacked(damage: int, style: String)
signal enemy_attacked(damage: int)

enum AttackStyle { ARCHITECT, RESONATOR, SILENT }

var current_style: AttackStyle = AttackStyle.RESONATOR
var combo_count: int = 0
var last_attack_time: float = 0.0
var rhythm_window: float = 0.6  # sekundy pro Resonator rytmus

# Statistiky útoku podle stylu
const STYLE_DATA = {
	AttackStyle.ARCHITECT: {
		"name": "Architektonický",
		"base_damage": 20,
		"cooldown": 1.2,
		"special": "barrier"   # vytvoří bariéru
	},
	AttackStyle.RESONATOR: {
		"name": "Rezonační",
		"base_damage": 12,
		"cooldown": 0.5,
		"special": "rhythm"    # násobič při rytmu
	},
	AttackStyle.SILENT: {
		"name": "Tichý",
		"base_damage": 0,
		"cooldown": 0.0,
		"special": "patience"  # entita se ničí sama
	}
}

func set_style(style: AttackStyle) -> void:
	current_style = style
	combo_count = 0

func calculate_damage() -> int:
	var base = STYLE_DATA[current_style]["base_damage"]
	
	match current_style:
		AttackStyle.RESONATOR:
			# Rytmický bonus
			var time_since_last = Time.get_ticks_msec() / 1000.0 - last_attack_time
			if time_since_last <= rhythm_window and combo_count > 0:
				combo_count += 1
				base = int(base * (1.0 + combo_count * 0.2))
			else:
				combo_count = 1
		AttackStyle.ARCHITECT:
			base = int(base * (1.0 + combo_count * 0.1))
			combo_count += 1
		AttackStyle.SILENT:
			base = 0
	
	last_attack_time = Time.get_ticks_msec() / 1000.0
	return base

func get_style_name() -> String:
	return STYLE_DATA[current_style]["name"]

func get_current_style() -> AttackStyle:
	return current_style
