extends State
class_name FallState


func enter() -> void:
	animated_sprite.play("idle")


func update(delta: float) -> void:

	var direction := Input.get_axis("Left", "Right")


	# ========================================================
	# Horizontal Air Movement
	# ========================================================

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
	# Jump Input
	# ========================================================

	if Input.is_action_just_pressed("Jump"):

		# ----------------------------------------------------
		# Coyote Jump
		# ----------------------------------------------------

		if player_controller.coyote_timer > 0.0:
			state_machine.change_to_jump(
				JumpState.JumpType.NORMAL
			)
			return


		# ----------------------------------------------------
		# Wall Jump
		# ----------------------------------------------------

		if player.is_on_wall() and player_controller.can_wall_jump:

			var wall_normal := player.get_wall_normal()

			# Push away from wall.
			player.velocity.x = (
				wall_normal.x * player_controller.speed
			)

			state_machine.change_to_jump(
				JumpState.JumpType.WALL
			)
			return


		# ----------------------------------------------------
		# Double Jump
		# ----------------------------------------------------

		if player_controller.can_double_jump:

			state_machine.change_to_jump(
				JumpState.JumpType.DOUBLE
			)
			return


		# ----------------------------------------------------
		# No Jump Available → Buffer
		# ----------------------------------------------------

		player_controller.jump_buffer_timer = (
			player_controller.jump_buffer_time
		)


	# ========================================================
	# Jump Buffer
	# ========================================================

	if player_controller.jump_buffer_timer > 0.0:

		if player.is_on_floor():
			state_machine.change_to_jump(
				JumpState.JumpType.NORMAL
			)
			return


	# ========================================================
	# Dash
	# ========================================================

	if Input.is_action_just_pressed("Dash"):

		if player_controller.can_dash and player_controller.dash_cooldown_timer <= 0:
			state_machine.change_state("DashState")
			return


	# ========================================================
	# Landing
	# ========================================================

	if player.is_on_floor():

		if player_controller.jump_buffer_timer > 0.0:

			state_machine.change_to_jump(
				JumpState.JumpType.NORMAL
			)

		elif direction != 0.0:

			state_machine.change_state("WalkState")

		else:

			state_machine.change_state("IdleState")
