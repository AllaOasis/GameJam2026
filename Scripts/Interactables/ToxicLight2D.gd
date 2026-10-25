extends PointLight2D
class_name ToxicLight2D

@export var textures: Array[Texture2D] = []
@export var min_interval: float = 0.1
@export var max_interval: float = 0.5

func _ready() -> void:
	randomize()
	change_texture()

func change_texture() -> void:
	if(PauseManager.is_paused): return
	if textures.size() < 1: return
	texture = textures.pick_random()

	var timer := randf_range(min_interval, max_interval)
	await get_tree().create_timer(timer).timeout
	change_texture()
