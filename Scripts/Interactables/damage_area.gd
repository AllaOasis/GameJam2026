extends Area2D
class_name DamageArea

@export_subgroup("Damage")
@export var damage_amount: int = 1

var player_controller: PlayerController
var player_in_range: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body is PlayerController:
		return

	if player_controller == null:
		player_controller = body as PlayerController
		
	if player_controller == null:
		push_warning("Spike: Could not find PlayerController.")
		return
		
	if player_controller.hazard_system == null:
		push_warning("Spike: PlayerController has no HazardSystem.")
		return
		
	player_in_range = true
	_try_damage()


func _on_body_exited(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	player_in_range = false

func _try_damage() -> void:
	if player_controller == null or player_controller.hazard_system == null:
		return
	player_controller.hazard_system.take_damage(damage_amount)

func _process(delta: float) -> void:
	if player_in_range:
		_try_damage()
