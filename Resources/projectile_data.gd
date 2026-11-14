class_name ProjectileData extends Resource
@export var damage: float = 10.0
@export var knockback: float = 10.0
@export var scale: Vector2 = Vector2.ONE
@export var speed: float = 500.0
@export var direction: Vector2 = Vector2.ONE
@export var life_time_seconds: float = 5.0
@export var range_pixels: float = 1000.0
@export var use_range: bool = true
@export var enemy: bool = false
func convert_range_to_life_time() -> float:
	return range_pixels / speed
