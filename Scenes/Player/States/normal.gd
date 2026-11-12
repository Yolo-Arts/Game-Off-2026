extends PlayerState

func enter(_data: Variant) -> void:
	player.can_control_speed = true
	player.can_steer = true
	player.can_shift = true
