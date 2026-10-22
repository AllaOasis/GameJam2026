extends State
class_name WalkState


func enter() -> void:
	animated_sprite.play("walk")


func update(delta: float) -> void:

	# ========================================================
	# Horizontal Movement
	# ========================================================

	var direction := Input.get_axis("Left", "Right")


	# No input → idle.
	if direction == 0.0:
		state_machine.change_state("IdleState")
		return


	# ========================================================
	# Face Movement Direction
	# ========================================================

	if direction > 0.0:
		player_controller.orientation = 1.0
		animated_sprite.flip_h = false
	else:
		player_controller.orientation = -1.0
		animated_sprite.flip_h = true


	# ========================================================
	# Accelerate
	# ========================================================

	var target_speed = direction * player_controller.speed
	
	player.velocity.x = move_toward(
		player.velocity.x,
		target_speed,
		player_controller.acceleration * delta
	)

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
