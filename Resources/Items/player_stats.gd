class_name PlayerStats extends Resource

@export var max_health: float = 100.0
@export var health_usage_per_second: float = 1.0
# TODO implement this: fuel_gain_on_currency_pickup
@export var fuel_gain_on_currency_pickup: float = 0.0
@export var max_energy: float = 100.0
@export var starting_energy: float = 0.0
@export var energy_increase: float = 2.0
@export var energy_ram_cost: float = 20.0
@export var energy_regen_rate: float = 0.0

@export var invincibility_duration_seconds: float = 1.0
@export var damage: float = 10.0
@export var max_speed: float = 600.0
@export var steering_speed: float = 2 * PI
@export var acceleration: float = 80.0
@export var deacceleration: float = 200.0
@export var minimum_ram_speed: float = 200.0
@export var attack_cooldown: float = 0.5
@export var critical_chance: float = 0.0
@export var critical_damage_multiplier: float = 1.1
@export var luck: float  = 0.0
@export var healing_efficiency: float = 1.0
@export var knockback: float = 500.0
@export var shrapnel_damage: float = 2.0
@export var shots_per_second: float = 2.0
@export var shot_damage: float = 20.0
# TODO implement this:
@export var shot_cost: float = 10.0
# TODO implement this (do we want this??):
@export var shot_knockback: float = 200.0
@export var shot_speed: float = 3000.0
@export var shot_range: float = 4000.0
@export var shot_scale: Vector2 = Vector2.ONE
@export var recoil: float = 100.0
@export var gear_currency_value: int = 0
@export var star_currency_value: int = 0
@export var currency_pickup_radius_multi: float = 1.0
@export var shrapnel_count: int = 1
@export var time_per_wave: float = 5.0
@export var enemies_per_wave: Vector2i = Vector2i(3, 5)
@export var ram_bullet_energy_increase: float = 0.0
@export var ram_bullet_fuel_increase: float = 0.0
@export var unlocked_turrets: int = 1
@export var unlocked_missiles: int = 0
@export var missile_count: int = 10
@export var missile_speed: float = 3000.0
@export var missile_damage: int = 50
@export var missile_explosion_radius: float = 500.0
# TODO implement this: 
@export var missile_explosion_knockback: float = 400.0

@export_group("Dash")
@export var dash_duration: float = 0.35
@export var dash_cooldown: float = 3.0
@export var dash_speed: float = 2400.0

@export var max_pierce: int = 1

@export var fuel_pickup_amount_percentage: float = 0.2
@export var pickup_spawn_chance: float = 0.2
@export var energy_pickup_amount: float = 20

func get_computed_damage(shoot: bool = false) -> float:
	var final_damage: float = damage if not shoot else shot_damage
	if randf() <= critical_chance:
		final_damage *= critical_damage_multiplier
	return final_damage
