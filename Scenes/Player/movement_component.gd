class_name PlayerMovementComponent
extends Node

var player: Player
var speed: float = 0.0
var steer: float = 0.0

func setup(_player: Player) -> void:
	player = _player

func get_steer_input() -> float:
	return Input.get_axis("move_left", "move_right")

func get_thrust_input() -> float:
	return Input.get_axis("move_down", "move_up")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	var stats: PlayerStats = player.get_current_stats()
	
	if player.can_steer:
		steer = get_steer_input()
		
	player.rotation += steer * stats.steering_speed * delta
	
	if player.can_control_speed:
		if get_thrust_input() == 1.0:
			speed = move_toward(speed, stats.max_speed, delta * stats.acceleration)
		elif get_thrust_input() == -1.0:
			speed = move_toward(speed, 0.0, delta * stats.deacceleration)
		
	player.velocity = -player.transform.y * speed
	player.move_and_slide()
