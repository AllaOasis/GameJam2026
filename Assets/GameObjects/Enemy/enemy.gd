extends CharacterBody2D

@export var move_speed: float = 40.0
@export var max_health: int = 100

@export_subgroup("Player Detection")
@export var detect_area: Area2D
@export var radiation_damage: int = 1
@export var radiation_cooldown: float = 0.2

@export_range(0.0, 1.0, 0.05) var behind_detection_chance: float = 0.25
@export var behind_check_interval: float = 1.0

@export_subgroup("Area Detection")
@export var wall_check: RayCast2D
@export var ground_check: RayCast2D
@export var turn_cooldown: float = 0.2

@export_subgroup("Bug")
@export var stop_chasing_at_edges: bool = true

var direction: int = 1
var turn_timer: float = 0.0
var health: int

var detected_players: Array[Node2D] = []
var chase_target: Node2D = null
var behind_check_timer: float = 0.0


func _ready() -> void:
	if wall_check:
		wall_check.enabled = true

	if ground_check:
		ground_check.enabled = true

	_update_raycasts()
	
	health = max_health;
	
	if detect_area:
		detect_area.body_entered.connect(_on_detection_body_entered)
		detect_area.body_exited.connect(_on_detection_body_exited)




func _physics_process(delta: float) -> void:
	# ============================================================
	# Gravity
	# ============================================================

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	turn_timer = maxf(turn_timer - delta, 0.0)

	# ============================================================
	# Choose Movement Direction
	# ============================================================

	var chasing: bool = is_instance_valid(chase_target)

	if chasing:
		var distance_x: float = (
			chase_target.global_position.x - global_position.x
		)

		if not is_zero_approx(distance_x):
			var new_direction: int = 1 if distance_x > 0.0 else -1

			if new_direction != direction:
				_turn_around()

	# ============================================================
	# Wall & Edge Detection
	# ============================================================

	var blocked: bool = false

	if wall_check and ground_check:
		wall_check.force_raycast_update()
		ground_check.force_raycast_update()

		blocked = (
			wall_check.is_colliding()
			or not ground_check.is_colliding()
		)

	if blocked:
		if chasing and stop_chasing_at_edges:
			velocity.x = 0.0
			move_and_slide()
			return
		elif turn_timer <= 0.0:
			_turn_around()

	# ============================================================
	# Horizontal Movement
	# ============================================================

	velocity.x = direction * move_speed
	move_and_slide()

	# ============================================================
	# Collision Safety
	# ============================================================

	if is_on_wall():
		if chasing:
			velocity.x = 0.0
		elif turn_timer <= 0.0:
			_turn_around()

	# ============================================================
	# Player Detection
	# ============================================================

	behind_check_timer -= delta

	if behind_check_timer > 0.0:
		return

	behind_check_timer = behind_check_interval

	for player in detected_players:
		if not is_instance_valid(player):
			continue

		if _is_player_in_front(player):
			_detect_player(player)
		elif randf() < behind_detection_chance:
			_detect_player(player)


func _turn_around() -> void:
	direction *= -1
	turn_timer = turn_cooldown
	
	_flip_sprite()

	# Update the raycasts to face the new direction.
	_update_raycasts()
	
func _flip_sprite():
	# Flip the visual to face the walking direction.
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = direction < 0


func _update_raycasts() -> void:
	# Keep the raycasts pointing in the walking direction.
	if wall_check:
		wall_check.position.x = absf(wall_check.position.x) * direction
		wall_check.target_position.x = absf(wall_check.target_position.x)

	if ground_check:
		ground_check.position.x = absf(ground_check.position.x) * direction
		ground_check.target_position.x = 0.0
		
		
func take_damage(damage: int):
	if damage <= 0: return
	
	health = maxi(health - damage, 0)
	
	if(health == 0):
		print("Enemy DEATH")



func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not detected_players.has(body):
		detected_players.append(body)


func _on_detection_body_exited(body: Node2D) -> void:
	detected_players.erase(body)

	if body == chase_target:
		chase_target = null
		print("Player lost. Returning to patrol.")


func _is_player_in_front(player: Node2D) -> bool:
	var horizontal_distance: float = player.global_position.x - global_position.x

	return (
		(direction > 0 and horizontal_distance >= 0.0)
		or (direction < 0 and horizontal_distance <= 0.0)
	)


func _detect_player(player: Node2D) -> void:
	if chase_target == player:
		return

	chase_target = player
	print("Player detected! Chasing!")
