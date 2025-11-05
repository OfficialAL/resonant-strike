extends Node
class_name RightArmController

## Independent right arm controller for Wing Chun combat
## Handles right-specific movements and positions

# Reference to the right arm components
@onready var forearm: MeshInstance3D = get_parent().get_node("ArmGeometry/Forearm")
@onready var hand: MeshInstance3D = get_parent().get_node("ArmGeometry/Forearm/Hand")
@onready var hand_hitbox: Area3D = get_parent().get_node("Hitboxes/ForearmHitbox/HandHitbox")

# Right arm specific Wing Chun positions (offset for right side)
const RIGHT_ARM_POSITIONS = {
	# BONG_SAU - Wing arm deflection (Right side)
	0: {
		"forearm_position": Vector3(0.8, -0.3, -0.4),
		"forearm_rotation": Vector3(-20, -15, 10),
		"hand_rotation": Vector3(0, 10, -5),
		"description": "Right wing arm - elevated blocking"
	},
	# TAN_SAU - Dispersing hand (Right side)  
	1: {
		"forearm_position": Vector3(0.7, -0.4, -0.5),
		"forearm_rotation": Vector3(-10, -25, 5),
		"hand_rotation": Vector3(-5, -15, 0),
		"description": "Right dispersing hand - energy redirect"
	},
	# WU_SAU - Protecting hand (Right side)
	2: {
		"forearm_position": Vector3(0.75, -0.35, -0.45),
		"forearm_rotation": Vector3(-15, -10, 0),
		"hand_rotation": Vector3(0, 0, 0),
		"description": "Right protecting hand - centerline guard"
	},
	# CHI_SAU - Sticky hands (Right side)
	3: {
		"forearm_position": Vector3(0.7, -0.3, -0.4),
		"forearm_rotation": Vector3(-20, -15, 5),
		"hand_rotation": Vector3(-5, -8, -3),
		"description": "Right sticky hands - sensitive contact"
	}
}

# Right arm technique movements
const RIGHT_TECHNIQUE_ANIMATIONS = {
	# CHAIN_PUNCH - Right centerline punch
	0: {
		"extension": Vector3(-0.1, 0, -0.3),
		"hand_rotation": Vector3(0, 0, 10),
		"speed": 0.15,
		"description": "Right chain punch"
	},
	# TAN_DA - Right simultaneous block and strike
	1: {
		"extension": Vector3(-0.15, -0.1, -0.25),
		"hand_rotation": Vector3(-10, -20, 5),
		"speed": 0.2,
		"description": "Right tan da"
	},
	# LAP_SAU - Right pulling hand
	2: {
		"extension": Vector3(0.1, 0, -0.1),
		"hand_rotation": Vector3(0, 30, -10),
		"speed": 0.18,
		"description": "Right lap sau"
	},
	# PAK_SAU - Right slapping hand
	3: {
		"extension": Vector3(-0.2, 0, -0.2),
		"hand_rotation": Vector3(5, -25, 10),
		"speed": 0.12,
		"description": "Right pak sau"
	}
}

# Current state
var current_stance: int = 2  # Start with Wu Sau
var current_technique: int = -1
var is_animating: bool = false

# Store initial scene positions
var initial_forearm_position: Vector3
var initial_forearm_rotation: Vector3
var initial_hand_rotation: Vector3

func _ready() -> void:
	# Wait for all nodes to be ready
	await get_tree().process_frame
	
	# Verify all required nodes exist
	if not forearm:
		push_error("Right forearm node not found")
		return
	if not hand:
		push_error("Right hand node not found") 
		return
	if not hand_hitbox:
		push_error("Right hand hitbox not found")
		return
	
	# Store initial scene positions before any modifications
	initial_forearm_position = forearm.position
	initial_forearm_rotation = forearm.rotation_degrees
	initial_hand_rotation = hand.rotation_degrees
	
	print("Right arm controller ready - using scene position: ", initial_forearm_position)
	print("Right arm initial stance: ", RIGHT_ARM_POSITIONS[current_stance].description)

## Set right arm stance
func set_right_arm_stance(stance_id: int) -> void:
	if stance_id < 0 or stance_id > 3:
		push_warning("Invalid right arm stance ID: " + str(stance_id))
		return
	
	if not forearm or not hand:
		push_warning("Right arm nodes not ready")
		return
	
	current_stance = stance_id
	var stance_data = RIGHT_ARM_POSITIONS[stance_id]
	
	# Apply stance rotations as relative adjustments to scene position
	var target_forearm_rotation = initial_forearm_rotation + stance_data.forearm_rotation
	var target_hand_rotation = initial_hand_rotation + stance_data.hand_rotation
	
	# Use scene position with minimal adjustment
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(forearm, "rotation_degrees", target_forearm_rotation, 0.3)
	tween.tween_property(hand, "rotation_degrees", target_hand_rotation, 0.3)
	
	print("Right arm stance: ", stance_data.description)

## Execute right arm technique
func execute_right_technique(technique_id: int) -> void:
	if technique_id < 0 or technique_id > 3 or is_animating:
		return
	
	is_animating = true
	current_technique = technique_id
	var technique_data = RIGHT_TECHNIQUE_ANIMATIONS[technique_id]
	
	# Calculate movement from current scene position
	var current_position = forearm.position
	var technique_position = current_position + technique_data.extension
	var current_hand_rotation = hand.rotation_degrees
	var technique_hand_rotation = current_hand_rotation + technique_data.hand_rotation
	
	# Execute technique
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(forearm, "position", technique_position, technique_data.speed)
	tween.tween_property(hand, "rotation_degrees", technique_hand_rotation, technique_data.speed * 0.8)
	
	await tween.finished
	
	# Return to current position
	var return_tween = create_tween()
	return_tween.set_parallel(true)
	
	return_tween.tween_property(forearm, "position", current_position, technique_data.speed * 1.2)
	return_tween.tween_property(hand, "rotation_degrees", current_hand_rotation, technique_data.speed)
	
	await return_tween.finished
	
	is_animating = false
	current_technique = -1
	print("Right arm technique completed: ", technique_data.description)

## External interface
func set_stance(stance_id: int) -> void:
	set_right_arm_stance(stance_id)

func play_technique_animation(technique_name: String, _is_primary: bool = true) -> void:
	var technique_id = -1
	
	match technique_name:
		"CHAIN_PUNCH":
			technique_id = 0
		"TAN_DA":
			technique_id = 1
		"LAP_SAU":
			technique_id = 2
		"PAK_SAU":
			technique_id = 3
		_:
			push_warning("Unknown right technique: " + technique_name)
			return
	
	execute_right_technique(technique_id)

func can_execute_technique() -> bool:
	return not is_animating
