extends Control
class_name MainMenuController

@export_subgroup("Map")
@export var castle_q1: CanvasItem
@export var castle_q2: CanvasItem
@export var castle_q3: CanvasItem
@export var castle_q4: CanvasItem
@export var castle_mist: CanvasItem
@export var the_end: CanvasItem

@export_subgroup("Menus")
@export var info: CanvasItem
@export var settings: CanvasItem
@export var credits: CanvasItem

@export_subgroup("Cheats")
@export var cheat1: CanvasItem
@export var cheat2: CanvasItem
@export var cheat3: CanvasItem
@export var cheat4: CanvasItem
@export var cheat5: CanvasItem
@export var cheat6: CanvasItem

@export_subgroup("Sound")
@export var main_theme: AudioStreamPlayer2D
@export var win_theme: AudioStreamPlayer2D

func _ready() -> void:
	open(true, false, false)
	GameData.data_changed.connect(_reload_map)
	_reload_map()

	if GameData.q1 and GameData.q2 and GameData.q3 and GameData.q4:
		_full_unlock()
	else:
		if the_end: the_end.visible = false
		if cheat1: cheat1.visible = false
		if cheat2: cheat2.visible = false
		if cheat3: cheat3.visible = false
		if cheat4: cheat4.visible = false
		if cheat5: cheat5.visible = false
		if cheat6: cheat6.visible = false
		if main_theme:
			main_theme.autoplay = false
			main_theme.play()
		if win_theme:
			win_theme.autoplay = false
			win_theme.stop()

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
	if the_end: the_end.visible = true
	if cheat1: cheat1.visible = true
	if cheat2: cheat2.visible = true
	if cheat3: cheat3.visible = true
	if cheat4: cheat4.visible = true
	if cheat5: cheat5.visible = true
	if cheat6: cheat6.visible = true
	if main_theme: 
		main_theme.autoplay = false
		main_theme.stop()
	if win_theme: 
		win_theme.autoplay = true
		win_theme.play()
