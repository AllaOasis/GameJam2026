extends TextureButton
class_name SceneButton

@export_file("*.tscn") var level_path: String
@export var player_scene: PackedScene
@export var spawn_point: StringName = &"Default"

@export var click_sound: AudioStreamPlayer2D

@export_subgroup("On Hover")
@export var enable_on_hover: CanvasItem


func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_hover_exit)
	if enable_on_hover: enable_on_hover.visible = false

func _on_pressed() -> void:
	if click_sound: click_sound.play()
	if level_path.is_empty():
		push_error("LevelLoadButton: No level path assigned.")
		return

	SceneManager.load_level(
		level_path,
		player_scene,
		spawn_point
	)

func _on_hover() -> void:
	if enable_on_hover: enable_on_hover.visible = true

func _on_hover_exit() -> void:
	if enable_on_hover: enable_on_hover.visible = false
