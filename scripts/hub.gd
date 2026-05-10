extends Node2D

@onready var player = $player
@onready var elder = $NPC_Elder

func _ready() -> void:
	# According to GDD: "The Tuner awakens. Elder says: 'Do you feel the disharmony?'"
	# We can trigger the intro quest/dialogue here.
	if elder:
		elder.dialogue_file = "res://dialogue/elder_intro.dialogue"
		elder.dialogue_start = "intro_awaken"
		# Small delay to let the player realize where they are
		await get_tree().create_timer(1.0).timeout
		elder.start_dialogue()

func _on_arena_selected(arena_path: String) -> void:
	# This would be called when the player chooses an arena from the Elder's menu or a portal
	get_tree().change_scene_to_file(arena_path)
