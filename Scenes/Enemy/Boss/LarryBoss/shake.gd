extends Sprite2D

@export var power: float = 16
var origin_pos: Vector2
func _ready() -> void:
	origin_pos = position

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	position = origin_pos + Vector2(randf_range(-power, power), randf_range(-power, power))
