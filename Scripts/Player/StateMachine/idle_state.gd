extends State
class_name IdleState


func enter() -> void:
	animated_sprite.play("idle")


func update(delta: float) -> void:

	# ========================================================
	# Stop Horizontal Movement
	# ========================================================

	player.velocity.x = move_toward(
		player.velocity.x,
		0.0,
		player_controller.deceleration * delta
	)


	# ========================================================
	# Walk
	# ========================================================

	if Input.get_axis("Left", "Right") != 0.0:
		state_machine.change_state("WalkState")
		return

	# ========================================================
	# Jump / Drop Through
	# ========================================================

	if Input.is_action_just_pressed("Jump"):

		# Down + Jump = Drop Through
		if Input.is_action_pressed("Down"):
			if player_controller.drop_through:
				state_machine.change_state("DropThroughState")
				return

		# Normal Jump
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
	# Left Ground
	# ========================================================

	if not player.is_on_floor():
		state_machine.change_state("FallState")
