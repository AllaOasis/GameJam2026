extends TextureButton
class_name ActionButton

@export var action: StringName = &"Jump"

func _ready() -> void:
	focus_mode = Control.FOCUS_CLICK
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down() -> void:
	print(action)
	Input.action_press(action)

func _on_button_up() -> void:
	Input.action_release(action)
