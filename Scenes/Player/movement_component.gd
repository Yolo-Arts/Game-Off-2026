class_name PlayerMovementComponent
extends Node

var player: Player
var speed: float = 0.0
var steer: float = 0.0
func setup(_player: Player) -> void:
	player = _player

func get_steer_input() -> float:
	return Input.get_axis("move_left", "move_right")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	var stats: PlayerStats = player.get_current_stats()
	
	if player.can_steer:
		steer = get_steer_input()
		
	player.rotation += steer * stats.steering_speed * delta
	speed = move_toward(speed, stats.max_speed, delta * stats.acceleration)
	player.velocity = -player.transform.y * speed
	player.move_and_slide()
