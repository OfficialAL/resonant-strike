extends CharacterBody3D
class_name PlayerController

## Player controller for Resonant Strike with Wing Chun Combat System integration
## CONTROLS:
## WASD: Switch between Wing Chun stances (W=BONG_SAU, A=TAN_SAU, S=WU_SAU, D=CHI_SAU)
## IJKL: Execute Wing Chun techniques (I=CHAIN_PUNCH, J=TAN_DA, K=LAP_SAU, L=PAK_SAU)
## Player remains stationary - enemies come to you!

# Import Wing Chun combat system
const WingChunCombat = preload("res://scripts/combat/wing_chun_combat_system.gd")

# Wing Chun stances
enum Stance {
	BONG_SAU,    # W - Deflecting/Wing arm - high risk, redirects force
	TAN_SAU,     # A - Dispersing hand - absorbs and neutralizes  
	WU_SAU,      # S - Guarding hand - safe, protective
	CHI_SAU      # D - Sticky hands - advanced sensing/trapping
}

# Wing Chun techniques - with combat system integration
enum AttackDirection {
	CHAIN_PUNCH,     # I - Rapid centerline punch
	TAN_DA,          # J - Simultaneous block and strike
	LAP_SAU,         # K - Pulling hand/redirect
	PAK_SAU          # L - Slapping hand/trap
}

# Player stats
@export var max_health: float = 100.0
@export var max_resonance: float = 100.0

# Current state
var current_health: float
var current_resonance: float
var current_stance: Stance = Stance.WU_SAU  # Start in guard position
var is_attacking: bool = false
var can_switch_stance: bool = true

# Wing Chun stance properties  
const STANCE_COLORS = {
	Stance.BONG_SAU: Color.RED,     # Deflecting wing - dangerous
	Stance.TAN_SAU: Color.BLUE,     # Dispersing hand - controlled
	Stance.WU_SAU: Color.GREEN,     # Guarding hand - safe
	Stance.CHI_SAU: Color.YELLOW    # Sticky hands - advanced
}

const STANCE_DAMAGE_MULTIPLIERS = {
	Stance.BONG_SAU: 1.5,    # High damage when deflecting
	Stance.TAN_SAU: 0.8,     # Lower damage, builds energy
	Stance.WU_SAU: 1.0,      # Balanced damage
	Stance.CHI_SAU: 1.2      # Sensing advantage
}

const STANCE_DEFENSE_MULTIPLIERS = {
	Stance.BONG_SAU: 1.4,    # High risk - can be overwhelmed
	Stance.TAN_SAU: 0.6,     # Excellent absorption
	Stance.WU_SAU: 0.8,      # Good protection  
	Stance.CHI_SAU: 0.7      # Sensitivity allows evasion
}

# Attack cooldowns
@export var attack_cooldown: float = 0.3
var attack_timer: float = 0.0

# References (to be set in scene)
@onready var human_model: Node3D = $Visual/HumanModel
@onready var stance_indicator: MeshInstance3D = $Camera3D/StanceIndicator
@onready var left_arm_controller = $Visual/LeftArm/LeftArmController if has_node("Visual/LeftArm/LeftArmController") else null
@onready var right_arm_controller = $Visual/RightArm/RightArmController if has_node("Visual/RightArm/RightArmController") else null
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

# Signals
signal stance_changed(new_stance: Stance)
signal attack_performed(direction: AttackDirection, stance: Stance)
signal resonance_changed(new_value: float)
signal health_changed(new_value: float)
signal player_overloaded()

# Wing Chun combat system
var wing_chun_system: WingChunCombat
var current_hitbox: Area3D = null
var current_hurtbox: Area3D = null
var attack_frame_count: int = 0
var is_in_attack_frames: bool = false

func _ready() -> void:
	current_health = max_health
	current_resonance = 0.0
	
	# Initialize Wing Chun combat system
	wing_chun_system = WingChunCombat.new()
	add_child(wing_chun_system)
	
	# Setup initial hurtbox for current stance
	setup_stance_hurtbox()
	
	# Debug stance indicator
	if stance_indicator:
		print("Stance indicator found!")
		print("Stance indicator position: ", stance_indicator.global_position)
		print("Stance indicator visible: ", stance_indicator.visible)
	else:
		print("ERROR: Stance indicator not found!")
	
	update_stance_visual()

	# Give the human selector one frame to instantiate the imported scene, then try to attach arms to the skeleton
	# This will create BoneAttachment3D nodes under the Skeleton3D and reparent our Left/Right arm viewmodels there,
	# preserving their global transforms so the first-person view doesn't jump.
	await get_tree().process_frame
	attach_arms_to_human_skeleton()

