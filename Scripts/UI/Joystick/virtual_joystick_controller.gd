extends Control

signal joystick_moved(direction: Vector2)

@export var radius: float = 60.0

@onready var base: Control = $JoystickBase
@onready var knob: Control = $JoystickKnob

var direction: Vector2 = Vector2.ZERO
var dragging: bool = false
var touch_index: int = -1


func _ready() -> void:
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	knob.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event: InputEvent) -> void:
	# Android touch input
	if event is InputEventScreenTouch:
		if event.pressed and not dragging:
			# Only activate when touching the visible joystick base
			if base.get_global_rect().has_point(event.position):
				dragging = true
				touch_index = event.index
				_update_joystick(event.position)

		elif not event.pressed and dragging and event.index == touch_index:
			_release_joystick()

	# Android touch dragging
	elif event is InputEventScreenDrag:
		if dragging and event.index == touch_index:
			_update_joystick(event.position)

	# PC mouse input
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not dragging:
				# Only activate when clicking the visible joystick base
				if base.get_global_rect().has_point(event.position):
					dragging = true
					touch_index = -2
					_update_joystick(event.position)

			elif not event.pressed and dragging and touch_index == -2:
				_release_joystick()

	# PC mouse dragging
	elif event is InputEventMouseMotion:
		if dragging and touch_index == -2:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				_update_joystick(event.position)


func _update_joystick(screen_pos: Vector2) -> void:
	var center: Vector2 = base.global_position + base.size / 2.0
	var offset: Vector2 = screen_pos - center

	# Keep the knob within the joystick radius
	offset = offset.limit_length(radius)

	knob.global_position = center + offset - knob.size / 2.0

	# Normalize direction to a maximum magnitude of 1
	direction = offset / radius

	joystick_moved.emit(direction)
	simulate_direction(direction)


func _release_joystick() -> void:
	dragging = false
	touch_index = -1
	direction = Vector2.ZERO

	# Reset the knob to the center of the base
	knob.global_position = (
		base.global_position + (base.size - knob.size) / 2.0
	)

	# Release simulated inputs
	simulate_direction(Vector2.ZERO)
	joystick_moved.emit(direction)


func simulate_direction(dir: Vector2) -> void:
	# Horizontal: Left and Right
	if dir.x < 0.0:
		Input.action_release("Right")
		Input.action_press("Left", -dir.x)
	elif dir.x > 0.0:
		Input.action_release("Left")
		Input.action_press("Right", dir.x)
	else:
		Input.action_release("Left")
		Input.action_release("Right")

	# Vertical: Down only (positive Y)
	if dir.y > 0.5:
		Input.action_press("Down", dir.y)
	else:
		Input.action_release("Down")
