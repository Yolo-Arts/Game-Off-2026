class_name PlayerMovementComponent
extends Node

@export var decay_coefficient: float = 14.0
@export var knockback_decay_coefficient: float = 12.0
var current_knockback: Vector2

var player: Player
var dir: Vector2

func setup(_player: Player) -> void:
	player = _player

func get_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	if player.is_dead:
		return
	
	var stats: PlayerStats = player.get_current_stats()
	
	if player.can_steer:
		player.look_at(player.get_global_mouse_position())
		player.rotate(PI/2)
	
	if player.can_control_speed:
		dir = get_input_vector()
	if dir == Vector2.ZERO:
		player.can_reduce_health = false
	else:
		player.can_reduce_health = true
	var target_movement_velocity = stats.max_speed * dir.rotated(player.rotation)
	var move_lerp_factor: float = 1.0 - exp(-decay_coefficient * delta)
	var active_movement_velocity = player.velocity.lerp(target_movement_velocity, move_lerp_factor)
	var kb_lerp_factor: float = 1.0 - exp(-knockback_decay_coefficient * delta)
	
	current_knockback = current_knockback.lerp(Vector2.ZERO, kb_lerp_factor)
	
	if current_knockback.length_squared() < 1.0:
		current_knockback = Vector2.ZERO
	player.velocity = active_movement_velocity + current_knockback
	player.move_and_slide()
