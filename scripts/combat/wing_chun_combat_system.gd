extends Node
class_name WingChunCombatSystem

## Custom Wing Chun combat system for precise martial arts detection
## Uses Area3D hitboxes/hurtboxes with Wing Chun frame data

# Wing Chun technique frame data
var TECHNIQUE_FRAME_DATA = {
	0: {  # CHAIN_PUNCH
		"startup": 8, "active": 4, "recovery": 12, "damage": 15,
		"knockback": Vector2(100, 0), "shape_size": Vector3(0.3, 0.3, 1.2),
		"position": Vector3(0, 0, -1.0)
	},
	1: {  # TAN_DA
		"startup": 12, "active": 6, "recovery": 16, "damage": 12,
		"knockback": Vector2(80, -20), "shape_size": Vector3(0.8, 0.4, 0.8),
		"position": Vector3(0.3, 0, -0.8)
	},
	2: {  # LAP_SAU
		"startup": 16, "active": 8, "recovery": 20, "damage": 20,
		"knockback": Vector2(150, 0), "shape_size": Vector3(0.6, 1.0, 0.6),
		"position": Vector3(-0.3, 0, -0.9)
	},
	3: {  # PAK_SAU
		"startup": 6, "active": 3, "recovery": 8, "damage": 8,
		"knockback": Vector2(50, 0), "shape_size": Vector3(0.6, 0.3, 0.6),
		"position": Vector3(0.4, 0, -0.7)
	}
}

# Wing Chun stance defensive properties
var STANCE_PROPERTIES = {
	0: {  # BONG_SAU
		"defense_multiplier": 0.7, "redirect_angle": 45.0, "parry_window": 10,
		"hurtbox_size": Vector3(1.2, 1.8, 0.8), "color": Color.RED
	},
	1: {  # TAN_SAU
		"defense_multiplier": 0.8, "redirect_angle": 30.0, "parry_window": 12,
		"hurtbox_size": Vector3(1.0, 1.6, 0.8), "color": Color.BLUE
	},
	2: {  # WU_SAU
		"defense_multiplier": 0.9, "redirect_angle": 0.0, "parry_window": 8,
		"hurtbox_size": Vector3(0.8, 1.6, 0.6), "color": Color.GREEN
	},
	3: {  # CHI_SAU
		"defense_multiplier": 0.85, "redirect_angle": 15.0, "parry_window": 14,
		"hurtbox_size": Vector3(1.0, 1.6, 1.0), "color": Color.YELLOW
	}
}

## Create Area3D hitbox for Wing Chun technique
func create_technique_hitbox(technique_type: int, parent_node: Node3D) -> Area3D:
	var data = TECHNIQUE_FRAME_DATA[technique_type]
	
	# Create hitbox Area3D
	var hitbox = Area3D.new()
	hitbox.name = "WingChunHitbox_" + str(technique_type)
	hitbox.monitoring = false  # Start inactive
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = data.shape_size
	collision_shape.shape = shape
	hitbox.add_child(collision_shape)
	
	# Position hitbox
	hitbox.position = data.position
	
	# Store technique data as metadata
	hitbox.set_meta("technique_type", technique_type)
	hitbox.set_meta("damage", data.damage)
	hitbox.set_meta("knockback", data.knockback)
	hitbox.set_meta("startup_frames", data.startup)
	hitbox.set_meta("active_frames", data.active)
	hitbox.set_meta("recovery_frames", data.recovery)
	
	# Add to parent
	parent_node.add_child(hitbox)
	
	return hitbox