func _process(delta: float) -> void:
	# Update attack cooldown
	if attack_timer > 0:
		attack_timer -= delta
		is_attacking = attack_timer > 0

func _physics_process(_delta: float) -> void:
	# Handle stance switching
	handle_stance_input()
	
	# Handle attacks  
	handle_attack_input()
	
	# Stationary combat - no movement needed
	velocity = Vector3.ZERO
	move_and_slide()

## Handle stance switching with W/A/S/D - stationary combat
func handle_stance_input() -> void:
	if not can_switch_stance or is_attacking:
		return
	
	var new_stance: Stance = current_stance
	
	# WASD maps to the four Wing Chun stances
	if Input.is_action_just_pressed("stance_counter"):  # W - Forward/Offensive
		new_stance = Stance.BONG_SAU  # Wing arm - high risk deflection
		print("Switched to BONG SAU - Wing Arm (High Risk Deflection)")
	elif Input.is_action_just_pressed("stance_palm"):  # A - Left/Absorbing  
		new_stance = Stance.TAN_SAU   # Dispersing hand - neutralizes force
		print("Switched to TAN SAU - Dispersing Hand (Force Absorption)")
	elif Input.is_action_just_pressed("stance_rigid"):  # S - Back/Defensive
		new_stance = Stance.WU_SAU    # Guarding hand - safe protection
		print("Switched to WU SAU - Guarding Hand (Safe Defense)")
	elif Input.is_action_just_pressed("stance_reserved"):  # D - Right/Advanced
		new_stance = Stance.CHI_SAU   # Sticky hands - sensing/trapping
		print("Switched to CHI SAU - Sticky Hands (Advanced Sensing)")
	
	if new_stance != current_stance:
		switch_stance(new_stance)

## Switch to a new stance
func switch_stance(new_stance: Stance) -> void:
	current_stance = new_stance
	update_stance_visual()
	stance_changed.emit(new_stance)
	
	# Play stance switch sound
	# AudioManager.play_stance_switch(new_stance)

## Handle attack input with I/J/K/L - execute Wing Chun techniques
func handle_attack_input() -> void:
	if is_attacking:
		return
	
	var attack_dir: AttackDirection = AttackDirection.TAN_DA
	var should_attack: bool = false
	
	# IJKL maps to the four Wing Chun techniques
	if Input.is_action_just_pressed("attack_left"):  # I - Chain punch
		attack_dir = AttackDirection.CHAIN_PUNCH
		should_attack = true
		print("CHAIN PUNCH - Rapid centerline strike!")
	elif Input.is_action_just_pressed("attack_forward"):  # J - Block & strike
		attack_dir = AttackDirection.TAN_DA
		should_attack = true
		print("TAN DA - Simultaneous block and strike!")
	elif Input.is_action_just_pressed("attack_right"):  # K - Redirect
		attack_dir = AttackDirection.LAP_SAU
		should_attack = true
		print("LAP SAU - Pulling hand redirect!")
	elif Input.is_action_just_pressed("attack_redirect"):  # L - Trap
		attack_dir = AttackDirection.PAK_SAU
		should_attack = true
		print("PAK SAU - Slapping hand trap!")
	
	if should_attack:
		perform_attack(attack_dir)

## Perform an attack
func perform_attack(direction: AttackDirection) -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	
	# Create visual energy wave
	create_energy_wave(direction)
	
	# Animate hands based on attack direction
	animate_attack_hands(direction)
	
	# Emit attack signal for wave system to handle
	attack_performed.emit(direction, current_stance)
	
	# Play attack animation
	if animation_player:
		animation_player.play("attack_" + AttackDirection.keys()[direction].to_lower())
	
	# Consume resonance for redirect attacks (Lap Sau)
	if direction == AttackDirection.LAP_SAU and current_stance == Stance.TAN_SAU:
		var _resonance_damage = current_resonance * 2.0  # Amplified damage
		current_resonance = 0.0
		resonance_changed.emit(current_resonance)

