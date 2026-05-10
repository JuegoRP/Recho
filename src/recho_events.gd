## Global event bus - connects distant scenes without direct references
extends Node

# --- PLAYER ---
signal player_died
signal player_healed(amount: int)
signal player_damaged(amount: int)

# --- COMBAT ---
signal combat_started(enemy_data: Dictionary)
signal combat_ended(victory: bool)
signal entity_killed(entity_name: String)
signal perfect_hit_performed(at_position: Vector2)

# --- QUEST ---
signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, step: int)
signal quest_completed(quest_id: String)

# --- DIALOGUE ---
signal dialogue_started(npc_name: String)
signal dialogue_ended

# --- WORLD ---
signal area_changed(area_name: String)
signal resonance_changed(amount: int)
signal game_paused(paused: bool)

# --- FACTIONS ---
signal faction_reputation_changed(faction: String, amount: int)
