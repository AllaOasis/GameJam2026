extends Node

const TOUCH_DEFAULT = false

signal player_death
signal data_changed

# Cheats - Future Update
var toxinImmunity: bool = false
var damageImunity: bool = false
var infiniteJump: bool = false
var infiniteWallJump: bool = false
var infiniteDash: bool = false
var infiniteFoam: bool = false

# Level Data
var level_toxins: int = 0
var current_toxins: int = 0
var game_won: bool = false
var is_player_dead: bool = false:
	set(value):
		is_player_dead = value
		player_death.emit(is_player_dead)

# Game Data
var q1: bool = false:
	set(value):
		if q1 != value:
			q1 = value
			save_data()
var q2: bool = false:
	set(value):
		if q2 != value:
			q2 = value
			save_data()
var q3: bool = false:
	set(value):
		if q3 != value:
			q3 = value
			save_data()
var q4: bool = false:
	set(value):
		if q4 != value:
			q4 = value
			save_data()

# Settings
var is_touch: bool = TOUCH_DEFAULT:
	set(value):
		if is_touch != value:
			is_touch = value
			save_data()

# Persistant storage
const SAVE_PATH = "user://savegame.dat"
func _ready() -> void:
	load_data()
	
func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		push_error("Failed to load save data.")
		return

	var data = file.get_var()
	file.close()

	if not data is Dictionary:
		push_error("Invalid save data.")
		return

	q1 = data.get("q1", false)
	q2 = data.get("q2", false)
	q3 = data.get("q3", false)
	q4 = data.get("q4", false)
	is_touch = data.get("touch", false)
	data_changed.emit()
	
func save_data() -> void:
	var data = {
		"q1": q1,
		"q2": q2,
		"q3": q3,
		"q4": q4,
		"touch": is_touch
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("Failed to save game.")
		return

	file.store_var(data)
	file.close()
	data_changed.emit()

func reset_data() -> void:
	# Back up the existing save before resetting.
	if FileAccess.file_exists(SAVE_PATH):
		var backup_path = SAVE_PATH + ".bak"

		var source = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if source != null:
			var contents = source.get_buffer(source.get_length())
			source.close()

			var backup = FileAccess.open(backup_path, FileAccess.WRITE)
			if backup != null:
				backup.store_buffer(contents)
				backup.close()
			else:
				push_error("Failed to create save backup.")
				return
		else:
			push_error("Failed to read save for backup.")
			return

	# Reset saved game data to defaults.
	q1 = false
	q2 = false
	q3 = false
	q4 = false
	is_touch = TOUCH_DEFAULT

	# Write the reset state to the save file.
	save_data()
