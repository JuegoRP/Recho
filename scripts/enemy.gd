extends CharacterBody2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player_group")
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var base_movement_speed: float = 40.0
@export var movement_speed_variation: float = 10.0
@export var max_hp: int = 20
@export var xp_reward: int = 8
@export var resonance_reward: int = 3
@export var entity_type: String = "basic"  # basic, architect, resonator, silent

# Resonance Pulse
@export var pulse_frequency: float = 1.0  # Seconds between pulses
var time_since_last_pulse: float = 0.0

var hp: int
var movement_speed: float
var is_dead: bool = false

func _ready() -> void:
	add_to_group("enemy_group")
	hp = max_hp
	movement_speed = base_movement_speed + randf_range(-movement_speed_variation, movement_speed_variation)
	# Randomize start phase so not all enemies pulse at the same time
	time_since_last_pulse = randf_range(0, pulse_frequency)

func _physics_process(delta) -> void:
	if is_dead or player == null:
		return
	
	# Update pulse timer
	time_since_last_pulse += delta
	if time_since_last_pulse >= pulse_frequency:
		trigger_pulse()

	move_to_player()

func trigger_pulse() -> void:
	time_since_last_pulse = 0.0
	# Visual feedback for the pulse
	var tween = create_tween()
	tween.tween_property(animated_sprite_2d, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(animated_sprite_2d, "scale", Vector2(1.0, 1.0), 0.2)
	# You could also add a ring effect or audio cue here later

func get_pulse_progress() -> float:
	# Returns 0.0 to 1.0 based on how close we are to the NEXT pulse
	return time_since_last_pulse / pulse_frequency

func take_damage(amount: int, is_perfect_hit: bool = false) -> void:
	if is_dead:
		return
	hp -= amount
	# Flash effect
	if is_perfect_hit:
		modulate = Color(1, 1, 0) # Gold flash for perfect
		# Create a visual splash or text (TODO)
	else:
		modulate = Color(1, 0.3, 0.3)
	
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	if hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	if player and player.has_method("gain_xp"):
		player.gain_xp(xp_reward)
	Inventory.add_resonance(resonance_reward)
	RechoEvents.entity_killed.emit(entity_type)
	queue_free()

func _on_hurt_box_hurt(damage: int) -> void:
	take_damage(damage)
