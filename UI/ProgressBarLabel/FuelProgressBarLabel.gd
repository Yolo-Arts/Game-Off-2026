extends ProgressBarLabel

func _ready():
	super()
	
	text = "%d/%d" % [parent.value, parent.max_value]

func _stat_changed(new_value: float, new_max: float = parent.max_value) -> void:
	text = "%d/%d" % [new_value, new_max]
