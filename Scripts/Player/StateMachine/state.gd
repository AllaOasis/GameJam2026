extends Node
class_name State

var state_id: StringName:
	get:
		return get_script().get_global_name()

var state_machine: StateMachine
var player: CharacterBody2D
var animated_sprite: AnimatedSprite2D
var player_controller: PlayerController

func setup(
	_state_machine: StateMachine,
	_player: CharacterBody2D,
	_animated_sprite: AnimatedSprite2D,
	_player_controller: PlayerController
) -> void:
	self.state_machine = _state_machine
	self.player = _player
	self.animated_sprite = _animated_sprite
	self.player_controller = _player_controller

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
