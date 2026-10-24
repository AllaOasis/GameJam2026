extends Node

var next_spawn_point: StringName = &"Default"


func load_level(
	level_path: String,
	player_scene: PackedScene = null,
	spawn_point: StringName = &"Default"
) -> void:
	PauseManager.resume_game()
	GameData.level_toxins = 0
	GameData.current_toxins = 0
	GameData.game_won = false
	
	# Load the requested scene.
	var error: Error = get_tree().change_scene_to_file(level_path)

	if error != OK:
		push_error(
			"SceneManager: Failed to load scene. Error: "
			+ str(error)
		)
		return

	if player_scene == null:
		return

	next_spawn_point = spawn_point

	await get_tree().scene_changed

	_spawn_player_at_spawn(player_scene)



func _spawn_player_at_spawn(player_scene: PackedScene) -> void:
	var current_scene: Node = get_tree().current_scene

	if current_scene == null:
		return

	# Collect all SpawnPoints in the scene.
	var spawn_points: Array[SpawnPoint] = []
	_collect_spawn_points(current_scene, spawn_points)

	if spawn_points.is_empty():
		push_error("SceneManager: No SpawnPoint found in the current scene.")
		return
		
	# Tri-Point spawn system
	var spawn: SpawnPoint = null

	for point in spawn_points:
		if point.name == String(next_spawn_point):
			spawn = point
			break

	if spawn == null:
		for point in spawn_points:
			if point.name == "Default":
				spawn = point
				break

	if spawn == null:
		spawn = spawn_points[0]
		
	var player: Node = player_scene.instantiate()

	if not player is Node2D:
		push_error("SceneManager: Player scene root must inherit Node2D.")
		player.free()
		return
		
	player.add_to_group("player")
	
	current_scene.add_child(player)
	(player as Node2D).global_position = spawn.global_position

func _collect_spawn_points(node: Node,spawn_points: Array[SpawnPoint]) -> void:
	if node is SpawnPoint:
		spawn_points.append(node as SpawnPoint)

	for child in node.get_children():
		_collect_spawn_points(child, spawn_points)
