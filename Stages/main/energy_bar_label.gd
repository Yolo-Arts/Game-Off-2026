extends ProgressBarLabel


func _ready(): 
	super()
	
	text = "%.0f%%" % parent.value

func _stat_changed(new_value: float, new_max: float = parent.max_value) -> void:
	text = "%.0f%%" % new_value
