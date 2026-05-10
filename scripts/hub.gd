extends Node2D

@onready var elder = get_node_or_null("NPC_Elder")

func _ready() -> void:
	AudioManager.play_music("res://audio/music/hub_ambient.mp3")
	# Krátká prodleva na načtení všeho
	await get_tree().create_timer(1.5).timeout
	start_intro_dialogue()

func start_intro_dialogue() -> void:
	if elder:
		print("Hub: NPC_Elder found, attempting to start dialogue...")
		elder.start_dialogue()
	else:
		push_error("Hub: NPC_Elder NOT FOUND in Hub scene! Check node name in editor.")
