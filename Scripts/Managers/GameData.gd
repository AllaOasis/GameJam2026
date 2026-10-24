extends Node

signal player_death

# Cheats - Future Update
var toxinImmunity: bool = false
var damageImunity: bool = false

# Level Data
var level_toxins: int = 0
var current_toxins: int = 0
var game_won: bool = false
var is_player_dead: bool = false:
	set(value):
		is_player_dead = value
		player_death.emit(is_player_dead)

# Game Data
var q1: bool = false
var q2: bool = false
var q3: bool = false
var q4: bool = false

# Settings
var is_touch: bool = false

# Hopefully for saving the game
func _ready() -> void:
	pass
	
func load_data() -> void:
	pass
	
func save_data() -> void:
	pass
