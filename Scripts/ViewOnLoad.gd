extends Node

@export var is_visible := true

func _ready() -> void:
	self.visible = is_visible
