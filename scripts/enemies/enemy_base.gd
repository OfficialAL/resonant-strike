extends CharacterBody3D
class_name EnemyBase

## Base class for all enemies in Resonant Strike
## Handles AI behavior, wave attacks, parrying, and redirecting with cinematic timing

# Enemy stats
@export var max_health: float = 80.0
@export var attack_damage: float = 15.0
@export var attack_cooldown: float = 2.5  # Slower, more deliberate attacks
@export var parry_chance: float = 0.3  # 30% chance to parry
@export var redirect_chance: float = 0.2  # 20% chance to redirect

# AI behavior
@export var aggression_level: float = 0.8  # More measured approach
@export var reaction_time: float = 0.8  # Slightly slower for cinematic effect

# Current state
var current_health: float
var attack_timer: float = 0.0
var is_attacking: bool = false
var is_parrying: bool = false
var target: Node3D = null  # Reference to player

# Decision making
var last_wave_time: float = 0.0
var decision_timer: float = 0.0
const DECISION_INTERVAL: float = 0.5  # More deliberate decisions

# Wing Chun techniques for enemy
enum EnemyTechnique {
	STRAIGHT_PUNCH,
	TAN_SAU_STRIKE,
	BONG_SAU_DEFLECT,
	CHI_SAU_TRAP
}

# References
@onready var visual_mesh: MeshInstance3D = $Visual/Mesh if has_node("Visual/Mesh") else null
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

# Signals
signal enemy_attack(enemy: EnemyBase)
signal enemy_defeated(enemy: EnemyBase)
signal wave_parried(wave)

func _ready() -> void:
	current_health = max_health
	decision_timer = randf_range(0, DECISION_INTERVAL)  # Randomize start

func _process(delta: float) -> void:
	# Update attack cooldown
	if attack_timer > 0:
		attack_timer -= delta
		is_attacking = attack_timer > 0
	
	# AI decision making
	decision_timer -= delta
	if decision_timer <= 0 and target:
		make_decision()
		decision_timer = DECISION_INTERVAL

## Make AI decision: attack, wait, or prepare to parry
func make_decision() -> void:
	if is_attacking or is_parrying:
		return
	
	# Random decision weighted by aggression
	var roll = randf()
	
	if roll < (0.4 * aggression_level):
		# Attack
		attempt_attack()
	elif roll < (0.6 * aggression_level):
		# Enter parry stance briefly
		enter_parry_stance()

## Attempt to attack the player with cinematic energy wave
func attempt_attack() -> void:
	if attack_timer > 0 or not target:
		return
	
	print("🥊 Enemy begins attack sequence...")
	
	# Choose a Wing Chun technique
	var technique = choose_attack_technique()
	
	# Telegraph the attack (gives player time to react)
	telegraph_attack(technique)
	
	# Wait for telegraph, then launch attack
	await get_tree().create_timer(0.8).timeout
	
	# Launch the actual energy wave attack
	launch_energy_attack(technique)

## Choose which Wing Chun technique to use
func choose_attack_technique() -> EnemyTechnique:
	var techniques = [
		EnemyTechnique.STRAIGHT_PUNCH,
		EnemyTechnique.TAN_SAU_STRIKE,
		EnemyTechnique.BONG_SAU_DEFLECT,
		EnemyTechnique.CHI_SAU_TRAP
	]
	return techniques[randi() % techniques.size()]

## Telegraph the attack (visual/audio cues)
func telegraph_attack(technique: EnemyTechnique) -> void:
	var technique_name = get_technique_name(technique)
	print("⚡ Enemy telegraphs: ", technique_name)
	
	# Visual telegraph - could be hand positioning, stance change, etc.
	# This gives the player time to react in "slow motion"

## Launch the energy wave attack
func launch_energy_attack(technique: EnemyTechnique) -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	
	print("🌊 Enemy launches ", get_technique_name(technique), " energy wave!")
	
	# Create visual energy wave
	create_enemy_energy_wave(technique)
	
	# Emit signals
	enemy_attack.emit(self)

