extends Control
class_name UIHandler

@export_subgroup("Health & Toxins")
@export var hearts_container: HBoxContainer
@export var heart_scene: PackedScene

@export_subgroup("Health & Toxins")
@export var toxins_container: HBoxContainer
@export var toxins_scene: PackedScene

var player_controller: PlayerController
var hearts: Array[Heart] = []

@export_subgroup("Dash")
@export var dash_cooldown: TextureRect

@export_subgroup("Foam")
@export var foam_tank: TextureRect

@export_subgroup("Menus")
@export var pause_menu: Node

@export_subgroup("Death Animation")
@export var death_background: CanvasItem
@export var death_text: CanvasItem
@export var death_button: CanvasItem
@export var animation_duration: float = 2
@export var initial_delay: float = 1.5

@export_subgroup("Win Animation")
@export var win_screen: CanvasItem
@export var win_text: CanvasItem
@export var win_button: CanvasItem
@export var win_animation_duration: float = 2.0
@export var win_initial_delay: float = 2

var win_text_timer: float = 0.0
var win_button_timer: float = 0.0

@export_subgroup("Android & Touch")
@export var pause_button: Node
@export var touch_controlls: Node;

@export_subgroup("Levels")
@export_file("*.tscn") var LevelQ1: String
@export_file("*.tscn") var LevelQ2: String
@export_file("*.tscn") var LevelQ3: String
@export_file("*.tscn") var LevelQ4: String

@export_subgroup("Sound")
@export var Level_theme: AudioStreamPlayer2D

var death_background_timer: float = 0
var death_text_timer: float = 0
var death_button_timer: float = 0



func _ready() -> void:
	if !touch_controlls:
		push_warning("UIHandler: Assign TouchControlls.")
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if pause_menu: pause_menu.visible = false
	if touch_controlls: touch_controlls.visible = false

	while !player_controller:
		var player_node: Node = get_tree().get_first_node_in_group("player")
		if player_node != null: player_controller = player_node as PlayerController
		if !player_controller: await get_tree().process_frame

	if !player_controller.hazard_system:
		push_warning("UIHandler: PlayerController has no HazardSystem.")
		return

	if !hearts_container:
		push_warning("UIHandler: Assign HeartsContainer.")
		return

	if !heart_scene:
		push_warning("UIHandler: Assign Heart Scene.")
		return
		
	if !toxins_container:
		push_warning("UIHandler: Assign HeartsContainer.")
		return

	if !toxins_scene:
		push_warning("UIHandler: Assign Heart Scene.")
		return
	
	if !dash_cooldown:
		push_warning("UIHandler: Assign Dash Cooldown.")
		return
	
	if !foam_tank:
		push_warning("UIHandler: Assign Foam Tank.")
		return

	if not player_controller.hazard_system.health_changed.is_connected(_on_health_changed):
		player_controller.hazard_system.health_changed.connect(_on_health_changed)

	if not player_controller.hazard_system.toxin_level_changed.is_connected(_on_toxin_level_changed):
		player_controller.hazard_system.toxin_level_changed.connect(_on_toxin_level_changed)

	create_hearts()
	call_deferred("update_hearts", player_controller.hazard_system.current_health, player_controller.hazard_system.max_health)
	
	update_toxins()
	
	GameData.player_death.connect(player_death)
	
	death_background.modulate.a = 0
	death_button.modulate.a = 0
	death_text.modulate.a = 0
	
	death_background.visible = false
	death_button.visible = false
	death_text.visible = false
	
	win_text.modulate.a = 0.0
	win_button.modulate.a = 0.0

	win_screen.visible = false
	win_text.visible = false
	win_button.visible = false

func update_toxins() -> void:
	for child in toxins_container.get_children():
		child.queue_free()
	
	var toxins = player_controller.hazard_system.toxin_coins
	
	for i in range(toxins):
		var toxin = toxins_scene.instantiate()
		toxins_container.add_child(toxin)
		
	

func create_hearts() -> void:
	for child in hearts_container.get_children(): child.queue_free()
	hearts.clear()

	# One heart represents two health points.
	var heart_count: int = ceili(float(player_controller.hazard_system.max_health) / 2.0)

	for i in range(heart_count):
		var heart: Heart = heart_scene.instantiate() as Heart

		if !heart:
			push_error("UIHandler: Heart Scene root must use Heart.gd.")
			return

		hearts_container.add_child(heart)
		hearts.append(heart)

