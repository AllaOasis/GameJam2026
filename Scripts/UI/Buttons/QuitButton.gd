extends TextureButton
class_name QuitButton

@export var click_sound: AudioStreamPlayer2D

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if click_sound: click_sound.play()
	get_tree().quit()
