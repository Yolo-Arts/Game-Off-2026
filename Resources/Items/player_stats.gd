class_name PlayerStats extends Resource

@export var max_health: float = 100.0
@export var health_usage_per_second: float = 1.0
@export var max_energy: float = 100.0
@export var energy_increase: float = 10.0
@export var energy_ram_cost: float = 20.0
@export var invincibility_duration_seconds: float = 1.0
@export var damage: float = 10.0
@export var max_speed: float = 600.0
@export var steering_speed: float = 2 * PI
@export var acceleration: float = 80.0
@export var deacceleration: float = 200.0
@export var minimum_ram_speed: float = 200.0
@export var attack_cooldown: float = 0.5
@export var critical_chance: float = 0.10
@export var critical_damage_multiplier: float = 1.5
@export var luck: float  = 1.0
@export var healing_efficiency: float = 1.0
@export var knockback: float = 500.0
@export var shots_per_second: float = 2.0
@export var shot_damage: float = 20.0
@export var shot_cost: float = 5.0
@export var shot_knockback: float = 200.0
@export var shot_speed: float = 3000.0
@export var shot_range: float = 4000.0
@export var shot_scale: Vector2 = Vector2.ONE

func get_computed_damage() -> float:
	var final_damage: float = damage
	if randf() <= critical_chance:
		final_damage *= critical_damage_multiplier
	return final_damage
