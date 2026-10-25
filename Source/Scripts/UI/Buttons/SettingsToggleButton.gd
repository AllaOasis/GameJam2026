
extends TextureButton
class_name SettingsToggleButton

@export var click_sound: AudioStreamPlayer2D
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
			&"toxinImmunity":
				button_pressed = GameData.toxinImmunity
			&"damageImunity":
				button_pressed = GameData.damageImunity
			&"infiniteJump":
				button_pressed = GameData.infiniteJump
			&"infiniteWallJump":
				button_pressed = GameData.infiniteWallJump
			&"infiniteDash":
				button_pressed = GameData.infiniteDash
			&"infiniteFoam":
				button_pressed = GameData.infiniteFoam
			_:
				push_warning(
					"SettingsToggleButton: Unknown toggle setting: "
					+ String(setting_name)
				)


func _on_pressed() -> void:
	if click_sound:
		click_sound.play()

	if is_toggle:
		match setting_name:
			&"is_touch":
				GameData.is_touch = button_pressed
			&"toxinImmunity":
				GameData.toxinImmunity = button_pressed
			&"damageImunity":
				GameData.damageImunity = button_pressed
			&"infiniteJump":
				GameData.infiniteJump = button_pressed
			&"infiniteWallJump":
				GameData.infiniteWallJump = button_pressed
			&"infiniteDash":
				GameData.infiniteDash = button_pressed
			&"infiniteFoam":
				GameData.infiniteFoam = button_pressed
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
