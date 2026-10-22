extends TextureButton
class_name SettingsToggleButton

@export_subgroup("Setting")
@export var setting_name: StringName = &"is_touch"
@export var display_name: String = "Touch Controls"

func _ready() -> void:
	toggle_mode = true
	
	# Initialize the button from the current global setting.
	match setting_name:
		&"is_touch":
			button_pressed = GameSettings.is_touch

		_:
			push_warning(
			"SettingsToggleButton: Unknown setting: "
			+ String(setting_name)
		)

	# Update the global setting when toggled.
	toggled.connect(_on_toggled)


func _on_toggled(enabled: bool) -> void:
	match setting_name:
		&"is_touch":
			GameSettings.is_touch = enabled

		_:
			push_warning(
				"SettingsToggleButton: Unknown setting: "
				+ String(setting_name)
			)
			return
