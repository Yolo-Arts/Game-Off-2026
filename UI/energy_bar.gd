class_name EnergyBar extends TextureProgressBar

@export var event_bus_signal: Array[StringName]
@export var tween_duration: float = 0.25

var max_tween: Tween
var value_tween: Tween

func _ready() -> void:
	if event_bus_signal.is_empty():
		push_error("NO SIGNALS SET FOR -> ", name)
		return
	
	for sig in event_bus_signal:
		if EventSystem.has_signal(sig):
			EventSystem.connect(sig, _stat_changed)
			
func _stat_changed(new_value: float, new_max: float = max_value) -> void:
	if max_tween:
		max_tween.kill()
	max_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	max_tween.tween_property(self, "max_value", new_max, tween_duration)
	
	if value_tween:
		value_tween.kill()
	value_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	value_tween.tween_property(self, "value", new_value, tween_duration)
