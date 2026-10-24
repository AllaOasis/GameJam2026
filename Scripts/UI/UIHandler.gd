extends Control
class_name UIHandler

@export_subgroup("Health & Toxins")
@export var hearts_container: HBoxContainer
@export var heart_scene: PackedScene

var player_controller: PlayerController
var hearts: Array[Heart] = []

@export_subgroup("Dash")
@export var dash_cooldown: TextureRect

@export_subgroup("Foam")
@export var foam_tank: TextureRect

@export_subgroup("Menus")
@export var pause_menu: Node

@export_subgroup("Android & Touch")
@export var touch_controlls: Node;



func _ready() -> void:
	# Android & Touch
	if !touch_controlls:
		push_warning("UIHandler: Assign TouchControlls.")

	# Health & Toxins
	while player_controller == null:
		var player_node: Node = get_tree().get_first_node_in_group("player")
		if player_node != null:
			player_controller = player_node as PlayerController
		if player_controller == null:
			await get_tree().process_frame

	if player_controller.hazard_system == null:
		push_warning("UIHandler: PlayerController has no HazardSystem.")
		return

	if hearts_container == null:
		push_warning("UIHandler: Assign HeartsContainer.")
		return

	if heart_scene == null:
		push_warning("UIHandler: Assign Heart Scene.")
		return
	
	if dash_cooldown == null:
		push_warning("UIHandler: Assign Dash Cooldown.")
		return
	
	if foam_tank == null:
		push_warning("UIHandler: Assign Foam Tank.")
		return

	# Connect to HazardSystem™ signals.
	if not player_controller.hazard_system.health_changed.is_connected(_on_health_changed):
		player_controller.hazard_system.health_changed.connect(_on_health_changed)

	if not player_controller.hazard_system.toxin_level_changed.is_connected(_on_toxin_level_changed):
		player_controller.hazard_system.toxin_level_changed.connect(_on_toxin_level_changed)

	create_hearts()

	call_deferred(
		"update_hearts",
		player_controller.hazard_system.current_health,
		player_controller.hazard_system.max_health
	)

func create_hearts() -> void:
	# Remove existing hearts.
	for child in hearts_container.get_children():
		child.queue_free()

	hearts.clear()

	# One heart represents two health points.
	var heart_count: int = ceili(
		float(player_controller.hazard_system.max_health) / 2.0
	)

	for i in range(heart_count):
		var heart: Heart = heart_scene.instantiate() as Heart

		if heart == null:
			push_error("UIHandler: Heart Scene root must use Heart.gd.")
			return

		hearts_container.add_child(heart)
		hearts.append(heart)

func update_hearts(current: int, _maximum: int) -> void:
	var toxins: int = player_controller.hazard_system.toxin_level()

	for i in range(hearts.size()):
		# Each heart represents two health points.
		var health_for_heart: int = clampi(
			current - (i * 2),
			0,
			2
		)

		# Each heart represents two toxin levels.
		var toxins_for_heart: int = clampi(
			toxins - ((hearts.size() - 1 - i) * 2),
			0,
			2
		)

		hearts[i].set_heart_state(
			health_for_heart,
			toxins_for_heart
		)

func _on_health_changed(current: int, maximum: int) -> void:
	update_hearts(current, maximum)

func _on_toxin_level_changed(_toxin_level: int) -> void:
	update_hearts(
		player_controller.hazard_system.current_health,
		player_controller.hazard_system.max_health
	)
	
func process_texture(rect: TextureRect, frame_count: int, maximum: float, current: float, sizeX: int, sizeY: int):
	if !rect:
		return

	if maximum <= 0.0:
		return

	var progress: float = clampf(current / maximum, 0.0, 1.0)
	var frame: int = (frame_count - 1) - roundi(progress * (frame_count - 1))

	var atlas := rect.texture as AtlasTexture
	if atlas == null:
		return

	atlas.region = Rect2(
		Vector2(frame * sizeX, 0),
		Vector2(sizeX,sizeY)
	)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		PauseManager.toggle_pause()
	
	if pause_menu:
		if PauseManager.is_paused: 
			pause_menu.show()
		else: 
			pause_menu.hide()
			
	
	if is_instance_valid(touch_controlls):
		if GameData.is_touch and not touch_controlls.visible:
			touch_controlls.show()
		elif not GameData.is_touch and touch_controlls.visible:
			touch_controlls.hide()
	
	process_texture(dash_cooldown, 21, player_controller.dash_cooldown_time, player_controller.dash_cooldown_timer, 16, 16)
	process_texture(foam_tank, 31, player_controller.foam_canon.max_foam, player_controller.foam_canon.current_foam, 48, 16)
	
