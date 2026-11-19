extends ProgressBarLabel

func _ready():
	super()
	
	text = "%d/%d" % [ceilf(parent.value), parent.max_value]

func _stat_changed(new_value: float, new_max: float = parent.max_value, _initialize: bool = false) -> void:
	text = "%d/%d" % [ceilf(new_value), new_max]
