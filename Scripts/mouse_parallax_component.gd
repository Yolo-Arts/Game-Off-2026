class_name MouseParallaxComponent
extends Node

@export var max_offset: Vector2 = Vector2(24.0, 18.0)
@export var smoothing: float = 4.0
@export var target: Node2D

var _target: Node2D
var _current_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	if _target == null:
		_target = get_parent() as Node2D
	else:
		_target = target
	
	if _target == null:
		push_warning("MouseParallaxComponent must be a child of a Node2D. Anything else is bad...")
		set_process(false)


func _process(delta: float) -> void:
	var viewport_size: Vector2 = _target.get_viewport_rect().size
	if viewport_size == Vector2.ZERO:
		return
	
	var mouse_pos: Vector2 = _target.get_viewport().get_mouse_position()
	var screen_center: Vector2 = viewport_size * 0.5
	
	var normalized_offset: Vector2 = ((mouse_pos - screen_center) / screen_center).clamp(-Vector2.ONE, Vector2.ONE)
	
	var target_offset: Vector2 = -normalized_offset * max_offset
	var next_offset: Vector2 = _current_offset.lerp(target_offset, 1.0 - exp(-smoothing * delta))
	
	_target.position += next_offset - _current_offset
	_current_offset = next_offset
