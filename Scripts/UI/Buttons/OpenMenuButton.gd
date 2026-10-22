extends TextureButton
class_name OpenMenuButton

@export var target_node: Node


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if not is_instance_valid(target_node):
		push_error("OpenMenuButton: No target node assigned.")
		return

	target_node.process_mode = Node.PROCESS_MODE_INHERIT
	target_node.visible = !target_node.visible 
