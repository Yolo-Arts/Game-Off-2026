class_name StatBar extends TextureProgressBar

@export var event_bus_signal: Array[StringName]
@export var tween_duration: float = 0.25
@export var lerp_speed: float = 10.0

var target_value: float
var target_max_value: float
var max_tween: Tween
var value_tween: Tween

func _ready() -> void:
	if event_bus_signal.is_empty():
		push_error("NO SIGNALS SET FOR -> ", name)
		return
	
	for sig in event_bus_signal:
		if EventSystem.has_signal(sig):
			EventSystem.connect(sig, _stat_changed)

func _process(delta: float) -> void:
	value = lerpf(value, target_value, lerp_speed * delta)
	max_value = lerpf(max_value, target_max_value, lerp_speed * delta)
	
func _stat_changed(new_value: float, new_max: float = max_value, initialize: bool = false) -> void:
	if initialize:
		value = new_value
		max_value = new_max
	target_value = new_value
	target_max_value = new_max
