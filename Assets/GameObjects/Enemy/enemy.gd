extends CharacterBody2D

@export var sprite: AnimatedSprite2D

@export_subgroup("Stats")
@export var move_speed: float = 40.0
@export var max_health: int = 10

@export_subgroup("Player Detection")
@export var detect_area: Area2D
@export var radiation_damage: int = 1
@export var radiation_cooldown: float = 0.2

@export_range(0.0, 1.0, 0.05)
var behind_detection_chance: float = 0.25

@export var behind_check_interval: float = 0.2
@export var chase_deadzone: float = 8.0

@export_subgroup("Area Detection")
@export var wall_check: RayCast2D
@export var ground_check: RayCast2D
@export var vision_ray: RayCast2D
@export var turn_cooldown: float = 0.2

@export_subgroup("Damage Area")
@export var attack_area: DamageArea
@export var damage_amount: int = 1

@export_subgroup("Drop")
@export var drop: PackedScene

@export_subgroup("Bugfix")
@export var stop_chasing_at_edges: bool = false

var direction: int = 1
var turn_timer: float = 0.0
var health: int = 10

var detected_players: Array[Node2D] = []
var chase_target: Node2D = null
var behind_check_timer: float = 0.0

var is_dead: bool = false
var death_timer: float = 1.5


func _ready() -> void:
	health = max_health

	if sprite == null:
		sprite = get_node_or_null("AnimatedSprite2D")
		
	if sprite:
		sprite.play("walk")

	if wall_check:
		wall_check.enabled = true

	if ground_check:
		ground_check.enabled = true

	if vision_ray:
		vision_ray.enabled = true

	_update_raycasts()
	_flip_sprite()

	if detect_area:
		detect_area.body_entered.connect(_on_detection_body_entered)
		detect_area.body_exited.connect(_on_detection_body_exited)

		for body in detect_area.get_overlapping_bodies():
			_on_detection_body_entered(body)

	if attack_area:
		attack_area.damage_amount = damage_amount


func _physics_process(delta: float) -> void:
	if is_dead:
		death_timer -= delta

		if death_timer <= 0.0:
			if drop:
				var fragment = drop.instantiate() as Node2D

				if fragment:
					fragment.global_position = global_position
					get_tree().current_scene.add_child(fragment)

			queue_free()

		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	turn_timer = maxf(turn_timer - delta, 0.0)

	for i in range(detected_players.size() - 1, -1, -1):
		if not is_instance_valid(detected_players[i]):
			detected_players.remove_at(i)

	if is_instance_valid(chase_target):
		var target_in_range: bool = (
			not GameData.is_player_dead
			and detected_players.has(chase_target)
			and detect_area != null
			and detect_area.overlaps_body(chase_target)
		)

		if not target_in_range or not _can_see_player(chase_target):
			chase_target = null
			velocity.x = 0.0

	behind_check_timer -= delta

	if (
		not is_instance_valid(chase_target)
		and not GameData.is_player_dead
		and behind_check_timer <= 0.0
	):
		behind_check_timer = behind_check_interval

		for player in detected_players:
			if not is_instance_valid(player):
				continue

			if detect_area == null or not detect_area.overlaps_body(player):
				continue

			if not _can_see_player(player):
				continue

			if _is_player_in_front(player):
				_detect_player(player)
				break
			elif randf() < behind_detection_chance:
				_detect_player(player)
				break

	var chasing: bool = (
		is_instance_valid(chase_target)
		and not GameData.is_player_dead
		and detected_players.has(chase_target)
		and detect_area != null
		and detect_area.overlaps_body(chase_target)
	)

	if chasing:
		var distance_x: float = (
			chase_target.global_position.x - global_position.x
		)

		if absf(distance_x) <= chase_deadzone:
			velocity.x = 0.0
		else:
			var new_direction: int = 1 if distance_x > 0.0 else -1

			if new_direction != direction:
				direction = new_direction
				_flip_sprite()
				_update_raycasts()

	var wall_blocked: bool = false
	var edge_blocked: bool = false

	if wall_check:
		wall_check.force_raycast_update()
		wall_blocked = wall_check.is_colliding()

	if ground_check and (not chasing or stop_chasing_at_edges):
		ground_check.force_raycast_update()
		edge_blocked = not ground_check.is_colliding()

	if wall_blocked:
		if chasing:
			velocity.x = 0.0
			move_and_slide()
			return

		if turn_timer <= 0.0:
			_turn_around()

	elif edge_blocked:
		if chasing and stop_chasing_at_edges:
			velocity.x = 0.0
			move_and_slide()
			return

		if not chasing and turn_timer <= 0.0:
			_turn_around()

	if chasing:
		var distance_x: float = (
			chase_target.global_position.x - global_position.x
		)

		if absf(distance_x) <= chase_deadzone:
			velocity.x = 0.0
		else:
			velocity.x = direction * move_speed
	else:
		velocity.x = direction * move_speed

	move_and_slide()

	if is_on_wall() and not chasing and turn_timer <= 0.0:
		_turn_around()


func _turn_around() -> void:
	direction *= -1
	turn_timer = turn_cooldown

	_flip_sprite()
	_update_raycasts()


func _flip_sprite() -> void:
	if sprite:
		sprite.flip_h = direction < 0


func _update_raycasts() -> void:
	if wall_check:
		wall_check.position.x = absf(wall_check.position.x) * direction
		wall_check.target_position.x = absf(wall_check.target_position.x)

	if ground_check:
		ground_check.position.x = absf(ground_check.position.x) * direction
		ground_check.target_position.x = 0.0


func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not detected_players.has(body):
		detected_players.append(body)


func _on_detection_body_exited(body: Node2D) -> void:
	detected_players.erase(body)

	if body == chase_target:
		chase_target = null
		velocity.x = 0.0


func _is_player_in_front(player: Node2D) -> bool:
	var horizontal_distance: float = (
		player.global_position.x - global_position.x
	)

	return (
		(direction > 0 and horizontal_distance >= 0.0)
		or (direction < 0 and horizontal_distance <= 0.0)
	)


func _detect_player(player: Node2D) -> void:
	if not is_instance_valid(player):
		return

	chase_target = player

	var distance_x: float = (
		player.global_position.x - global_position.x
	)

	if absf(distance_x) > chase_deadzone:
		direction = 1 if distance_x > 0.0 else -1

	_flip_sprite()
	_update_raycasts()


func _can_see_player(player: Node2D) -> bool:
	if not is_instance_valid(player):
		return false

	if not vision_ray:
		return detect_area != null and detect_area.overlaps_body(player)

	vision_ray.target_position = vision_ray.to_local(
		player.global_position
	)

	vision_ray.force_raycast_update()

	if not vision_ray.is_colliding():
		return false

	var collider: Object = vision_ray.get_collider()

	if collider == player:
		return true

	if collider is Node:
		var hit_node: Node = collider as Node

		if hit_node.is_in_group("player"):
			return true

		if hit_node.get_parent() == player:
			return true

	return false


func take_damage(damage: int) -> void:
	if damage <= 0 or is_dead:
		return

	health = maxi(health - damage, 0)

	if health == 0:
		is_dead = true
		velocity = Vector2.ZERO

		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)

		if sprite:
			sprite.play("death")
