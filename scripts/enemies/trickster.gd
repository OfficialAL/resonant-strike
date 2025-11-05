extends EnemyBase
class_name Trickster

## Trickster enemy type
## Characteristics: High parry/redirect, unpredictable, moderate stats

func _ready() -> void:
	super._ready()
	
	# Override stats for Trickster
	max_health = 70.0
	current_health = max_health
	attack_damage = 15.0
	attack_cooldown = 1.2
	parry_chance = 0.5  # Very high parry chance
	redirect_chance = 0.45  # Very high redirect chance
	aggression_level = 1.0
	reaction_time = 0.4

## Override decision making for more unpredictable behavior
func make_decision() -> void:
	if is_attacking or is_parrying:
		return
	
	# Trickster has more varied behavior
	var roll = randf()
	
	if roll < 0.35:
		attempt_attack()
	elif roll < 0.7:
		enter_parry_stance()
	# else: do nothing (feint)
