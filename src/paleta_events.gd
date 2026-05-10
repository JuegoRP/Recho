## Globální event bus - spojuje vzdálené scény bez přímých referencí
extends Node

# --- HRÁČ ---
signal player_died
signal player_healed(amount: int)
signal player_damaged(amount: int)

# --- COMBAT ---
signal combat_started(enemy_data: Dictionary)
signal combat_ended(victory: bool)
signal entity_killed(entity_name: String)

# --- QUEST ---
signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, step: int)
signal quest_completed(quest_id: String)

# --- DIALOGUE ---
signal dialogue_started(npc_name: String)
signal dialogue_ended

# --- SVĚT ---
signal area_changed(area_name: String)
signal resonance_changed(amount: int)

# --- FRAKCE ---
signal faction_reputation_changed(faction: String, amount: int)
