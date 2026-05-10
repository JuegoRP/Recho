extends Control

func _ready() -> void:
	AudioManager.play_music("res://audio/music/hub_ambient.mp3")
	pass

func _on_start_pressed() -> void:
	# Explicitly using the verified path in scenes/arenas/
	var hub_path = "res://scenes/arena_hub.tscn"
	if FileAccess.file_exists(hub_path):
		get_tree().change_scene_to_file(hub_path)
	else:
		push_error("Could not find arena_hub.tscn at: " + hub_path)

func _on_exit_pressed() -> void:
	get_tree().quit()
