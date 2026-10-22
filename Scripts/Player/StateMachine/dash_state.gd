extends State
class_name DashState


func enter() -> void:
	animated_sprite.play("idle")

	player_controller.can_dash = false
	player_controller.dash_timer = player_controller.dash_time
	player_controller.dash_cooldown_timer = player_controller.dash_cooldown_time

	# Dash in facing direction.
	player.velocity.x = (
		player_controller.orientation
		* player_controller.dash_speed
	)

	# Preserve the original gravity damping behavior.
	player.velocity.y *= player_controller.dash_gravity_damping


func update(delta: float) -> void:
	# Keep dash movement locked.
	player.velocity.x = (
		player_controller.orientation
		* player_controller.dash_speed
	)

	player.velocity.y *= player_controller.dash_gravity_damping

	player_controller.dash_timer -= delta

	if player_controller.dash_timer <= 0.0:
		player_controller.dash_timer = 0.0

		# Decide where we go after the dash.
		if player.is_on_floor():
			if Input.get_axis("Left", "Right") != 0.0:
				state_machine.change_state("WalkState")
			else:
				state_machine.change_state("IdleState")
		elif player.velocity.y < 0.0:
			state_machine.change_state("JumpState")
		else:
			state_machine.change_state("FallState")
