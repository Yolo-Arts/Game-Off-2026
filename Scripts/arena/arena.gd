extends Node2D
class_name Arena

@export var turret_path : Path2D
@export var reverse_turret_path : Path2D
@export var visuals : ArenaVisuals


func pick_random_path() -> Path2D:
	return turret_path if randf() > 0.5 else reverse_turret_path


func resize_arena(corners : int, radius : float) -> void:
	if visuals == null:
		return
	visuals.generate_shape(corners, radius)
