extends TextureButton
class_name SettingsToggleButton

@export_subgroup("Setting")
@export var setting_name: StringName = &"is_touch"
@export var is_toggle: bool = true


func _ready() -> void:
	toggle_mode = is_toggle

	_set_toggleables()
	
	pressed.connect(_on_pressed)
	GameData.data_changed.connect(_set_toggleables)

func _set_toggleables() -> void:
	if is_toggle:
		match setting_name:
			&"is_touch":
				button_pressed = GameData.is_touch
			_:
				push_warning(
					"SettingsToggleButton: Unknown toggle setting: "
					+ String(setting_name)
				)

func _on_pressed() -> void:
	if is_toggle:
		match setting_name:
			&"is_touch":
				GameData.is_touch = button_pressed
			_:
				push_warning(
					"SettingsToggleButton: Unknown toggle setting: "
					+ String(setting_name)
				)
	else:
		match setting_name:
			&"reset_data":
				GameData.reset_data()
			_:
				push_warning(
					"SettingsToggleButton: Unknown action: "
					+ String(setting_name)
				)
