extends Node

func scale_up_and_down(object: Object, scale_up: float, scale_down: float, up_duration: float, down_duration: float) -> void :
	var tween = object.create_tween()
	tween.tween_property(object, "scale", scale_up * Vector2.ONE, up_duration)
	tween.tween_property(object, "scale", scale_down * Vector2.ONE, down_duration)
	await tween.finished


func flash(object: Object, flash_color: Color, end_color: Color, duration: float, ramp_duration: float) -> void :
	var tween = object.create_tween()
	tween.tween_property(object, "modulate", flash_color, ramp_duration)
	tween.tween_property(object, "modulate", end_color, ramp_duration).set_delay(duration - 2 * ramp_duration)
	await tween.finished


func shake(object: Object, intensity: float = 1.0, duration: float = 1.0) -> void :
	# TODO if time allows add settings integration for screenshake
	#if ConfigManager.shake_intensity == 0: return
	#
	#intensity *= ConfigManager.shake_intensity
	
	if !object.has_meta("initial_position"):
		object.set_meta("initial_position", object.position)
		
	var initial_position = object.get_meta("initial_position")
	var tween = object.create_tween()
	tween.tween_method( func(x): object.position = initial_position + Vector2(randf_range( - x, x), randf_range( - x, x)), intensity, intensity, duration)
	await tween.finished
	
	object.position = initial_position

var camera
