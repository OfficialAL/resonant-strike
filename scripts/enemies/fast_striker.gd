extends EnemyBase
class_name FastStriker

## Fast Striker enemy type
## Characteristics: Quick attacks, low health, aggressive

func _ready() -> void:
	super._ready()
	
	# Override stats for Fast Striker
	max_health = 60.0
	current_health = max_health
	attack_damage = 12.0
	attack_cooldown = 0.8  # Faster attacks
	parry_chance = 0.15  # Lower parry chance
	redirect_chance = 0.1
	aggression_level = 1.5  # Very aggressive
	reaction_time = 0.3  # Quick reactions