func update_hearts(current: int, _maximum: int) -> void:
	var toxins: int = player_controller.hazard_system.toxin_level()

	for i in range(hearts.size()):
		# Each heart represents two health points.
		var health_for_heart: int = clampi(current - (i * 2), 0, 2)

		# Each heart represents two toxin levels.
		var toxins_for_heart: int = clampi(toxins - ((hearts.size() - 1 - i) * 2), 0, 2)

		hearts[i].set_heart_state(health_for_heart, toxins_for_heart)

func _on_health_changed(current: int, maximum: int) -> void:
	update_hearts(current, maximum)

func _on_toxin_level_changed(_toxin_level: int) -> void:
	update_hearts(player_controller.hazard_system.current_health, player_controller.hazard_system.max_health)
	update_toxins()

func process_texture(rect: TextureRect, frame_count: int, maximum: float, current: float, sizeX: int, sizeY: int):
	if !rect: return
	if maximum <= 0.0: return

	var progress: float = clampf(current / maximum, 0.0, 1.0)
	var frame: int = (frame_count - 1) - roundi(progress * (frame_count - 1))

	var atlas := rect.texture as AtlasTexture
	if !atlas:return
	atlas.region = Rect2(Vector2(frame * sizeX, 0), Vector2(sizeX,sizeY))

func _process(_delta: float) -> void:
	if GameData.is_player_dead:
		if initial_delay <= 0:
			if death_background_timer > 0:
				death_background.modulate.a = clampf(1.0 - death_background_timer / (animation_duration / 3.0), 0.0, 1.0)
				death_background_timer -= _delta
			elif death_text_timer > 0:
				if Level_theme: Level_theme.stop()
				death_text.modulate.a = clampf(1.0 - death_text_timer / (animation_duration / 3.0), 0.0, 1.0)
				death_text_timer -= _delta
			elif death_button_timer > 0:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				death_button.modulate.a = clampf(1.0 - death_button_timer / (animation_duration / 3.0), 0.0, 1.0)
				death_button_timer -= _delta
		initial_delay -= _delta
		return
		
	# Win condition.
	check_win_condition()

	# Win animation.
	if GameData.game_won:
		if win_initial_delay > 0.0:
			win_initial_delay -= _delta
			return
		
		# Hide pause controls and menu.
		pause_button.visible = false
		pause_menu.visible = false
		PauseManager.pause_game()
		
		if win_text_timer > 0.0:
			win_text.modulate.a = clampf(1.0 - win_text_timer / (win_animation_duration / 3.0), 0.0, 1.0)
			win_text_timer -= _delta
		elif win_button_timer > 0.0:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			win_button.modulate.a = clampf(1.0 - win_button_timer / (win_animation_duration / 3.0), 0.0, 1.0)
			win_button_timer -= _delta
		return
	
	if Input.is_action_just_pressed("Pause"):
		PauseManager.toggle_pause()
	
	if pause_menu:
		if PauseManager.is_paused: 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			pause_menu.visible = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			pause_menu.visible = false
			
	
	if is_instance_valid(touch_controlls):
		if GameData.is_touch and not touch_controlls.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			touch_controlls.visible = true
		elif not GameData.is_touch and touch_controlls.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			touch_controlls.visible = false
	
	process_texture(dash_cooldown, 21, player_controller.dash_cooldown_time, player_controller.dash_cooldown_timer, 16, 16)
	process_texture(foam_tank, 31, player_controller.foam_canon.max_foam, player_controller.foam_canon.current_foam, 48, 16)

func player_death(death: bool) -> void:
	if death:
		pause_button.visible = false
		pause_menu.visible = false
		death_background.visible = true
		death_button.visible = true
		death_text.visible = true
		
		death_background_timer = animation_duration / 3
		death_button_timer = animation_duration / 3
		death_text_timer = animation_duration / 3

func check_win_condition() -> void:
	if GameData.game_won or GameData.is_player_dead:
		return

	if GameData.current_toxins >= GameData.level_toxins:
		player_win()

func player_win() -> void:
	if GameData.game_won or GameData.is_player_dead:
		return

	GameData.game_won = true
	
	var current_scene := get_tree().current_scene

	if current_scene:
		var scene_uid := ResourceLoader.get_resource_uid(current_scene.scene_file_path)
		var current_id = ResourceUID.id_to_text(scene_uid)

		if current_id == LevelQ1:
			GameData.q1 = true
		elif current_id == LevelQ2:
			GameData.q2 = true
		elif current_id == LevelQ3:
			GameData.q3 = true
		elif current_id == LevelQ4:
			GameData.q4 = true
	
	win_screen.visible = true
	win_text.visible = true
	win_button.visible = true

	win_text.modulate.a = 0.0
	win_button.modulate.a = 0.0

	win_text_timer = win_animation_duration / 2.0
	win_button_timer = win_animation_duration / 2.0
