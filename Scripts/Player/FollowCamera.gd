extends Camera2D
class_name FollowCamera

@export var minimum: Vector2
@export var maximum: Vector2
@export var deadzone: Vector2 = Vector2(10.0, 12.0)


var follow_target: Node2D

func _ready() -> void:
	while follow_target == null:
		follow_target = get_tree().get_first_node_in_group("player") as Node2D
		if follow_target != null: break
		await get_tree().process_frame

func _process(_delta: float) -> void:
	if not is_instance_valid(follow_target):
		return

	var target_pos := follow_target.global_position
	var camera_pos := global_position

	# Move only when the target leaves the deadzone.
	if target_pos.x < camera_pos.x - deadzone.x:
		camera_pos.x = target_pos.x + deadzone.x
	elif target_pos.x > camera_pos.x + deadzone.x:
		camera_pos.x = target_pos.x - deadzone.x

	if target_pos.y < camera_pos.y - deadzone.y:
		camera_pos.y = target_pos.y + deadzone.y
	elif target_pos.y > camera_pos.y + deadzone.y:
		camera_pos.y = target_pos.y - deadzone.y

	# Clamp camera position to level boundaries.
	camera_pos.x = clampf(camera_pos.x, minimum.x, maximum.x)
	camera_pos.y = clampf(camera_pos.y, minimum.y, maximum.y)

	global_position = camera_pos
