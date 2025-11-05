# Test script to verify enums
extends Node

enum AttackDirection {
	CHAIN_PUNCH,     # I - Rapid centerline punch
	TAN_DA,          # J - Simultaneous block and strike
	LAP_SAU,         # K - Pulling hand/redirect
	PAK_SAU          # L - Slapping hand/trap
}

func _ready():
	print("Testing enum: ", AttackDirection.CHAIN_PUNCH)
	print("Testing enum: ", AttackDirection.TAN_DA)
	var test_dir: AttackDirection = AttackDirection.TAN_DA
	print("Enum assignment works: ", test_dir)