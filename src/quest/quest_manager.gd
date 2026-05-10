## Quest system for RECHO
## Manages active quests, their progress and rewards
extends Node

signal quest_started(quest_id: String)
signal quest_step_completed(quest_id: String, step: int)
signal quest_completed(quest_id: String)

# Active quests: { "quest_id": { "step": 0, "data": {...} } }
var active_quests: Dictionary = {}
var completed_quests: Array = []

# Quest definitions
const QUESTS = {
	"intro_awaken": {
		"title": "Awakening",
		"faction": "none",
		"steps": [
			{"desc": "Find out what happened.", "type": "explore", "target": "village_center"},
			{"desc": "Talk to the first NPC.", "type": "talk", "target": "elder_npc"},
			{"desc": "Enter the first dungeon.", "type": "enter", "target": "dark_forest"},
		],
		"reward_resonance": 50,
		"reward_items": ["memory_echo"]
	},
	"architect_trial": {
		"title": "Architects' Trial",
		"faction": "architects",
		"steps": [
			{"desc": "Find the Architectural symbol.", "type": "collect", "target": "arch_symbol"},
			{"desc": "Create a pattern from symbols.", "type": "interact", "target": "pattern_altar"},
			{"desc": "Defeat the Pattern Guardian.", "type": "kill", "target": "pattern_guardian"},
		],
		"reward_resonance": 100,
		"reward_items": ["architect_key"],
		"reward_faction": {"architects": 20}
	},
	"resonator_song": {
		"title": "Lost Melody",
		"faction": "resonators",
		"steps": [
			{"desc": "Hear the echo in the dungeon.", "type": "explore", "target": "echo_chamber"},
			{"desc": "Collect melody fragments.", "type": "collect_multi", "target": "melody_fragment", "count": 3},
			{"desc": "Play the melody at the altar.", "type": "interact", "target": "melody_altar"},
		],
		"reward_resonance": 100,
		"reward_items": ["resonator_song"],
		"reward_faction": {"resonators": 20}
	}
}

func start_quest(quest_id: String) -> bool:
	if not QUESTS.has(quest_id):
		push_warning("Unknown quest: " + quest_id)
		return false
	if active_quests.has(quest_id) or completed_quests.has(quest_id):
		return false
	
	active_quests[quest_id] = {"step": 0}
	quest_started.emit(quest_id)
	RechoEvents.quest_started.emit(quest_id)
	print("Quest started: ", QUESTS[quest_id]["title"])
	return true

func advance_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	
	var quest_data = QUESTS[quest_id]
	var current_step = active_quests[quest_id]["step"]
	current_step += 1
	active_quests[quest_id]["step"] = current_step
	
	quest_step_completed.emit(quest_id, current_step)
	RechoEvents.quest_updated.emit(quest_id, current_step)
	
	if current_step >= quest_data["steps"].size():
		complete_quest(quest_id)

func complete_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	
	var quest_data = QUESTS[quest_id]
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)
	
	# Give rewards
	Inventory.add_resonance(quest_data.get("reward_resonance", 0))
	for item in quest_data.get("reward_items", []):
		Inventory.add_item(item)
	
	quest_completed.emit(quest_id)
	RechoEvents.quest_completed.emit(quest_id)
	print("Quest completed: ", quest_data["title"])

func get_active_quest_step(quest_id: String) -> Dictionary:
	if not active_quests.has(quest_id):
		return {}
	var step_idx = active_quests[quest_id]["step"]
	var steps = QUESTS[quest_id]["steps"]
	if step_idx >= steps.size():
		return {}
	return steps[step_idx]

func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

func get_quest_title(quest_id: String) -> String:
	return QUESTS.get(quest_id, {}).get("title", quest_id)
