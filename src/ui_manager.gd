extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var pause_menu = load("res://scenes/pause_menu.tscn").instantiate()
	var settings_menu = load("res://scenes/settings_menu.tscn").instantiate()
	
	# Přidání do rootu, aby menu přežila změnu scén
	get_tree().root.call_deferred("add_child", pause_menu)
	get_tree().root.call_deferred("add_child", settings_menu)
