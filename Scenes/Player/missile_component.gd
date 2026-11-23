extends Node
class_name MissileComponent

var missile_count: int = 0
var player_stats: PlayerStats

func setup(_player: Player) -> void:
	player_stats = _player.get_current_stats()
	set_missiles()

func get_missiles() -> int:
	return missile_count

func set_missiles() -> void:
	missile_count = player_stats.missile_count

func can_fire_missiles() -> bool:
	return missile_count > 0

func consume_missile() -> void:
	missile_count = max(0, missile_count - 1)
