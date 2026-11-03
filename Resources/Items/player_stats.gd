class_name PlayerStats extends Resource

@export var max_health: float = 100.0
@export var damage: float = 10.0
@export var max_speed: float = 600.0
@export var steering_speed: float = 2 * PI
@export var acceleration: float = 80.0
@export var minimum_attack_speed: float = 200.0
@export var attack_cooldown: float = 0.5
@export var critical_chance: float = 0.10
@export var critical_damage_multiplier: float = 1.5
@export var luck: float  = 1.0
@export var healing_efficiency: float = 1.0

func get_computed_damage() -> float:
	var final_damage: float = damage
	if randf() <= critical_chance:
		final_damage *= critical_damage_multiplier
	return final_damage
