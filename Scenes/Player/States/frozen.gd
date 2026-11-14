class_name PlayerFrozen extends PlayerState

func enter(_data: Variant) -> void:
	player.can_steer = false
	player.can_control_speed = false
	player.can_shift = false
