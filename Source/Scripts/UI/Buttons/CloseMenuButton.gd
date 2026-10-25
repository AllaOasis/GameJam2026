extends TextureButton
class_name CloseMenuButton

@export var target_node: Node


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if not is_instance_valid(target_node):
		push_error("CloseMenuButton: No target node assigned.")
		return

	target_node.hide()
	target_node.process_mode = Node.PROCESS_MODE_DISABLED
