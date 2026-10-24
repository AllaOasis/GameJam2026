extends Area2D
class_name CleansingStation

@export var sprite: AnimatedSprite2D
@export var light: PointLight2D
@export var processing_time: float = 1
@export var run_empty: bool = false

var processing_timer: float = 0
var player_controller: PlayerController
var player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if light:
		light.visible = false

func _on_body_entered(body: Node2D) -> void:
	if not body is PlayerController:
		return

	if !player_controller:
		player_controller = body as PlayerController
		
	if player_controller:
		player_in_range = true
		if light:
			light.visible = true
		process_interact(0)
		
func _on_body_exited(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return

	player_in_range = false
	if light:
		light.visible = false
	
func process_interact(delta):
	if processing_timer <= 0:
		if light and !light.visible:
			light.visible = true
		if Input.is_action_just_pressed("Interact"):
			if player_controller == null or player_controller.hazard_system == null:
				return
				
			if light:
				light.visible = false

			var purified_amount: int = player_controller.hazard_system.purify_toxin_fragments()
			if purified_amount > 0 or run_empty:
				processing_timer = processing_time
				if sprite:
					sprite.play("processing")
	else:
		if light and light.visible:
			light.visible = false
		processing_timer = maxf(processing_timer - delta, 0)
			
			
	
func _process(delta: float) -> void:
	if not player_in_range:
		return
	
	process_interact(delta)
