extends CharacterBody2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player_group")
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var base_movement_speed: float = 40.0
@export var movement_speed_variation: float = 10.0
@export var max_hp: int = 20
@export var xp_reward: int = 8
@export var resonance_reward: int = 3
@export var entity_type: String = "basic"  # basic, architect, resonator, silent

var hp: int
var movement_speed: float
var is_dead: bool = false

func _ready() -> void:
	add_to_group("enemy_group")
	hp = max_hp
	movement_speed = base_movement_speed + randf_range(-movement_speed_variation, movement_speed_variation)

func _physics_process(_delta) -> void:
	if is_dead or player == null:
		return
	move_to_player()

func move_to_player() -> void:
	var direction: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	move_and_slide()
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
	elif direction.x > 0:
		animated_sprite_2d.flip_h = false

func take_damage(amount: int) -> void:
	if is_dead:
		return
	hp -= amount
	# Flash efekt
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
	PaletaEvents.entity_killed.emit(entity_type)
	queue_free()

func _on_hurt_box_hurt(damage: int) -> void:
	take_damage(damage)
