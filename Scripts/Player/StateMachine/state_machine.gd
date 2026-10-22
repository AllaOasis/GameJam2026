extends Node
class_name StateMachine


@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var player_controller: PlayerController
@export var default_state: StringName

var current_state: State
var states: Dictionary[StringName, State] = {}


func _ready() -> void:
	if !player || !animated_sprite || !player_controller:
		push_error("StateMachine: Missing required references.")
		push_warning("StateMachine: Disabling StateMachine. Check errors above.")
		set_process(false)
		set_physics_process(false)
		return


	# ========================================================
	# Register States
	# ========================================================

	for child in get_children():
		if child is State:

			child.setup(
				self,
				player,
				animated_sprite,
				player_controller
			)

			if states.has(child.state_id):
				push_error(
					"Duplicate State ID: '%s'" % child.state_id
				)
				continue

			states[child.state_id] = child


	# ========================================================
	# Start Default State
	# ========================================================

	change_state(default_state)


func _physics_process(delta: float) -> void:
	# Shared Physics
	player_controller.apply_gravity(delta)
	player_controller.update_timers(delta)

	# Current State
	if current_state:
		current_state.update(delta)

	# Move Player
	player.move_and_slide()

	# Update Ground State
	player_controller.update_ground_state(delta)
	player_controller.update_ground_data()


func change_state(state_id: StringName) -> void:

	if not states.has(state_id):

		if state_id == default_state:
			push_error(
				"State '%s' does not exist!" % state_id
			)
			return

		push_warning(
			"State '%s' does not exist, using default state '%s'." % [
				state_id,
				default_state
			]
		)

		state_id = default_state


	# Don't restart the current state.
	if current_state == states[state_id]:
		return


	if current_state:
		current_state.exit()


	current_state = states[state_id]
	current_state.enter()


# ============================================================
# Jump Transition
# ============================================================

func change_to_jump(jump_type: JumpState.JumpType) -> void:
	var jump_state := states["JumpState"] as JumpState

	jump_state.jump_type = jump_type

	change_state("JumpState")
