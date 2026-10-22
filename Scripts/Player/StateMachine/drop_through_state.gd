
extends State
class_name DropThroughState


const PLATFORM_COLLISION_LAYER := 8

var original_collision_mask := 0
var drop_started := false


func enter() -> void:
	animated_sprite.play("idle")

	original_collision_mask = player.collision_mask
	drop_started = false

	# Ignore one-way platforms temporarily.
	player.set_collision_mask_value(
		PLATFORM_COLLISION_LAYER,
		false
	)

	# Ensure the player starts moving down.
	player.velocity.y = maxf(player.velocity.y, 50.0)


func update(_delta: float) -> void:
	# Wait until the player has moved below the platform.
	if not drop_started:
		if player.velocity.y >= 0.0:
			drop_started = true
		return

	# Restore platform collision once we're clear of the
	# platform we dropped through.
	player.collision_mask = original_collision_mask

	# If we landed on another platform, check whether it can
	# also be dropped through.
	if player.is_on_floor():
		if Input.is_action_pressed("Jump"):
			if player_controller.can_drop_through_current_ground():
				player.set_collision_mask_value(
					PLATFORM_COLLISION_LAYER,
					false
				)
				player.velocity.y = maxf(player.velocity.y, 50.0)
				drop_started = false
				return
			else:
				state_machine.change_state("JumpState")
				return

		if Input.get_axis("Left", "Right") != 0.0:
			state_machine.change_state("WalkState")
		else:
			state_machine.change_state("IdleState")
		return


func exit() -> void:
	# Never leave the player with platform collision disabled.
	player.collision_mask = original_collision_mask
