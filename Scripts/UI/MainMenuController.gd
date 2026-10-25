extends Control
class_name MainMenuController

@export_subgroup("Map")
@export var castle_q1: CanvasItem
@export var castle_q2: CanvasItem
@export var castle_q3: CanvasItem
@export var castle_q4: CanvasItem
@export var castle_mist: CanvasItem

@export_subgroup("Menus")
@export var info: CanvasItem
@export var settings: CanvasItem
@export var credits: CanvasItem

func _ready() -> void: 
	open(true, false, false)
	_reload_map()
	GameData.data_changed.connect(_reload_map)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("OpenSettings"): open(false, true, false)
	if Input.is_action_just_pressed("OpenCredits"): open(false, false, true)
	if Input.is_action_just_pressed("Close"): open(true, false, false)
			
func open(ib: bool, sb: bool, cb: bool) -> void:
	if info and info.visible != ib:
		info.visible = ib
	if settings and settings.visible != sb:
		settings.visible = sb
	if credits and credits.visible != cb:
		credits.visible = cb
		
func _reload_map() -> void:
	if castle_q1: castle_q1.visible = not GameData.q1
	if castle_q2: castle_q2.visible = not GameData.q2
	if castle_q3: castle_q3.visible = not GameData.q3
	if castle_q4: castle_q4.visible = not GameData.q4
	if GameData.q1 and GameData.q2 and GameData.q3 and GameData.q4:
		_full_unlock()

func _full_unlock():
	if castle_mist: castle_mist.visible = false;
