extends Resource
class_name EnemyData

## Resource for defining enemy types and their properties

@export var enemy_name: String = "Enemy"
@export var max_health: float = 80.0
@export var attack_damage: float = 15.0
@export var attack_cooldown: float = 1.5
@export var parry_chance: float = 0.3
@export var redirect_chance: float = 0.2
@export var aggression_level: float = 1.0
@export var reaction_time: float = 0.5

# Visual properties
@export var mesh_color: Color = Color.WHITE
@export var mesh_scale: Vector3 = Vector3.ONE

# Optional custom behavior script
@export var behavior_script: GDScript = null
