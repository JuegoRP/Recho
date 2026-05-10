extends Node

func _ready() -> void:
	call_deferred("connect_signals")

func connect_signals() -> void:
	var player = get_tree().get_first_node_in_group("player_group")
	if player:
		player.connect("hp_changed", _on_hp_changed)
		player.connect("xp_changed", _on_xp_changed)
		player.connect("level_up", _on_level_up)
		_on_hp_changed(player.hp, player.max_hp)
		_on_xp_changed(player.xp, player.xp_to_next_level)
	
	# Resonance from system
	if Inventory:
		Inventory.resonance_changed.connect(_on_resonance_changed)
		_on_resonance_changed(Inventory.resonance)
	
	if RechoEvents:
		RechoEvents.quest_started.connect(_on_quest_started)
		RechoEvents.quest_completed.connect(_on_quest_completed)

func _find(name: String) -> Node:
	return get_tree().root.find_child(name, true, false)

func _on_hp_changed(current: int, maximum: int) -> void:
	var bar = _find("HPBar")
	if bar:
		bar.max_value = maximum
		bar.value = current
	var label = _find("HPLabel")
	if label:
		label.text = "HP %d/%d" % [current, maximum]

func _on_xp_changed(current: int, needed: int) -> void:
	var bar = _find("XPBar")
	if bar:
		bar.max_value = needed
		bar.value = current

func _on_level_up(new_level: int) -> void:
	var label = _find("LevelLabel")
	if label:
		label.text = "Level " + str(new_level)

func _on_resonance_changed(amount: int) -> void:
	var label = _find("GoldLabel")
	if label:
		label.text = "✦ Resonance: " + str(amount)

func _on_quest_started(quest_id: String) -> void:
	var label = _find("QuestLabel")
	if label:
		label.text = "Quest: " + QuestManager.get_quest_title(quest_id)
		label.visible = true

func _on_quest_completed(quest_id: String) -> void:
	var label = _find("QuestLabel")
	if label:
		label.text = "✓ " + QuestManager.get_quest_title(quest_id)
		await get_tree().create_timer(3.0).timeout
		label.text = ""