## Create visual energy wave based on Wing Chun technique
func create_energy_wave(direction: AttackDirection) -> void:
	var wave = MeshInstance3D.new()
	var wave_mesh = SphereMesh.new()
	wave_mesh.radius = 0.12
	wave_mesh.height = 0.24
	wave.mesh = wave_mesh
	
	# Enhanced material with metallic and emission properties
	var material = StandardMaterial3D.new()
	material.albedo_color = get_wave_color(direction)
	
	# Make it glow and look energetic
	material.emission_enabled = true
	material.emission = material.albedo_color * 2.0  # Brighter emission
	material.metallic = 0.3
	material.roughness = 0.2
	material.rim_enabled = true
	material.rim = 1.0
	material.rim_tint = 0.5
	
	# Transparency and fresnel effect
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.8
	material.flags_transparent = true
	material.flags_use_point_size = true
	
	wave.material_override = material
	
	# Position wave at hand/attack origin
	wave.position = global_position + Vector3(0, 1.2, -0.3)  # More at chest level
	get_tree().current_scene.add_child(wave)
	
	# Animate wave toward enemy
	animate_wave_to_target(wave, direction)
	
	print("🌊 Created ", get_technique_name(direction), " energy wave!")

## Get wave color based on technique and stance
func get_wave_color(direction: AttackDirection) -> Color:
	var base_color = STANCE_COLORS[current_stance]
	
	match direction:
		AttackDirection.CHAIN_PUNCH:
			return base_color.lerp(Color.YELLOW, 0.3)  # Fast energy
		AttackDirection.TAN_DA:
			return base_color.lerp(Color.WHITE, 0.4)   # Balanced energy
		AttackDirection.LAP_SAU:
			return base_color.lerp(Color.CYAN, 0.5)    # Pulling energy
		AttackDirection.PAK_SAU:
			return base_color.lerp(Color.MAGENTA, 0.3) # Trapping energy
	
	return base_color

## Get technique name for display
func get_technique_name(direction: AttackDirection) -> String:
	match direction:
		AttackDirection.CHAIN_PUNCH:
			return "CHAIN PUNCH"
		AttackDirection.TAN_DA:
			return "TAN DA"
		AttackDirection.LAP_SAU:
			return "LAP SAU"
		AttackDirection.PAK_SAU:
			return "PAK SAU"
	return "UNKNOWN"

## Animate wave traveling to target
func animate_wave_to_target(wave: MeshInstance3D, _direction: AttackDirection) -> void:
	if not wave:
		return
		
	var target_position = global_position + Vector3(0, 1, -2.5)  # Closer enemy position
	var _start_position = wave.position
	var travel_time = 0.8
	
	# Create smooth wave motion
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Position animation
	tween.tween_property(wave, "position", target_position, travel_time)
	
	# Scale animation (wave grows as it travels)
	tween.tween_property(wave, "scale", Vector3(1.5, 1.5, 1.5), travel_time)
	
	# Rotation for visual effect
	tween.tween_property(wave, "rotation", Vector3(0, PI * 2, 0), travel_time)
	
	# Fade out animation
	if wave.material_override is StandardMaterial3D:
		var _mat = wave.material_override as StandardMaterial3D
		tween.tween_method(fade_wave_alpha, 0.7, 0.0, travel_time)
		
	# Clean up wave after animation
	await tween.finished
	if wave and is_instance_valid(wave):
		wave.queue_free()
		print("🌊 Wave dispersed!")

## Fade wave alpha during animation
func fade_wave_alpha(_alpha: float) -> void:
	# This will be called by tween to fade the wave
	pass

