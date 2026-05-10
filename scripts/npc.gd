extends CharacterBody2D

@export var npc_name: String = "Elder"
@export var dialogue_file: String = "res://dialogue/elder_intro.dialogue"
@export var dialogue_start: String = "intro_awaken"

@onready var label: Label = $Label
@onready var interaction_area: Area2D = $InteractionArea

var player_nearby: bool = false

func _ready() -> void:
	add_to_group("npc_group")
	if label:
		label.text = "[E] " + npc_name
		label.visible = false

func play_voice() -> void:
	AudioManager.play_sfx("res://audio/sfx/elder_voice.mp3")

func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("interact"):
		start_dialogue()

func start_dialogue() -> void:
	print("NPC: start_dialogue() called.")
	var file_path = "res://dialogue/elder_intro.dialogue"
	var dm = get_node_or_null("/root/DialogueManager")
	
	if dm == null:
		push_error("NPC: DialogueManager is missing! Check Autoload.")
		return
		
	var resource = load(file_path)
	if resource == null:
		push_error("NPC: Failed to load dialogue: " + file_path)
		return
		
	print("NPC: Dialogue balloon shown.")
	dm.show_dialogue_balloon(resource, dialogue_start)
	RechoEvents.dialogue_started.emit(npc_name)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_nearby = true
		if label:
			label.visible = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_group"):
		player_nearby = false
		if label:
			label.visible = false