## Create Area3D hurtbox for Wing Chun stance
func create_stance_hurtbox(stance_type: int, parent_node: Node3D) -> Area3D:
	var data = STANCE_PROPERTIES[stance_type]
	
	# Create hurtbox Area3D
	var hurtbox = Area3D.new()
	hurtbox.name = "WingChunHurtbox_" + str(stance_type)
	hurtbox.monitoring = true  # Always active for defense
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = data.hurtbox_size
	collision_shape.shape = shape
	hurtbox.add_child(collision_shape)
	
	# Position at center
	hurtbox.position = Vector3.ZERO
	
	# Store stance data as metadata
	hurtbox.set_meta("stance_type", stance_type)
	hurtbox.set_meta("defense_multiplier", data.defense_multiplier)
	hurtbox.set_meta("redirect_angle", data.redirect_angle)
	hurtbox.set_meta("parry_window", data.parry_window)
	
	# Add to parent
	parent_node.add_child(hurtbox)
	
	return hurtbox

## Handle frame-based hitbox activation (precise timing)
func activate_hitbox_sequence(hitbox: Area3D, parent_node: Node3D) -> void:
	var startup = hitbox.get_meta("startup_frames")
	var active = hitbox.get_meta("active_frames") 
	var recovery = hitbox.get_meta("recovery_frames")
	
	# Startup frames (inactive)
	await parent_node.get_tree().create_timer(startup * (1.0/60.0)).timeout
	
	# Activate hitbox
	hitbox.monitoring = true
	print("Wing Chun technique ACTIVE - frame ", startup)
	
	# Active frames
	await parent_node.get_tree().create_timer(active * (1.0/60.0)).timeout
	
	# Deactivate hitbox
	hitbox.monitoring = false
	print("Wing Chun technique RECOVERY - frame ", startup + active)
	
	# Recovery frames
	await parent_node.get_tree().create_timer(recovery * (1.0/60.0)).timeout
	
	# Remove hitbox
	hitbox.queue_free()
	print("Wing Chun technique COMPLETE")

## Resolve combat when hitbox meets hurtbox
func resolve_wing_chun_collision(
	hitbox: Area3D, 
	hurtbox: Area3D, 
	timing_frame: int
) -> Dictionary:
	
	var attack_damage = hitbox.get_meta("damage")
	var defense_mult = hurtbox.get_meta("defense_multiplier")
	var parry_window = hurtbox.get_meta("parry_window")
	var redirect_angle = hurtbox.get_meta("redirect_angle")
	var knockback = hitbox.get_meta("knockback")
	
	# Check if within parry window
	var can_parry = timing_frame <= parry_window
	
	var result = {
		"hit_connects": not can_parry,
		"parry_successful": can_parry,
		"final_damage": attack_damage * defense_mult,
		"knockback": knockback,
		"redirect_angle": redirect_angle if can_parry else 0.0,
		"technique_type": hitbox.get_meta("technique_type"),
		"stance_type": hurtbox.get_meta("stance_type")
	}
	
	return result

## Get Wing Chun stance color for visual feedback
func get_stance_color(stance_type: int) -> Color:
	if STANCE_PROPERTIES.has(stance_type):
		return STANCE_PROPERTIES[stance_type].color
	return Color.WHITE

## Validate Wing Chun principles in combat
func validate_wing_chun_principles(technique_type: int, stance_type: int) -> bool:
	# Centerline theory
	if technique_type == 0:  # CHAIN_PUNCH
		return stance_type == 2  # WU_SAU centerline guard
	
	# Simultaneous attack and defense
	if technique_type == 1:  # TAN_DA
		return true  # Tan Da embodies this principle
	
	# Economy of motion
	return get_technique_efficiency(technique_type, stance_type) > 0.7

## Calculate efficiency based on Wing Chun principles
func get_technique_efficiency(technique_type: int, stance_type: int) -> float:
	var base_efficiency = 0.8
	
	# Bonus for proper combinations
	if technique_type == 0 and stance_type == 2:  # CHAIN_PUNCH + WU_SAU
		base_efficiency += 0.2  # Centerline combination
	
	if technique_type == 1 and stance_type == 1:  # TAN_DA + TAN_SAU
		base_efficiency += 0.15  # Simultaneous block/strike
	
	return min(base_efficiency, 1.0)