## Animate hands during Wing Chun techniques
func animate_attack_hands(direction: AttackDirection) -> void:
	if not left_arm_controller or not right_arm_controller:
		return
		
	# Use arm controller animations instead of direct positioning
	match direction:
		AttackDirection.CHAIN_PUNCH:  # I key - Rapid centerline
			print("CHAIN PUNCH - Centerline attack!")
			left_arm_controller.play_technique_animation("CHAIN_PUNCH", false)  # Left guards
			right_arm_controller.play_technique_animation("CHAIN_PUNCH", true)  # Right attacks
			
		AttackDirection.TAN_DA:  # J key - Block and strike
			print("TAN DA - Deflect and counter!")
			left_arm_controller.play_technique_animation("TAN_DA", true)  # Left deflects
			right_arm_controller.play_technique_animation("TAN_DA", false)  # Right strikes
			
		AttackDirection.LAP_SAU:  # K key - Pull/redirect
			print("LAP SAU - Pulling energy!")
			left_arm_controller.play_technique_animation("LAP_SAU", true)  # Left pulls
			right_arm_controller.play_technique_animation("LAP_SAU", false)  # Right counters
			
		AttackDirection.PAK_SAU:  # L key - Trap
			print("PAK SAU - Trapping hand!")
			left_arm_controller.play_technique_animation("PAK_SAU", true)  # Left traps
			right_arm_controller.play_technique_animation("PAK_SAU", false)  # Right follows
	
	# Arms will automatically return to guard position via their controllers

## Update visual representation of current stance
func update_stance_visual() -> void:
	if stance_indicator:
		# Create or update material
		var material = stance_indicator.get_surface_override_material(0) as StandardMaterial3D
		if not material:
			material = StandardMaterial3D.new()
			stance_indicator.set_surface_override_material(0, material)
		
		material.albedo_color = STANCE_COLORS[current_stance]
		
		# Make sure it's visible and properly positioned for first-person
		stance_indicator.visible = true
		print("Stance indicator color changed to: ", STANCE_COLORS[current_stance])
		print("Stance indicator position: ", stance_indicator.position)
	
	# Update arm controllers to match current stance
	if left_arm_controller:
		left_arm_controller.set_stance(current_stance)
	if right_arm_controller:
		right_arm_controller.set_stance(current_stance)

## Take damage from waves or attacks
func take_damage(amount: float, _wave_type: String = "") -> void:
	var actual_damage = amount * STANCE_DEFENSE_MULTIPLIERS[current_stance]
	current_health -= actual_damage
	health_changed.emit(current_health)
	
	if current_health <= 0:
		player_overloaded.emit()
		# Handle player defeat
	
	# Visual feedback
	flash_damage()

## Absorb wave energy (Tan Sau - Dispersing Hand)
func absorb_wave_energy(amount: float) -> void:
	if current_stance == Stance.TAN_SAU:
		current_resonance = min(current_resonance + amount, max_resonance)
		resonance_changed.emit(current_resonance)
		# Visual feedback for absorption

## Get current damage multiplier based on stance
func get_damage_multiplier() -> float:
	var base_multiplier = STANCE_DAMAGE_MULTIPLIERS[current_stance]
	
	# Bonus damage if using resonance with Tan Sau
	if current_stance == Stance.TAN_SAU and current_resonance > 50:
		base_multiplier *= 1.5
	
	return base_multiplier

## Visual feedback for taking damage
func flash_damage() -> void:
	# TODO: Implement damage flash effect
	pass

# ===== WING CHUN COMBAT SYSTEM INTEGRATION =====

## Setup hurtbox for current stance using Wing Chun system
func setup_stance_hurtbox() -> void:
	# Remove existing hurtbox
	if current_hurtbox:
		current_hurtbox.queue_free()
	
	# Create new hurtbox using Wing Chun combat system
	current_hurtbox = wing_chun_system.create_stance_hurtbox(current_stance, self)
	
	# Connect hit detection
	current_hurtbox.area_entered.connect(_on_hurtbox_hit)
	
	print("Setup hurtbox for stance: ", Stance.keys()[current_stance])

## Create hitbox for Wing Chun technique using combat system
func create_technique_hitbox(technique: AttackDirection) -> void:
	# Remove existing hitbox
	if current_hitbox:
		current_hitbox.queue_free()
	
	# Create new hitbox using Wing Chun combat system
	current_hitbox = wing_chun_system.create_technique_hitbox(technique, self)
	
	# Setup frame timing
	attack_frame_count = 0
	is_in_attack_frames = true
	
	# Start attack frame sequence using Wing Chun system
	wing_chun_system.activate_hitbox_sequence(current_hitbox, self)
	
	print("Created hitbox for technique: ", AttackDirection.keys()[technique])

