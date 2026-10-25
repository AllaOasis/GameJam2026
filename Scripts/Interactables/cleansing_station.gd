extends Area2D
class_name CleansingStation

@export var sprite: AnimatedSprite2D
@export var light: PointLight2D
@export var processing_time: float = 1.0
@export var run_empty: bool = false

var processing_timer: float = 0.0
var player_controller: PlayerController = null
var player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if light: light.visible = false


func _on_body_entered(body: Node2D) -> void:
	if not body is PlayerController: return

	player_controller = body as PlayerController
	player_in_range = true

	if light and processing_timer <= 0.0: light.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body != player_controller: return

	player_in_range = false
	player_controller = null

	if light: light.visible = false


func _process(delta: float) -> void:
	if processing_timer > 0.0:
		processing_timer = maxf(processing_timer - delta, 0.0)
		if processing_timer <= 0.0 and sprite: sprite.play("idle")

	if !player_in_range or !player_controller: return
	if processing_timer > 0.0: return

	if light and not light.visible: light.visible = true

	if Input.is_action_just_pressed("Interact"): _interact()


func _interact() -> void:
	if !player_controller or !player_controller.hazard_system:
		return

	var purified_amount: int = player_controller.hazard_system.purify_toxin_fragments()

	if purified_amount <= 0 and not run_empty: return

	processing_timer = processing_time

	if light: light.visible = false
	if sprite: sprite.play("processing")
