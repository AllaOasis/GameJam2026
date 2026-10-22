extends Node

var is_paused: bool = false


func pause_game() -> void:
	is_paused = true
	get_tree().paused = true


func resume_game() -> void:
	get_tree().paused = false
	is_paused = false


func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()
		
