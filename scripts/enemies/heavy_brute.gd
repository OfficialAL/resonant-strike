extends EnemyBase
class_name HeavyBrute

## Heavy Brute enemy type
## Characteristics: High health, powerful attacks, slow

func _ready() -> void:
	super._ready()
	
	# Override stats for Heavy Brute
	max_health = 120.0
	current_health = max_health
	attack_damage = 25.0
	attack_cooldown = 2.5  # Slower attacks
	parry_chance = 0.4  # Better parry chance
	redirect_chance = 0.3
	aggression_level = 0.7  # Less aggressive
	reaction_time = 0.8  # Slower reactions
