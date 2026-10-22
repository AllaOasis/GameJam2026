extends Node2D
class_name PlayerController


@export var player: CharacterBody2D
@export var hazard_system: HazardSystem

var ground_tile_map: TileMapLayer

func _ready() -> void:
	if !player:
		push_error("PlayerController: Missing Player Reference!")
		push_warning("PlayerController: Disabling Movement Controller.")
		set_process(false)
		set_physics_process(false)

	# Find the ground TileMapLayer if it hasn't been assigned.
	if !ground_tile_map:
		var tile_node: Node = get_tree().get_first_node_in_group("level_tiles")
		ground_tile_map = tile_node as TileMapLayer

	if !ground_tile_map:
		push_error("PlayerController: Missing Ground Tile Map!")

	if !hazard_system:
		push_error("PlayerController: Missing Hazard System!")


# ============================================================
# Shared Physics
# ============================================================

func apply_gravity(delta: float) -> void:
	if !player.is_on_floor():
		player.velocity += player.get_gravity() * delta


func update_timers(delta: float) -> void:
	# Jump buffer
	if jump_buffer_timer > 0.0:
		jump_buffer_timer = maxf(
			jump_buffer_timer - delta,
			0.0
		)

	# Dash cooldown
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = maxf(
			dash_cooldown_timer - delta,
			0.0
		)

	if drop_through_timer > 0.0:
		drop_through_timer = maxf(
			drop_through_timer - delta,
			0.0
		)


func update_ground_state(delta: float) -> void:
	if player.is_on_floor():
		# Restore abilities when landing.
		can_double_jump = double_jump
		can_wall_jump = wall_jump
		can_dash = dash

		# Start / refresh coyote timer.
		coyote_timer = coyote_time
	else:
		# Count down coyote time while airborne.
		coyote_timer = maxf(
			coyote_timer - delta,
			0.0
		)


# ============================================================
# Jump
# ============================================================

func request_jump() -> void:
	jump_buffer_timer = jump_buffer_time


func consume_jump_buffer() -> void:
	jump_buffer_timer = 0.0
	
# ============================================================
# Ground Data
# ============================================================

func update_ground_data() -> void:
	current_ground_type = "air"
	current_ground_drop_through = false

	if not is_instance_valid(player):
		push_error("MovementController: Player reference is missing or invalid.")
		return

	if not is_instance_valid(ground_tile_map):
		push_error("MovementController: Ground Tile Map reference is missing or invalid.")
		return

	if not player.is_on_floor():
		return

	var floor_collision: KinematicCollision2D = null

	for i in player.get_slide_collision_count():
		var collision := player.get_slide_collision(i)

		if collision.get_normal().dot(player.up_direction) > 0.7:
			floor_collision = collision
			break

	if floor_collision == null:
		return

	if floor_collision.get_collider() != ground_tile_map:
		return

	var tile_local_position := ground_tile_map.to_local(
		floor_collision.get_position()
	)

	var tile_coords := ground_tile_map.local_to_map(
		tile_local_position
	)

	var tile_data: TileData = ground_tile_map.get_cell_tile_data(
		tile_coords
	)

	if tile_data == null:
		return

	current_ground_type = str(
		tile_data.get_custom_data("ground_type")
	)
	
	current_ground_drop_through = bool(
		tile_data.get_custom_data("drop_through")
	)

func can_drop_through_current_ground() -> bool:
	return (
		drop_through
		and current_ground_drop_through
		and player.is_on_floor()
	)

# ============================================================
# Config Data
# ============================================================

@export_category("Movement Controller")
@export_subgroup("Movement")

@export_range(0, 1000, 0.01, "hide_slider")
var speed: float = 100.0

@export_range(0, 10000, 0.01, "hide_slider")
var acceleration: float = 1000.0

@export_range(0, 10000, 0.01, "hide_slider")
var deceleration: float = 800.0


@export_subgroup("Jumping")

@export_range(0, 1000, 0.01, "hide_slider")
var jump_velocity: float = 200.0

@export_range(0, 1, 0.01, "prefer_slider")
var jump_buffer_time: float = 0.1

@export_range(0, 1, 0.01, "prefer_slider")
var coyote_time: float = 0.1

@export_range(0, 1, 0.01, "prefer_slider")
var jump_cut_multiplier: float = 0.5

@export var double_jump: bool = true

@export var wall_jump: bool = true

@export var allow_double_and_wall_jump: bool = true

@export var infinite_wall_jump: bool = false

@export var infinite_double_jump: bool = false


@export_subgroup("Dash")

@export_range(0, 2000, 0.01, "hide_slider")
var dash_speed: float = 250.0

@export_range(0, 1, 0.01, "prefer_slider")
var dash_time: float = 0.15

@export_range(0, 60, 0.01, "prefer_slider")
var dash_cooldown_time: float = 2.0

@export_range(0, 1, 0.01, "prefer_slider")
var dash_gravity_damping: float = 0.33

@export var dash: bool = true


@export_subgroup("Drop Through")

@export var drop_through: bool = true
@export var drop_through_time: float = 0.2


# ============================================================
# Runtime Data
# ============================================================

var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0

var can_double_jump: bool = false
var can_wall_jump: bool = false

var can_dash: bool = true
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

var drop_through_timer: float = 0.0

var current_ground_type: String = ""
var current_ground_drop_through: bool = false

# 1.0 = facing right
# -1.0 = facing left
var orientation: float = 1.0
