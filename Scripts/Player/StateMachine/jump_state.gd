extends State
class_name JumpState


enum JumpType {
	NORMAL,
	DOUBLE,
	WALL
}


var jump_type := JumpType.NORMAL


func enter() -> void:
	animated_sprite.play("idle")


	# ========================================================
	# Perform Jump
	# ========================================================

	player.velocity.y = -player_controller.jump_velocity


	# ========================================================
	# Consume Correct Ability
	# ========================================================

	match jump_type:

		JumpType.NORMAL:
			# Normal jump consumes coyote time.
			player_controller.coyote_timer = 0.0


		JumpType.DOUBLE:
			# Consume double jump.
			player_controller.can_double_jump = player_controller.infinite_double_jump

			# If double + wall jumps are NOT independent,
			# consume the wall jump too.
			if not player_controller.allow_double_and_wall_jump:
				player_controller.can_wall_jump = false


		JumpType.WALL:
			# Consume wall jump.
			player_controller.can_wall_jump = player_controller.infinite_wall_jump

			# If double + wall jumps are NOT independent,
			# consume the double jump too.
			if not player_controller.allow_double_and_wall_jump:
				player_controller.can_double_jump = false


	# Jump input has been consumed.
	player_controller.jump_buffer_timer = 0.0


func update(delta: float) -> void:

	# ========================================================
	# Jump Cut
	# ========================================================

	if Input.is_action_just_released("Jump"):
		if player.velocity.y < 0.0:
			player.velocity.y *= player_controller.jump_cut_multiplier


	# ========================================================
	# Horizontal Air Movement
	# ========================================================

	var direction := Input.get_axis("Left", "Right")


	if direction != 0.0:

		if direction > 0.0:
			player_controller.orientation = 1.0
			animated_sprite.flip_h = false
		else:
			player_controller.orientation = -1.0
			animated_sprite.flip_h = true


		var target_speed := direction * player_controller.speed

		player.velocity.x = move_toward(
			player.velocity.x,
			target_speed,
			player_controller.acceleration * delta
		)

	else:

		player.velocity.x = move_toward(
			player.velocity.x,
			0.0,
			player_controller.deceleration * delta
		)


	# ========================================================
	# Dash
	# ========================================================

	if Input.is_action_just_pressed("Dash"):
		if player_controller.can_dash and player_controller.dash_cooldown_timer <= 0:
			state_machine.change_state("DashState")
			return


	# ========================================================
	# Apex → Fall
	# ========================================================

	if player.velocity.y >= 0.0:
		state_machine.change_state("FallState")
