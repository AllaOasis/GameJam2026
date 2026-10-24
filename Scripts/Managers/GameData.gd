extends Node

signal player_death

var toxinImmunity := false
var damageImunity := false

var is_touch: bool = false

var is_player_dead: bool = false:
	set(value):
		is_player_dead = value
		player_death.emit(is_player_dead)
		

# Hopefully for saving the game
func _ready() -> void:
	pass
	
func load_data() -> void:
	pass
	
func save_data() -> void:
	pass
