extends Area2D
class_name Spike

@export_subgroup("Damage")
@export var damage_amount: int = 1
@export var damage_cooldown: float = 1.0

var player_controller: PlayerController
var player_in_range: bool = false

@onready var damage_timer: Timer = $DamageCooldown


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	damage_timer.wait_time = damage_cooldown
	damage_timer.one_shot = true
	damage_timer.timeout.connect(_on_damage_cooldown_timeout)


func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return

	# Find the PlayerController if it hasn't been assigned.
	if player_controller == null:
		player_controller = body as PlayerController

	if player_controller == null:
		var player_node: Node = get_tree().get_first_node_in_group("player")
		player_controller = player_node as PlayerController

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

	if not damage_timer.is_stopped():
		return

	# Apply damage through HazardSystem™.
	player_controller.hazard_system.take_damage(damage_amount)

	# Prevent another hit until the cooldown expires.
	damage_timer.start()


func _on_damage_cooldown_timeout() -> void:
	if player_in_range:
		# Damage again if the player is still touching the spikes.
		_try_damage()
