extends Node
class_name CombatManager

## Manages the 1v1 PvE combat loop
## Handles enemy spawning, wave detection, combat flow, and victory/defeat

# Enemy spawn configuration
@export var enemy_scenes: Array[PackedScene] = []
@export var initial_spawn_delay: float = 2.0
@export var spawn_delay_between_enemies: float = 1.5

# Combat state
enum CombatState {
	WAITING,
	ACTIVE_COMBAT,
	ENEMY_DEFEATED,
	PLAYER_DEFEATED,
	VICTORY
}

var current_state: CombatState = CombatState.WAITING
var current_enemy: EnemyBase = null
var player: PlayerController = null
var wave_system: WaveSystem = null

# Progression tracking
var enemies_defeated: int = 0
var current_wave_number: int = 1
var difficulty_multiplier: float = 1.0

# Enemy spawn queue
var enemy_queue: Array[String] = []

# References
@onready var enemy_spawn_point: Marker3D = $EnemySpawnPoint if has_node("EnemySpawnPoint") else null
@onready var player_spawn_point: Marker3D = $PlayerSpawnPoint if has_node("PlayerSpawnPoint") else null

# Signals
signal combat_started()
signal enemy_spawned(enemy: EnemyBase)
signal combat_ended(player_won: bool)
signal wave_completed(wave_number: int)

func _ready() -> void:
	# Find or create wave system
	if not has_node("WaveSystem"):
		wave_system = WaveSystem.new()
		wave_system.name = "WaveSystem"
		add_child(wave_system)
	else:
		wave_system = $WaveSystem
	
	# Setup initial enemy queue
	setup_enemy_queue()
	
	# Wait for player to be ready
	await get_tree().create_timer(0.5).timeout
	
	# Find player
	player = get_tree().get_first_node_in_group("player")
	if player:
		connect_player_signals()
	
	# Start first combat after delay
	await get_tree().create_timer(initial_spawn_delay).timeout
	spawn_next_enemy()

func _process(delta: float) -> void:
	if current_state == CombatState.ACTIVE_COMBAT:
		check_wave_collisions()

## Setup the enemy spawn queue for current wave
func setup_enemy_queue() -> void:
	enemy_queue.clear()
	
	# Wave composition based on wave number
	match current_wave_number:
		1:
			enemy_queue = ["FastStriker", "FastStriker"]
		2:
			enemy_queue = ["FastStriker", "HeavyBrute", "FastStriker"]
		3:
			enemy_queue = ["Trickster", "FastStriker", "HeavyBrute"]
		4:
			enemy_queue = ["HeavyBrute", "Trickster", "Trickster"]
		5:
			enemy_queue = ["MiniBoss"]  # Boss fight
		_:
			# Progressive difficulty after wave 5
			for i in range(3 + (current_wave_number - 5)):
				var rand = randf()
				if rand < 0.4:
					enemy_queue.append("FastStriker")
				elif rand < 0.7:
					enemy_queue.append("HeavyBrute")
				else:
					enemy_queue.append("Trickster")

