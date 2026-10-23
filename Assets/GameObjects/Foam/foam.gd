
extends Area2D
class_name FoamProjectile

@export var small_texture: Texture2D
@export var medium_texture: Texture2D
@export var sprite: Sprite2D

@export_range(0.0, 1.0, 0.01) var medium_chance: float = 0.25

@export_subgroup("Behaviour")
@export var launch_speed: float = 260.0
@export var damage: int = 1
@export var lifetime: float = 4.0
@export var destroy_on_hit: bool = true
@export var damage_on_ground: bool = false

var velocity: Vector2 = Vector2.ZERO
var timer: float = 0.0
var is_landed: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func launch(direction: Vector2) -> void:
	if sprite:
		if medium_texture and randf() < medium_chance:
			sprite.texture = medium_texture
		elif small_texture:
			sprite.texture = small_texture
	velocity = direction.normalized() * launch_speed


func _physics_process(delta: float) -> void:
	timer += delta

	if timer >= lifetime:
		queue_free()
		return

	if not is_landed:
		velocity.y += gravity * delta
		global_position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		_hit_target(body)
	else:
		_land()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		_hit_target(area)
	elif area.get_parent().has_method("take_damage"):
		_hit_target(area.get_parent())


func _hit_target(target: Node) -> void:
	target.take_damage(damage)

	if destroy_on_hit:
		queue_free()


func _land() -> void:
	if damage_on_ground:
		return

	is_landed = true
	velocity = Vector2.ZERO
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
