extends Button

@export var target_physics_object: Node2D
@export var offset: Vector2 = Vector2(0, -50) # Position button above the object
@onready var soft_body_parent = get_parent() 
func _process(_delta: float) -> void:
	if target_physics_object:
		# Match global screen position directly
		global_position = target_physics_object.global_position + offset

func _ready() -> void:
	_toggle_physics_recursive(soft_body_parent, false)

func _on_pressed() -> void:
	# 1. Check if the parent is currently running physics loop
	var is_physics_active = soft_body_parent.is_physics_processing()
	
	# 2. Toggle physics loop on the parent node
	soft_body_parent.set_physics_process(!is_physics_active)
	
	# 3. Handle the soft body's internal components 
	# Soft bodies in 2D use child RigidBody2Ds/Joints to move.
	# We freeze or unfreeze them recursively while ignoring this button.
	_toggle_physics_recursive(soft_body_parent, !is_physics_active)
	

func _toggle_physics_recursive(current_node: Node, enable: bool) -> void:
	for child in current_node.get_children():
		# Do NOT freeze the button itself or it won't receive future clicks
		if child == self:
			continue
			
		# Freeze or freeze_mode handles RigidBody2D stopping instantly in Godot 4
		if child is RigidBody2D:
			child.freeze = !enable
			# Optional: prevent forces/gravity integration when frozen
			child.set_use_custom_integrator(!enable) 
			
		# Continue down the tree if there are nested physics components
		if child.get_child_count() > 0:
			_toggle_physics_recursive(child, enable)
