extends Node
class_name WaveSystem

## Wave energy propagation system for Resonant Strike
## Handles wave creation, collision, absorption, reflection, and dispersion

# Wave types matching stances
enum WaveType {
	COMPRESSION,    # From Rigid stance attacks (I/K)
	SHEAR,          # From Palm stance forward (J)
	PHASE_INVERTED, # From Counter redirect (L)
	ENEMY_ATTACK    # Generic enemy wave
}

# Wave visual configuration
const WAVE_COLORS = {
	WaveType.COMPRESSION: Color.RED,
	WaveType.SHEAR: Color.GREEN,
	WaveType.PHASE_INVERTED: Color.BLUE,
	WaveType.ENEMY_ATTACK: Color.ORANGE
}

# Wave properties
const WAVE_SPEED: float = 12.0
const WAVE_LIFETIME: float = 3.0
const WAVE_EXPAND_RATE: float = 2.0

# Wave pool
var active_waves: Array[Wave] = []

# Signals
signal wave_collision(wave1: Wave, wave2: Wave)
signal wave_absorbed(wave: Wave, absorber: Node3D)
signal wave_reflected(wave: Wave, reflector: Node3D)
signal wave_dispersed(wave: Wave, disperser: Node3D)

# Reference to main scene
var combat_manager: Node = null

class Wave:
	var type: WaveType
	var damage: float
	var direction: Vector3
	var position: Vector3
	var velocity: Vector3
	var radius: float = 0.5
	var lifetime: float
	var owner_node: Node3D  # Player or enemy
	var visual: MeshInstance3D
	var was_reflected: bool = false
	
	func _init(
		_type: WaveType,
		_damage: float,
		_position: Vector3,
		_direction: Vector3,
		_owner: Node3D
	) -> void:
		type = _type
		damage = _damage
		position = _position
		direction = _direction.normalized()
		velocity = direction * WAVE_SPEED
		owner_node = _owner
		lifetime = WAVE_LIFETIME

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	update_waves(delta)
	check_wave_collisions()

## Create a new wave from player attack
func create_player_wave(
	direction: int,  # AttackDirection enum value
	stance: int,     # Stance enum value
	player: Node3D
) -> void:
	var wave_type: WaveType
	var damage: float = 20.0  # Base damage
	
	# Determine wave type from attack direction
	match direction:
		0, 2:  # LEFT or RIGHT (AttackDirection enum)
			wave_type = WaveType.COMPRESSION
		1:  # FORWARD
			wave_type = WaveType.SHEAR
		3:  # REDIRECT
			wave_type = WaveType.PHASE_INVERTED
			damage *= 2.0  # Redirect does bonus damage
		_:
			wave_type = WaveType.COMPRESSION
	
	# Apply stance damage multiplier
	if player.has_method("get_damage_multiplier"):
		damage *= player.get_damage_multiplier()
	
	# Get spawn position and direction from player
	var spawn_pos = player.global_position + Vector3.UP * 1.5
	var dir_vector = player.get_attack_direction_vector(direction) if player.has_method("get_attack_direction_vector") else Vector3.FORWARD
	
	spawn_wave(wave_type, damage, spawn_pos, dir_vector, player)

## Create a new wave from enemy attack
func create_enemy_wave(
	enemy: Node3D,
	target_position: Vector3,
	damage: float = 15.0
) -> void:
	var spawn_pos = enemy.global_position + Vector3.UP * 1.5
	var direction = (target_position - spawn_pos).normalized()
	
	spawn_wave(WaveType.ENEMY_ATTACK, damage, spawn_pos, direction, enemy)

## Spawn a wave into the scene
func spawn_wave(
	type: WaveType,
	damage: float,
	position: Vector3,
	direction: Vector3,
	owner_node: Node3D
) -> Wave:
	var wave = Wave.new(type, damage, position, direction, owner_node)
	
	# Create visual representation
	wave.visual = create_wave_visual(type)
	wave.visual.global_position = position
	add_child(wave.visual)
	
	active_waves.append(wave)
	return wave

## Create visual mesh for wave
func create_wave_visual(type: WaveType) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5
	sphere_mesh.height = 1.0
	mesh_instance.mesh = sphere_mesh
	
	# Create emissive material
	var material = StandardMaterial3D.new()
	material.albedo_color = WAVE_COLORS[type]
	material.emission_enabled = true
	material.emission = WAVE_COLORS[type]
	material.emission_energy_multiplier = 2.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.6
	
	mesh_instance.set_surface_override_material(0, material)
	return mesh_instance