## Handle attack frame timing for precise Wing Chun combat
func start_attack_frames(hitbox_data: Dictionary) -> void:
	# Startup frames (hitbox inactive)
	await get_tree().create_timer(hitbox_data.startup_frames * (1.0/60.0)).timeout
	
	if not is_in_attack_frames:
		return  # Attack was cancelled
	
	# Activate hitbox during active frames
	if current_hitbox:
		current_hitbox.monitoring = true
		print("Hitbox ACTIVE - frames ", hitbox_data.startup_frames, " to ", hitbox_data.startup_frames + hitbox_data.active_frames)
	
	# Active frames (hitbox active)
	await get_tree().create_timer(hitbox_data.active_frames * (1.0/60.0)).timeout
	
	if not is_in_attack_frames:
		return
	
	# Deactivate hitbox during recovery
	if current_hitbox:
		current_hitbox.monitoring = false
		print("Hitbox INACTIVE - recovery frames")
	
	# Recovery frames (hitbox inactive)
	await get_tree().create_timer(hitbox_data.recovery_frames * (1.0/60.0)).timeout
	
	# Attack complete
	is_in_attack_frames = false
	if current_hitbox:
		current_hitbox.queue_free()
		current_hitbox = null

## Handle when player's hurtbox is hit
func _on_hurtbox_hit(area: Area3D) -> void:
	# Check if this is an enemy attack hitbox
	if area.name.contains("EnemyHitbox"):
		var enemy = area.get_parent()
		if enemy and enemy.has_method("get_attack_data"):
			var attack_data = enemy.get_attack_data()
			handle_wing_chun_combat_interaction(attack_data)

## Resolve combat using Wing Chun + combat system principles
func handle_wing_chun_combat_interaction(enemy_attack_data: Dictionary) -> void:
	# Get current frame timing for parry window
	var timing_frame = attack_frame_count
	
	# Use Wing Chun combat system to resolve combat
	var result = wing_chun_system.resolve_wing_chun_collision(
		enemy_attack_data.get("hitbox", null),
		current_hurtbox,
		timing_frame
	)
	
	if result.parry_successful:
		print("PARRY SUCCESS! Wing Chun defense effective!")
		# Create energy wave on successful parry
		create_parry_energy_wave(result.redirect_angle)
		# Build resonance for successful defense
		current_resonance = min(current_resonance + 15.0, max_resonance)
		resonance_changed.emit(current_resonance)
	elif result.hit_connects:
		print("HIT TAKEN - damage: ", result.final_damage)
		take_damage(result.final_damage)
		# Apply knockback if needed
		if result.knockback != Vector2.ZERO:
			apply_knockback(result.knockback)
	else:
		print("ATTACK MISSED - proper spacing maintained")

## Create energy wave on successful parry
func create_parry_energy_wave(redirect_angle: float) -> void:
	# Create energy wave mesh
	var wave = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.3
	sphere_mesh.height = 0.6
	wave.mesh = sphere_mesh
	
	# Calculate redirect direction based on Wing Chun principles
	var redirect_direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(redirect_angle))
	
	# Enhanced parry wave material
	var material = StandardMaterial3D.new()
	material.albedo_color = STANCE_COLORS[current_stance]
	material.metallic = 0.5  # Extra metallic for parry waves
	material.roughness = 0.1  # Very smooth for deflection
	material.emission_enabled = true
	material.emission = material.albedo_color * 3.0  # Brighter emission
	material.rim_enabled = true
	material.rim_power = 3.0  # Strong rim lighting
	
	wave.material_override = material
	
	# Position and animate parry wave
	get_tree().current_scene.add_child(wave)
	wave.position = global_position + Vector3(0, 1, 0)
	animate_parry_wave(wave, redirect_direction)

## Animate parry energy wave with redirect
func animate_parry_wave(wave: MeshInstance3D, direction: Vector3) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move in redirect direction
	var target_position = wave.position + direction * 5.0
	tween.tween_property(wave, "position", target_position, 1.0)
	
	# Scale up then down
	tween.tween_property(wave, "scale", Vector3(2.0, 2.0, 2.0), 0.5)
	tween.tween_property(wave, "scale", Vector3(0.1, 0.1, 0.1), 0.5).set_delay(0.5)
	
	# Fade out
	tween.tween_method(fade_parry_wave, 1.0, 0.0, 1.0)
	
	# Clean up
	tween.tween_callback(wave.queue_free).set_delay(1.0)

