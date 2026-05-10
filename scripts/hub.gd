extends Node2D

@onready var player = $player
@onready var elder = $NPC_Elder

func _ready() -> void:
	AudioManager.play_music("res://audio/music/hub_ambient.mp3")
	if elder:
		elder.dialogue_file = "res://dialogue/elder_intro.dialogue"
		elder.dialogue_start = "intro_awaken"
		await get_tree().create_timer(1.0).timeout
		elder.start_dialogue()
	
	RechoEvents.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended() -> void:
	# After the first talk, maybe show a portal or just send them in
	print("Dialogue ended. Preparing for transition...")
	await get_tree().create_timer(1.0).timeout
	enter_first_arena()

func enter_first_arena() -> void:
	get_tree().change_scene_to_file("res://scenes/arenas/arena_01_cathedral.tscn")
