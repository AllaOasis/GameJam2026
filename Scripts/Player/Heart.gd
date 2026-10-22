extends Control
class_name Heart

@onready var sprite: Sprite2D = $HeartSprite

func set_heart_state(health: int, toxin_level: int) -> void:
	if sprite == null:
		sprite = get_node("HeartSprite")

	var health_frame: int = clampi(2 - health, 0, 2)
	var toxin_group: int = clampi(toxin_level, 0, 2)

	sprite.frame = toxin_group * 3 + health_frame
