extends EnemyMovementComponent

@export var seperation_min: float = 64
@export var seperation_max: float = 128
@export var far_speed_mult: float = 5.0
@export var close_speed_mult: float = 0.5


var segment: Segment

func setup(_enemy: Enemy, rotates: bool = true) -> void: 
	enemy = _enemy
	segment = enemy as Segment
	rotates_visual = rotates
	
	
	
func _physics_process(delta: float) -> void:
	if not segment.do_circle: return
	var target_speed: float = current_speed
	if enemy == null:
		return
	if not segment.started:
		return
	match segment.segment_type:
		Segment.SegmentLocation.HEAD:
			var player: Player = get_tree().get_first_node_in_group(&"player")
			var current_dir: Vector2 = segment.global_position.direction_to(player.global_position)
			var distance: float = segment.global_position.distance_to(player.global_position)

			var radius_error: float = distance - segment.player_orbit_radius
			var correction_angle: float = clampf(radius_error * 0.01, -PI / 3.0, PI / 3.0)

			var orbit_angle: float = segment.orbit_direction * (PI / 2.0 - correction_angle)
			dir = current_dir.rotated(orbit_angle)
		_:
			if segment.ahead_segment:
				dir = segment.global_position.direction_to(segment.ahead_segment.global_position)
				var dist: float = segment.global_position.distance_squared_to(segment.ahead_segment.global_position)
				if dist < seperation_min ** 2:
					target_speed = current_speed * close_speed_mult
				elif dist > seperation_max ** 2:
					target_speed = current_speed * far_speed_mult
	segment.rotation = dir.angle() + PI/2.0
	
	var target_movement_velocity: Vector2 = target_speed * dir
	var move_lerp_factor: float = 1.0 - exp(-decay_coefficient * delta)
	var active_movement_velocity: Vector2 = enemy.velocity.lerp(target_movement_velocity, move_lerp_factor)
	var kb_lerp_factor: float = 1.0 - exp(-knockback_decay_coefficient * delta)
	current_knockback = current_knockback.lerp(Vector2.ZERO, kb_lerp_factor)

	if current_knockback.length_squared() < 1.0:
		current_knockback = Vector2.ZERO
		
	enemy.velocity = active_movement_velocity + current_knockback
	enemy.move_and_slide()
	
