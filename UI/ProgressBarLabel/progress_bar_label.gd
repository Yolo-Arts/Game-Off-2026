extends Label

var parent
var event_bus_signal: Array[StringName]

func _ready():
	parent = get_parent()
	event_bus_signal = parent.event_bus_signal
	
	if event_bus_signal.is_empty():
		push_error("NO SIGNALS SET FOR -> ", name)
		return
	
	for sig in event_bus_signal:
		if EventSystem.has_signal(sig):
			EventSystem.connect(sig, _stat_changed)
	
	
	if parent == null: return
	
	text = "%d/%d" % [parent.value, parent.max_value]

func _stat_changed(new_value: float, new_max: float = parent.max_value) -> void:
	print("Hi")
	text = "%d/%d" % [new_value, new_max]
