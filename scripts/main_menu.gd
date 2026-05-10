extends Control

func _ready() -> void:
	AudioManager.play_music("res://audio/music/hub_ambient.mp3")
	pass

func _on_start_pressed() -> void:
	# Transition to the Hub
	get_tree().change_scene_to_file("res://scenes/arenas/arena_hub.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
