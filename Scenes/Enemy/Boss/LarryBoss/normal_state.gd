class_name SegmentBossRoam extends SegmentBossState

var roam_change_timer: float = 0.0
@export var color_change_time: float = 10.0
var color_change_timer: float = color_change_time
@export var roam_change_time: float = 5.0
var scheduled_roam_state: StringName = &""

var random_counter: int = 0

func handle_roam_state(state: StringName) -> void:
	var player: Player = get_tree().get_first_node_in_group(&"player")
	if not player:
		return
	var boss_movement: SegmentBossMVCP = segment.movement_component as SegmentBossMVCP
	if not boss_movement:
		return
	match state:
		&"random":
			segment.can_set_enemy_shift_speed = false
			var random_angle: float = randf_range(0, 2 * PI)
			var random_distance: float = randf_range(100.0, 1000.0)
			var random_speed: float = randf_range(1000.0, 1200.0)
			var target_pos: Vector2 = player.global_position + Vector2(cos(random_angle), sin(random_angle)) * random_distance
			boss_movement.current_speed = random_speed
			boss_movement.move_towards_dir = segment.global_position.direction_to(target_pos)
			segment.do_circle = false
			roam_change_timer = randf_range(0.5, 3.0)
			if random_counter < 3.0:
				random_counter += 1
				scheduled_roam_state = &"random"
			else:
				random_counter = 0
				scheduled_roam_state = &""
			
		&"circle":
			segment.can_set_enemy_shift_speed = true
			segment.orbit_direction = [-1, 1].pick_random()
			segment.do_circle = true
			segment.update_dimension_speed(player.shift_color)
			roam_change_timer = roam_change_time
		_:
			# TODO add visual change, to all segments
			segment.can_set_enemy_shift_speed = false
			boss_movement.current_speed = 2000.0
			segment.do_circle = false
			boss_movement.move_towards_dir = segment.global_position.direction_to(player.global_position)
			roam_change_timer = 2.0
		

func enter(_data: Variant) -> void:
	pass

func process_state(_delta: float) -> StringName:
	roam_change_timer = max(0.0, roam_change_timer - _delta)
	color_change_timer = max(0.0, color_change_timer - _delta)
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
		
		
		
	return NO_STATE
