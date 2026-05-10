extends Node2D

@export var arena_name: String = "Cathedral of Silence"
@export var resonance_goal: int = 100
@export var contagion_level: float = 0.0 # 0.0 to 1.0

var current_resonance: int = 0

func _ready() -> void:
	AudioManager.play_music("res://audio/music/arena_cathedral.mp3")
	RechoEvents.entity_killed.connect(_on_entity_killed)
	print("Entered Arena: ", arena_name)
	# Set up environment based on contagion
	apply_contagion_effects()

func _on_entity_killed(_type: String) -> void:
	current_resonance += 10 # Each kill gives some resonance
	if current_resonance >= resonance_goal:
		complete_arena()

func apply_contagion_effects() -> void:
	if contagion_level > 0.5:
		# Visual distortion (TODO: Shader)
		modulate = Color(1.2, 0.8, 0.8) # Reddish tint
	
	# Stronger enemies if contagion is high
	var enemies = get_tree().get_nodes_in_group("enemy_group")
	for enemy in enemies:
		if enemy.has_method("buff_from_contagion"):
			enemy.buff_from_contagion(contagion_level)

func complete_arena() -> void:
	print("Arena Complete: ", arena_name)
	RechoEvents.area_changed.emit("hub")
	# Portal back to hub (TODO: Visual)
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/arenas/arena_hub.tscn")