## Create visual energy wave from enemy to player
func create_enemy_energy_wave(technique: EnemyTechnique) -> void:
	var wave = MeshInstance3D.new()
	var wave_mesh = SphereMesh.new()
	wave_mesh.radius = 0.15  # Slightly larger than player waves
	wave_mesh.height = 0.3
	wave.mesh = wave_mesh
	
	# Set wave color based on technique
	var material = StandardMaterial3D.new()
	material.albedo_color = get_enemy_wave_color(technique)
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.8
	wave.material_override = material
	
	# Position wave at enemy position
	wave.position = global_position + Vector3(0, 1, 0)
	get_tree().current_scene.add_child(wave)
	
	# Animate wave toward player
	animate_enemy_wave_to_player(wave, technique)

## Get technique name for display
func get_technique_name(technique: EnemyTechnique) -> String:
	match technique:
		EnemyTechnique.STRAIGHT_PUNCH:
			return "STRAIGHT PUNCH"
		EnemyTechnique.TAN_SAU_STRIKE:
			return "TAN SAU STRIKE"
		EnemyTechnique.BONG_SAU_DEFLECT:
			return "BONG SAU DEFLECT"
		EnemyTechnique.CHI_SAU_TRAP:
			return "CHI SAU TRAP"
	return "UNKNOWN"

## Get enemy wave color based on technique
func get_enemy_wave_color(technique: EnemyTechnique) -> Color:
	match technique:
		EnemyTechnique.STRAIGHT_PUNCH:
			return Color.ORANGE_RED  # Aggressive direct attack
		EnemyTechnique.TAN_SAU_STRIKE:
			return Color.PURPLE      # Deflecting strike
		EnemyTechnique.BONG_SAU_DEFLECT:
			return Color.DARK_RED    # Wing arm deflection
		EnemyTechnique.CHI_SAU_TRAP:
			return Color.GOLD        # Trapping technique
	return Color.RED

## Animate enemy wave traveling to player
func animate_enemy_wave_to_player(wave: MeshInstance3D, technique: EnemyTechnique) -> void:
	if not wave or not target:
		return
		
	var target_position = target.global_position + Vector3(0, 1, 0)
	var travel_time = 1.2  # Slower for cinematic effect
	
	# Create smooth wave motion
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Position animation
	tween.tween_property(wave, "position", target_position, travel_time)
	
	# Scale animation (wave grows as it travels)
	tween.tween_property(wave, "scale", Vector3(2.0, 2.0, 2.0), travel_time)
	
	# Rotation for visual effect
	tween.tween_property(wave, "rotation", Vector3(PI, PI * 2, 0), travel_time)
	
	# Clean up wave after animation
	await tween.finished
	if wave and is_instance_valid(wave):
		wave.queue_free()
		print("🌊 Enemy wave reaches player!")

## Enter parry stance for a brief window
func enter_parry_stance() -> void:
	is_parrying = true
	await get_tree().create_timer(0.3).timeout
	is_parrying = false

## Try to parry an incoming wave
func try_parry_wave(wave) -> bool:
	# Higher chance if in parry stance, otherwise use base chance
	var parry_roll = randf()
	var effective_chance = parry_chance * 2.0 if is_parrying else parry_chance
	
	if parry_roll < effective_chance:
		# Successful parry
		wave_parried.emit(wave)
		
		# Play parry animation
		if animation_player:
			animation_player.play("parry")
		
		return true
	
	return false

## Take damage from waves or attacks
func take_damage(amount: float) -> void:
	current_health -= amount
	
	# Visual feedback
	flash_damage()
	
	if current_health <= 0:
		on_defeated()

## Called when enemy is defeated
func on_defeated() -> void:
	enemy_defeated.emit(self)
	# Play defeat animation/effect
	queue_free()

## Visual feedback for taking damage
func flash_damage() -> void:
	if visual_mesh:
		var tween = create_tween()
		var material = visual_mesh.get_surface_override_material(0)
		if material:
			tween.tween_property(material, "albedo_color", Color.RED, 0.1)
			tween.tween_property(material, "albedo_color", Color.WHITE, 0.1)

## Set the player as target
func set_target(player: Node3D) -> void:
	target = player

## Get attack priority (for combat manager)
func get_attack_priority() -> float:
	return aggression_level
