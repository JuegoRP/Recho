extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var SPEED: float = 200.0

# HP
var max_hp: int = 100
var hp: int = 100

# XP + leveling
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 20

# Combat
var attack_cooldown: float = 0.0
var attack_range: float = 60.0
var is_attacking: bool = false
var attack_style: int = 1  # 0=Architect, 1=Resonator, 2=Silent

# Stats modified by Fragments/Synergies
var stat_mods: Dictionary = {
	"damage_mult": 1.0,
	"cooldown_mult": 1.0,
	"speed_mult": 1.0,
	"range_mult": 1.0,
	"hp_mult": 1.0
}

# UI Signals
signal hp_changed(current: int, maximum: int)
signal xp_changed(current: int, needed: int)
signal level_up(new_level: int)
signal player_died
signal attack_performed(damage: int, style: String)
signal interactable_found(obj)
signal interactable_lost

var nearby_interactable = null

func _ready() -> void:
	add_to_group("player_group")
	emit_signal("hp_changed", hp, max_hp)
	emit_signal("xp_changed", xp, xp_to_next_level)
	Inventory.sockets_updated.connect(recalculate_stats)
	recalculate_stats()

func recalculate_stats() -> void:
	# Reset mods
	for key in stat_mods.keys():
		stat_mods[key] = 1.0
	
	# Apply Fragment stats
	for frag_id in Inventory.sockets:
		if Inventory.FRAGMENT_DATA.has(frag_id):
			var stats = Inventory.FRAGMENT_DATA[frag_id].stats
			for stat_key in stats.keys():
				if stat_mods.has(stat_key):
					stat_mods[stat_key] += stats[stat_key]
	
	# Apply Synergies
	var synergies = Inventory.get_active_synergies()
	for syn in synergies:
		match syn:
			"entropy_overload":
				stat_mods["damage_mult"] += 1.0
				stat_mods["hp_mult"] -= 0.5
			"ascence_stasis":
				stat_mods["cooldown_mult"] -= 0.3
			"grand_harmony":
				stat_mods["speed_mult"] += 0.5
	
	# Apply visual corruption based on dominant faction
	update_visual_corruption()

func update_visual_corruption() -> void:
	var counts = Inventory.faction_counts
	if counts["entropy"] > counts["ascence"] and counts["entropy"] > counts["symphony"]:
		modulate = Color(1.2, 0.8, 1.2) # Entropy Glitch (Purple-ish)
	elif counts["ascence"] > counts["entropy"] and counts["ascence"] > counts["symphony"]:
		modulate = Color(0.8, 1.0, 1.2, 0.7) # Ascence Glass (Transparent Blue)
	elif counts["symphony"] > counts["entropy"] and counts["symphony"] > counts["ascence"]:
		modulate = Color(1.2, 1.1, 0.8) # Symphony Gold
	else:
		modulate = Color(1, 1, 1, 1)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()

	# Attack
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0:
		perform_attack()

	# Interakce
	if Input.is_action_just_pressed("interact") and nearby_interactable:
		nearby_interactable.interact()

	# Switch style (1,2,3)
	if Input.is_action_just_pressed("ui_accept"):  # placeholder
		attack_style = (attack_style + 1) % 3

	handle_movement()

func handle_movement() -> void:
	var input_direction: Vector2 = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))
	velocity = input_direction.normalized() * SPEED * stat_mods["speed_mult"]
	move_and_slide()
	update_animation(input_direction)

func update_animation(input_direction: Vector2) -> void:
	if velocity == Vector2.ZERO:
		animated_sprite_2d.animation = "idle"
	else:
		animated_sprite_2d.animation = "walk"
	if input_direction.x < 0:
		animated_sprite_2d.flip_h = true
	elif input_direction.x > 0:
		animated_sprite_2d.flip_h = false

func perform_attack() -> void:
	var style_names = ["architect", "resonator", "silent"]
	var base_damages = [20, 12, 0]
	var cooldowns = [1.2, 0.5, 0.0]

	var base_damage = base_damages[attack_style] * stat_mods["damage_mult"]
	attack_cooldown = cooldowns[attack_style] * stat_mods["cooldown_mult"]
	var current_range = attack_range * stat_mods["range_mult"]

	# Find enemies in range
	var nearby = get_tree().get_nodes_in_group("enemy_group")
	for enemy in nearby:
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= current_range:
			var damage = base_damage
			var is_perfect = false

			# Calculate Resonance Pulse Timing
			if enemy.has_method("get_pulse_progress"):
				var progress = enemy.get_pulse_progress() # 0.0 is right after pulse, 1.0 is next pulse
				# We want to hit right at the pulse (0.0 or 1.0)
				var timing_diff = min(progress, 1.0 - progress)

				if timing_diff <= 0.1: # Perfect window
					damage = int(base_damage * 2.0)
					is_perfect = true
					RechoEvents.perfect_hit_performed.emit(enemy.global_position)
				elif timing_diff <= 0.25: # Good window
					damage = int(base_damage * 1.2)

			if enemy.has_method("take_damage"):
				enemy.take_damage(damage, is_perfect)

	emit_signal("attack_performed", base_damage, style_names[attack_style])
	is_attacking = true
	await get_tree().create_timer(0.2).timeout
	is_attacking = false

func _on_hurt_box_hurt(damage: int) -> void:
	hp -= damage
	hp = clamp(hp, 0, max_hp)
	emit_signal("hp_changed", hp, max_hp)
	RechoEvents.player_damaged.emit(damage)
	if hp <= 0:
		emit_signal("player_died")
		RechoEvents.player_died.emit()
		queue_free()

func gain_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = int(xp_to_next_level * 1.4)
		emit_signal("level_up", level)
	emit_signal("xp_changed", xp, xp_to_next_level)

func gain_gold(amount: int) -> void:
	Inventory.add_resonance(amount)

func upgrade_speed(amount: float) -> void:
	SPEED += amount

func upgrade_max_hp(amount: int) -> void:
	max_hp += amount
	hp += amount
	emit_signal("hp_changed", hp, max_hp)

func set_nearby_interactable(obj) -> void:
	nearby_interactable = obj
	emit_signal("interactable_found", obj)

func clear_nearby_interactable() -> void:
	nearby_interactable = null
	emit_signal("interactable_lost")