## Update all active waves
func update_waves(delta: float) -> void:
	var waves_to_remove: Array[int] = []
	
	for i in range(active_waves.size() - 1, -1, -1):
		var wave = active_waves[i]
		
		# Update position
		wave.position += wave.velocity * delta
		wave.visual.global_position = wave.position
		
		# Update lifetime
		wave.lifetime -= delta
		if wave.lifetime <= 0:
			waves_to_remove.append(i)
			continue
		
		# Expand wave visually
		wave.radius += WAVE_EXPAND_RATE * delta
		var scale = wave.radius / 0.5
		wave.visual.scale = Vector3.ONE * scale
		
		# Fade out as lifetime expires
		var alpha = wave.lifetime / WAVE_LIFETIME
		var material = wave.visual.get_surface_override_material(0) as StandardMaterial3D
		if material:
			material.albedo_color.a = alpha * 0.6
	
	# Remove expired waves
	for i in waves_to_remove:
		remove_wave(active_waves[i])
		active_waves.remove_at(i)

## Check for collisions between waves
func check_wave_collisions() -> void:
	for i in range(active_waves.size()):
		for j in range(i + 1, active_waves.size()):
			var wave1 = active_waves[i]
			var wave2 = active_waves[j]
			
			# Check if waves are from different owners
			if wave1.owner_node != wave2.owner_node:
				var distance = wave1.position.distance_to(wave2.position)
				if distance < (wave1.radius + wave2.radius):
					handle_wave_collision(wave1, wave2)

## Handle collision between two waves
func handle_wave_collision(wave1: Wave, wave2: Wave) -> void:
	wave_collision.emit(wave1, wave2)
	
	# Phase-inverted waves cancel out regular waves
	if wave1.type == WaveType.PHASE_INVERTED or wave2.type == WaveType.PHASE_INVERTED:
		# Waves cancel each other
		remove_wave(wave1)
		remove_wave(wave2)
		active_waves.erase(wave1)
		active_waves.erase(wave2)
		
		# Play cancel sound effect
		# AudioManager.play_wave_cancel()
	else:
		# Waves interact - create interference pattern
		var avg_position = (wave1.position + wave2.position) / 2.0
		# TODO: Create interference visual effect

## Handle wave hitting player
func wave_hit_player(wave: Wave, player: Node3D) -> void:
	if wave.owner_node == player:
		return  # Can't hit yourself
	
	# Get player stance
	var stance = player.current_stance if player.has("current_stance") else 0
	
	match stance:
		0:  # RIGID - Reflect wave
			reflect_wave(wave, player)
			wave_reflected.emit(wave, player)
		1:  # COUNTER - Absorb wave energy
			if player.has_method("absorb_wave_energy"):
				player.absorb_wave_energy(wave.damage * 0.5)
			remove_wave(wave)
			active_waves.erase(wave)
			wave_absorbed.emit(wave, player)
		2:  # PALM - Disperse wave
			if player.has_method("take_damage"):
				player.take_damage(wave.damage * 0.3)  # Reduced damage
			remove_wave(wave)
			active_waves.erase(wave)
			wave_dispersed.emit(wave, player)
		_:  # Default - take full damage
			if player.has_method("take_damage"):
				player.take_damage(wave.damage)
			remove_wave(wave)
			active_waves.erase(wave)

## Handle wave hitting enemy
func wave_hit_enemy(wave: Wave, enemy: Node3D) -> void:
	if wave.owner_node == enemy:
		return
	
	# Enemy can parry or take damage
	if enemy.has_method("try_parry_wave"):
		if enemy.try_parry_wave(wave):
			reflect_wave(wave, enemy)
			return
	
	# Deal damage to enemy
	if enemy.has_method("take_damage"):
		enemy.take_damage(wave.damage)
	
	remove_wave(wave)
	active_waves.erase(wave)

## Reflect a wave back at the sender
func reflect_wave(wave: Wave, reflector: Node3D) -> void:
	if wave.was_reflected:
		# Already reflected once, destroy it
		remove_wave(wave)
		active_waves.erase(wave)
		return
	
	# Reverse direction
	wave.direction = -wave.direction
	wave.velocity = wave.direction * WAVE_SPEED
	wave.owner_node = reflector
	wave.was_reflected = true
	wave.damage *= 1.3  # Reflected waves deal more damage
	
	# Update visual color to show it's reflected
	var material = wave.visual.get_surface_override_material(0) as StandardMaterial3D
	if material:
		material.emission_energy_multiplier = 3.0

## Remove a wave and its visual
func remove_wave(wave: Wave) -> void:
	if wave.visual and wave.visual.is_inside_tree():
		wave.visual.queue_free()

## Clear all active waves
func clear_all_waves() -> void:
	for wave in active_waves:
		remove_wave(wave)
	active_waves.clear()