## Fade parry wave alpha
func fade_parry_wave(alpha: float) -> void:
	if current_hitbox and current_hitbox.get_child_count() > 0:
		var material = current_hitbox.get_child(0).material_override as StandardMaterial3D
		if material:
			material.albedo_color.a = alpha

## Apply knockback from enemy attacks
func apply_knockback(knockback: Vector2) -> void:
	# Convert 2D knockback to 3D velocity
	var knockback_3d = Vector3(knockback.x, 0, knockback.y)
	velocity += knockback_3d
	print("Applied knockback: ", knockback_3d)

## Update hurtbox when stance changes
func on_stance_change_wing_chun_update() -> void:
	setup_stance_hurtbox()
	print("Updated Wing Chun hurtbox for new stance: ", Stance.keys()[current_stance])

## Get the direction vector for Wing Chun techniques
func get_attack_direction_vector(direction: AttackDirection) -> Vector3:
	match direction:
		AttackDirection.CHAIN_PUNCH:
			return -transform.basis.z  # Straight centerline
		AttackDirection.TAN_DA:
			return -transform.basis.z  # Forward deflect and strike
		AttackDirection.LAP_SAU:
			return -transform.basis.z  # Pull forward energy
		AttackDirection.PAK_SAU:
			return transform.basis.x   # Across the centerline
	
	return Vector3.ZERO


## Find first Skeleton3D descendant under a node (recursive)
func _find_first_skeleton(root: Node) -> Skeleton3D:
	if not root:
		return null
	for child in root.get_children():
		if child is Skeleton3D:
			return child
		if child.get_child_count() > 0:
			var found := _find_first_skeleton(child)
			if found:
				return found
	return null


## Return first bone name from candidates that exists in the skeleton, or empty string
func _find_bone_in_skeleton(skel: Skeleton3D, candidates: Array) -> String:
	if not skel:
		return ""
	for c in candidates:
		if typeof(c) == TYPE_STRING and skel.find_bone(c) != -1:
			return c
	return ""


## Create a BoneAttachment3D under the given skeleton and reparent the arm node there, preserving global transform
func _create_and_attach(skeleton: Skeleton3D, bone_name: String, arm_node_path: String, attach_name: String) -> void:
	if bone_name == "":
		print("No bone found for ", attach_name)
		return
	var attach := BoneAttachment3D.new()
	attach.name = attach_name
	attach.bone_name = bone_name
	skeleton.add_child(attach)
	# Reparent arm node if present
	if has_node(arm_node_path):
		var arm_node := get_node(arm_node_path)
		var old_global := arm_node.global_transform
		# Remove from old parent and add under attachment
		arm_node.get_parent().remove_child(arm_node)
		attach.add_child(arm_node)
		arm_node.global_transform = old_global
		print("Attached ", arm_node.name, " to bone ", bone_name)
	else:
		print("Arm node not found at path: ", arm_node_path)


## Attach the viewmodel arms to the human model's skeleton via BoneAttachment3D nodes.
## This runs at runtime after the human wrapper instantiates the imported scene.
func attach_arms_to_human_skeleton() -> void:
	if not human_model:
		print("attach_arms_to_human_skeleton: human_model not found")
		return

	var skeleton: Skeleton3D = _find_first_skeleton(human_model)
	if not skeleton:
		print("attach_arms_to_human_skeleton: no Skeleton3D found under HumanModel")
		return

	print("Found Skeleton3D: ", skeleton.name)

	# Candidate bone names gathered from your Blender outliner and common conventions
	var left_candidates := ["MaleArm", "MaleArm.001", "MaleArm.L", "upper_arm.L", "upper_arm_L", "LeftArm", "left_arm", "arm.L", "upper_arm"]
	var right_candidates := ["MaleArm.001", "MaleArm", "MaleArm.R", "upper_arm.R", "upper_arm_R", "RightArm", "right_arm", "arm.R", "upper_arm"]

	var left_bone := _find_bone_in_skeleton(skeleton, left_candidates)
	var right_bone := _find_bone_in_skeleton(skeleton, right_candidates)

	# Try attach left and right (calls top-level helper)
	_create_and_attach(skeleton, left_bone, "Visual/LeftArm", "BoneAttach_LeftArm")
	_create_and_attach(skeleton, right_bone, "Visual/RightArm", "BoneAttach_RightArm")

	print("attach_arms_to_human_skeleton: finished")
