extends Node

var is_paused: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		toggle_pause()

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	# Trigger a signal for UI to show/hide pause menu
	RechoEvents.game_paused.emit(is_paused)
