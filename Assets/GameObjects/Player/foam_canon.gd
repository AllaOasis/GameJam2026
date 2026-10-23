
extends Marker2D

@export var projectile_scene: PackedScene
@export var fire_cooldown: float = 0.4
@export var hold_to_shoot: bool = true

var fire_timer: float = 0.0


func _process(delta: float) -> void:
	fire_timer = maxf(fire_timer - delta, 0.0)

	if (!hold_to_shoot and Input.is_action_just_pressed("Shoot")) or (hold_to_shoot and Input.is_action_pressed("Shoot")):
		shoot()


func shoot() -> void:
	if fire_timer > 0.0:
		return

	if projectile_scene == null:
		push_warning("FoamShooter: Assign FoamProjectile.tscn.")
		return

	var projectile := projectile_scene.instantiate() as FoamProjectile

	if projectile == null:
		push_error("FoamShooter: Projectile root must use FoamProjectile.")
		return

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
