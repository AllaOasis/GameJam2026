extends TextureButton
class_name SceneButton

@export_file("*.tscn") var level_path: String
@export var player_scene: PackedScene
@export var level_toxins: int = 0
@export var spawn_point: StringName = &"Default"


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if level_path.is_empty():
		push_error("LevelLoadButton: No level path assigned.")
		return

	SceneManager.load_level(
		level_path,
		player_scene,
		level_toxins,
		spawn_point
	)
