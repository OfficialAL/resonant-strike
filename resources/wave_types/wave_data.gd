extends Resource
class_name WaveData

## Resource for defining wave attack patterns

@export var wave_name: String = "Basic Wave"
@export var base_damage: float = 15.0
@export var wave_speed: float = 12.0
@export var wave_lifetime: float = 3.0
@export var wave_color: Color = Color.WHITE

# Wave behavior
@export var can_be_reflected: bool = true
@export var can_be_absorbed: bool = true
@export var can_be_dispersed: bool = true

# Special properties
@export var piercing: bool = false  # Passes through first target
@export var homing: bool = false    # Tracks target
@export var split_on_impact: bool = false  # Splits into multiple waves
