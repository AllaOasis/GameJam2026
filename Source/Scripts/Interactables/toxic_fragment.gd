extends Area2D
class_name ToxicFragment

@export var coin_amount: int = 1

var player_controller: PlayerController

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D: return

	var controller: PlayerController = player_controller

	if controller == null: controller = body as PlayerController

	if controller == null:
		push_warning("ToxinCoin: Could not find PlayerController.")
		return

	if controller.hazard_system == null:
		push_warning("ToxinCoin: PlayerController has no HazardSystem.")
		return

	controller.hazard_system.collect_toxin_fragments(coin_amount)

	queue_free()
