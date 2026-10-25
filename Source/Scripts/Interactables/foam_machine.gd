extends Area2D
class_name FoamMachine

@export var light: PointLight2D
@export var sound: AudioStreamPlayer2D
var player_controller: PlayerController
var player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if light: light.visible = false

func _on_body_entered(body: Node2D) -> void:
	if not body is PlayerController: return
	if !player_controller: player_controller = body as PlayerController
		
	if player_controller:
		player_in_range = true
		if light: light.visible = true
		process_interact(0)

func _on_body_exited(body: Node2D) -> void:
	if not body is CharacterBody2D: return

	player_in_range = false
	
	if light: light.visible = false
	
func process_interact(_delta):
	if Input.is_action_just_pressed("Interact"):
		if player_controller == null or player_controller.foam_canon == null: return
		if sound: sound.play()
		player_controller.foam_canon.refill()
	
func _process(delta: float) -> void:
	if not player_in_range: return
	
	process_interact(delta)
