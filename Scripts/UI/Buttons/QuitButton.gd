extends TextureButton
class_name QuitButton


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	get_tree().quit()
