class_name damage_number extends Label

signal complete(node)

func display(_val : int) -> void:
	text = str(_val)
	self_modulate = Color.WHITE
	scale = Vector2.ONE * 2.5
	modulate.a = 1.0
	
	
func play(_pos: Vector2) -> void: 
	
	global_position = _pos
	var x := _pos + Vector2(randf_range(-15,15), -35)
	var t:= create_tween().set_parallel()
	t.tween_property(self, "global_position", x, 0.55) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# t.tween_property(self, "scale", Vector2.ONE,0.3)
	t.tween_property(self,"modulate:a", 0.0, 0.6).set_delay(0.15)
	t.chain().tween_callback(func(): complete.emit(self))
	
	
	

	
	