## Spawn the next enemy from queue
func spawn_next_enemy() -> void:
	# Ensure we're ready to spawn
	if not is_inside_tree():
		await tree_entered
	
	if enemy_queue.is_empty():
		# Wave complete
		on_wave_complete()
		return
	
	var enemy_type = enemy_queue.pop_front()
	var enemy_instance: EnemyBase = null
	
	# Try to use scene files first, fallback to script instantiation
	if enemy_scenes.size() > 0:
		# Use the first available enemy scene for now
		var scene = enemy_scenes[0]
		if scene:
			enemy_instance = scene.instantiate() as EnemyBase
	
	# Fallback: create from scripts if no scenes available
	if not enemy_instance:
		match enemy_type:
			"FastStriker":
				enemy_instance = preload("res://scripts/enemies/fast_striker.gd").new()
			"HeavyBrute":
				enemy_instance = preload("res://scripts/enemies/heavy_brute.gd").new()
			"Trickster":
				enemy_instance = preload("res://scripts/enemies/trickster.gd").new()
			_:
				push_error("Unknown enemy type: " + enemy_type)
				spawn_next_enemy()  # Try next
				return
	
	# Create basic 3D representation
	var enemy_node = CharacterBody3D.new()
	enemy_node.set_script(enemy_instance.get_script())
	
	# Add visual
	var visual_container = Node3D.new()
	visual_container.name = "Visual"
	enemy_node.add_child(visual_container)
	
	var mesh = MeshInstance3D.new()
	mesh.name = "Mesh"
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.8, 1.8, 0.6)  # More human proportions
	mesh.mesh = box_mesh
	
	# Enhanced enemy material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.DARK_RED
	material.emission_enabled = true
	material.emission = Color.RED * 0.3  # Subtle glow
	material.metallic = 0.2
	material.roughness = 0.4
	material.rim_enabled = true
	material.rim = 0.5
	mesh.material_override = material
	
	visual_container.add_child(mesh)
	
	# Add collision shape
	var collision = CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = BoxShape3D.new()
	enemy_node.add_child(collision)
	
	# Add enemy to scene tree first
	add_child(enemy_node)
	current_enemy = enemy_node
	
	# Now position enemy safely (after it's in the tree) - MUCH CLOSER for Ip Man style duel
	var spawn_position = Vector3(0, 0, -2.5)  # Ground level to match player - intimate duel distance
	if enemy_spawn_point and enemy_spawn_point.is_inside_tree():
		spawn_position = enemy_spawn_point.global_position
	
	enemy_node.global_position = spawn_position
	
	# Setup enemy
	if player:
		current_enemy.set_target(player)
	
	# Connect signals
	current_enemy.enemy_defeated.connect(_on_enemy_defeated)
	current_enemy.enemy_attack.connect(_on_enemy_attack)
	
	# Apply difficulty scaling
	current_enemy.max_health *= difficulty_multiplier
	current_enemy.current_health = current_enemy.max_health
	current_enemy.attack_damage *= difficulty_multiplier
	
	current_state = CombatState.ACTIVE_COMBAT
	enemy_spawned.emit(current_enemy)
	combat_started.emit()

## Connect player signals
func connect_player_signals() -> void:
	if player.has_signal("attack_performed"):
		player.attack_performed.connect(_on_player_attack)
	if player.has_signal("player_overloaded"):
		player.player_overloaded.connect(_on_player_defeated)

## Handle player attack
func _on_player_attack(direction: int, stance: int) -> void:
	if wave_system:
		wave_system.create_player_wave(direction, stance, player)

## Handle enemy attack
func _on_enemy_attack(enemy: EnemyBase) -> void:
	# Wave already created by enemy, just for tracking
	pass

## Check for wave collisions with combatants
func check_wave_collisions() -> void:
	if not wave_system or not player or not current_enemy:
		return
	
	for wave in wave_system.active_waves:
		# Check collision with player
		if wave.owner_node != player:
			var dist_to_player = wave.position.distance_to(player.global_position)
			if dist_to_player < (wave.radius + 1.0):
				wave_system.wave_hit_player(wave, player)
		
		# Check collision with enemy
		if wave.owner_node != current_enemy:
			var dist_to_enemy = wave.position.distance_to(current_enemy.global_position)
			if dist_to_enemy < (wave.radius + 1.0):
				wave_system.wave_hit_enemy(wave, current_enemy)

## Called when enemy is defeated
func _on_enemy_defeated(_enemy: EnemyBase) -> void:
	enemies_defeated += 1
	current_state = CombatState.ENEMY_DEFEATED
	
	# Clear remaining waves
	if wave_system:
		wave_system.clear_all_waves()
	
	# Spawn next enemy after delay
	await get_tree().create_timer(spawn_delay_between_enemies).timeout
	spawn_next_enemy()

## Called when player is defeated
func _on_player_defeated() -> void:
	current_state = CombatState.PLAYER_DEFEATED
	combat_ended.emit(false)
	
	# Show game over screen
	# TODO: Implement game over UI

## Called when wave is complete
func on_wave_complete() -> void:
	wave_completed.emit(current_wave_number)
	current_wave_number += 1
	difficulty_multiplier += 0.15  # Increase difficulty by 15% each wave
	
	# Setup next wave
	setup_enemy_queue()
	
	# Brief pause before next wave
	await get_tree().create_timer(3.0).timeout
	spawn_next_enemy()

## Reset combat for new game
func reset_combat() -> void:
	current_wave_number = 1
	enemies_defeated = 0
	difficulty_multiplier = 1.0
	current_state = CombatState.WAITING
	
	if wave_system:
		wave_system.clear_all_waves()
	
	if current_enemy:
		current_enemy.queue_free()
		current_enemy = null
	
	setup_enemy_queue()
