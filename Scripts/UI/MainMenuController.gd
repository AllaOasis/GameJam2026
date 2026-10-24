extends Control
class_name MainMenuController

@export var info: CanvasItem
@export var settings: CanvasItem
@export var credits: CanvasItem

func _ready() -> void: open(true, false, false)

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
