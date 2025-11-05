extends CanvasLayer
class_name GameHUD

## Game HUD for Resonant Strike
## Displays health, resonance meter, stance indicator, and wave counter

# References
var player: PlayerController = null

# UI Elements (to be created in scene)
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/PlayerStats/HealthBar if has_node("MarginContainer/VBoxContainer/PlayerStats/HealthBar") else null
@onready var resonance_bar: ProgressBar = $MarginContainer/VBoxContainer/PlayerStats/ResonanceBar if has_node("MarginContainer/VBoxContainer/PlayerStats/ResonanceBar") else null
@onready var stance_label: Label = $MarginContainer/VBoxContainer/StanceInfo/StanceLabel if has_node("MarginContainer/VBoxContainer/StanceInfo/StanceLabel") else null
@onready var wave_counter: Label = $MarginContainer/VBoxContainer/WaveInfo/WaveCounter if has_node("MarginContainer/VBoxContainer/WaveInfo/WaveCounter") else null
@onready var enemy_health_bar: ProgressBar = $MarginContainer/VBoxContainer/EnemyStats/EnemyHealthBar if has_node("MarginContainer/VBoxContainer/EnemyStats/EnemyHealthBar") else null

# Stance names for display
const STANCE_NAMES = {
	0: "RIGID",     # S - Red
	1: "COUNTER",   # W - Blue
	2: "PALM",      # A - Green
	3: "RESERVED"   # D - Yellow
}

const STANCE_COLORS = {
	0: Color.RED,
	1: Color.BLUE,
	2: Color.GREEN,
	3: Color.YELLOW
}

func _ready() -> void:
	# Find player
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		connect_player_signals()
		update_player_stats()
	
	# Find combat manager
	var combat_manager = get_node_or_null("/root/Main/CombatManager")
	if combat_manager:
		combat_manager.wave_completed.connect(_on_wave_completed)
		combat_manager.enemy_spawned.connect(_on_enemy_spawned)

## Connect to player signals
func connect_player_signals() -> void:
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_player_health_changed)
	if player.has_signal("resonance_changed"):
		player.resonance_changed.connect(_on_player_resonance_changed)
	if player.has_signal("stance_changed"):
		player.stance_changed.connect(_on_stance_changed)

## Update player health bar
func _on_player_health_changed(new_health: float) -> void:
	if health_bar:
		health_bar.value = (new_health / player.max_health) * 100.0
		
		# Color code health bar
		if health_bar.value > 60:
			health_bar.modulate = Color.GREEN
		elif health_bar.value > 30:
			health_bar.modulate = Color.YELLOW
		else:
			health_bar.modulate = Color.RED

## Update resonance bar
func _on_player_resonance_changed(new_resonance: float) -> void:
	if resonance_bar:
		resonance_bar.value = (new_resonance / player.max_resonance) * 100.0
		
		# Glow effect when near full
		if resonance_bar.value > 80:
			resonance_bar.modulate = Color(0.5, 0.5, 1.5)
		else:
			resonance_bar.modulate = Color.WHITE

## Update stance display
func _on_stance_changed(new_stance: int) -> void:
	if stance_label:
		stance_label.text = "STANCE: " + STANCE_NAMES.get(new_stance, "UNKNOWN")
		stance_label.modulate = STANCE_COLORS.get(new_stance, Color.WHITE)

## Update wave counter
func _on_wave_completed(wave_number: int) -> void:
	if wave_counter:
		wave_counter.text = "WAVE: " + str(wave_number)

## Update enemy health when new enemy spawns
func _on_enemy_spawned(enemy: EnemyBase) -> void:
	if enemy_health_bar:
		enemy_health_bar.max_value = enemy.max_health
		enemy_health_bar.value = enemy.current_health
		
		# Connect to enemy health updates
		# (This would need to be implemented via signal in enemy)

## Update all player stats
func update_player_stats() -> void:
	if player:
		_on_player_health_changed(player.current_health)
		_on_player_resonance_changed(player.current_resonance)
		_on_stance_changed(player.current_stance)

## Show combat tip
func show_tip(tip: String, duration: float = 3.0) -> void:
	# TODO: Implement tip display
	pass
