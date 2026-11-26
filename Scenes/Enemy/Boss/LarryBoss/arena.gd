extends SegmentBossState


@export var color_change_time: float = 10.0
@export var color_change_timer: float = color_change_time
var enemy_spawn_timer: float = 5.0
@export var enemy_spawn_time: float = 3.0

@export var wormies: Array[EnemyData] = []

func enter(_data: Variant) -> void:
	var player: Player = get_tree().get_first_node_in_group(&"player")
	if not player:
		return
	segment.movement_component.current_speed = 2000.0
	segment.do_circle = true
	segment.can_set_enemy_shift_speed = false
	segment.player_orbit_radius = 1500.0
	
	
func physics_state(_delta: float) -> StringName:
	color_change_timer = max(0.0, color_change_timer - _delta)
	if color_change_timer == 0.0:
		segment.change_color(1.0)
		color_change_timer = color_change_time
	enemy_spawn_timer = max(0.0, enemy_spawn_timer - _delta)
	if enemy_spawn_timer <= 0.0:
		enemy_spawn_timer = enemy_spawn_time
		EventSystem.request_spawn_enemy.emit(wormies.pick_random(), get_tree().get_first_node_in_group(&"player"))
	return NO_STATE
