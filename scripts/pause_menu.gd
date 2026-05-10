extends Control

func _ready() -> void:
	visible = false
	RechoEvents.game_paused.connect(_on_game_paused)

func _on_game_paused(paused: bool) -> void:
	visible = paused

func _on_resume_pressed() -> void:
	PauseManager.toggle_pause()

func _on_settings_pressed() -> void:
	var settings = get_tree().root.find_child("SettingsMenu", true, false)
	if settings:
		settings.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()
