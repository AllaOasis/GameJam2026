extends Area2D
class_name CleansingStation

@export var player_controller: PlayerController

var player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


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
		push_warning("CleansingStation: Could not find PlayerController.")
		return

	if player_controller.hazard_system == null:
		push_warning("CleansingStation: PlayerController has no HazardSystem.")
		return

	player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return

	player_in_range = false
	
func _process(_delta: float) -> void:
	if not player_in_range:
		return

	if Input.is_action_just_pressed("Interact"):
		if player_controller == null or player_controller.hazard_system == null:
			return

		# Purify all collected Toxin Coins.
		var purified_amount: int = player_controller.hazard_system.purify_toxin_coins()

		if purified_amount > 0:
			print("Purified ", purified_amount, " Toxin Coins!")
