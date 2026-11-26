extends SegmentBossRoam

var enemy_spawn_timer: float = 5.0
@export var enemy_spawn_time: float = 3.0

@export var wormies: Array[EnemyData] = []

func process_state(_delta: float) -> StringName:
	roam_change_timer = max(0.0, roam_change_timer - _delta)
	color_change_timer = max(0.0, roam_change_timer - _delta)
	if color_change_timer == 0.0:
		segment.change_color(1.0)
		color_change_timer = color_change_time
	if roam_change_timer == 0.0:
		if scheduled_roam_state != &"":
			handle_roam_state(scheduled_roam_state)
		else:
			var possible_roam_states: Array[StringName] = segment.roam_states.duplicate()
			possible_roam_states.erase(segment.last_roam_state)
			var next_roam_state = possible_roam_states.pick_random()
			handle_roam_state(next_roam_state)
			segment.last_roam_state = next_roam_state
		
	enemy_spawn_timer = max(0.0, enemy_spawn_timer - _delta)
	if enemy_spawn_timer <= 0.0:
		enemy_spawn_timer = enemy_spawn_time
		EventSystem.request_spawn_enemy.emit(wormies.pick_random(), get_tree().get_first_node_in_group(&"player"))
		
	return NO_STATE
