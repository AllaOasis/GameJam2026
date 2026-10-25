extends Marker2D
class_name FoamCanon

@export var projectile_scene: PackedScene
@export var fire_cooldown: float = 0.4
@export var hold_to_shoot: bool = true

@export var max_foam: int = 100
@export var sound: AudioStreamPlayer2D

var current_foam: int
var fire_timer: float = 0.0

func _ready() -> void:
	current_foam = max_foam

func _process(delta: float) -> void:
	fire_timer = maxf(fire_timer - delta, 0.0)

	if (!hold_to_shoot and Input.is_action_just_pressed("Shoot")) or (hold_to_shoot and Input.is_action_pressed("Shoot")):
		shoot()


func shoot() -> void:
	if GameData.is_player_dead:
		return
	
	if fire_timer > 0.0:
		return
		
	if current_foam <= 0:
		return

	if projectile_scene == null:
		push_warning("FoamShooter: Assign FoamProjectile.tscn.")
		return

	var projectile := projectile_scene.instantiate() as FoamProjectile

	if projectile == null:
		push_error("FoamShooter: Projectile root must use FoamProjectile.")
		return

	if sound:
		sound.pitch_scale = 0.8 + randf_range(-0.1,0.1)
		sound.play()
		pass

	if !GameData.infiniteFoam: current_foam = maxi(current_foam - 1, 0)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position

	# Face the direction the Player is looking.
	var player := get_parent()
	var direction := 1.0

	if player.has_node("AnimatedSprite2D"):
		if player.get_node("AnimatedSprite2D").flip_h:
			direction = -1.0

	projectile.launch(Vector2(direction, -0.6))

	fire_timer = fire_cooldown

func refill():
	current_foam = max_foam
