extends State
class_name DropThroughState

var original_collision_mask := 0
var drop_started := false


func enter() -> void:
	animated_sprite.play("idle")

	original_collision_mask = player.collision_mask
	drop_started = false

	player.set_collision_mask_value(8,false)

	player.velocity.y = maxf(player.velocity.y, 50.0)


func update(_delta: float) -> void:
	if not drop_started:
		if player.velocity.y >= 0.0:
			drop_started = true
		return

	player.collision_mask = original_collision_mask

	if player.is_on_floor():
		if Input.is_action_pressed("Jump"):
			if player_controller.can_drop_through_current_ground():
				player.set_collision_mask_value(8, false)
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
	player.collision_mask = original_collision_mask
