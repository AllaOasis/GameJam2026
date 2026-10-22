extends Area2D
class_name ToxinCoin

@export var coin_amount: int = 1

var player_controller: PlayerController

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return

	# Find the PlayerController if it hasn't been assigned.
	var controller: PlayerController = player_controller

	if controller == null:
		controller = body as PlayerController

	if controller == null:
		var player_node: Node = get_tree().get_first_node_in_group("player")
		controller = player_node as PlayerController

	if controller == null:
		push_warning("ToxinCoin: Could not find PlayerController.")
		return

	if controller.hazard_system == null:
		push_warning("ToxinCoin: PlayerController has no HazardSystem.")
		return

	# Grant Toxin Coins to HazardSystem™.
	controller.hazard_system.collect_toxin_coins(coin_amount)

	# Remove the collected coin.
	queue_free()
