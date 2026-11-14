class_name EnemyStats extends Resource


@export var max_health: float = 100.0
@export var shift_color: DamageSource.ShiftColor = DamageSource.ShiftColor.NONE
@export var enemy_damage_type: DamageSource.DamageSourceType = DamageSource.DamageSourceType.ENEMY
@export var damage: float = 0.0
@export var knockback: float = 100.0
@export var speed: float = 100.0
@export var opposite_speed: float = 200.0
@export var drop: int = 0
## Multiplied with incoming knocback, bigger number means less resistance
@export var knockback_resistance: float = 1.0:
	set(value):
		knockback_resistance = abs(value)
