extends Node
class_name EnemyMovementComponent

@export var decay_coefficient: float = 1.2
@export var knockback_decay_coefficient: float = 10.0
var current_knockback: Vector2
var dir: Vector2
var enemy :Enemy
var current_speed: float
func setup(_enemy: Enemy) -> void: 
	enemy = _enemy
	

func _process(delta: float) -> void:
	if enemy == null:
		return
	var player : Node2D = get_tree().get_first_node_in_group("player")
	if player:
		dir = enemy.global_position.direction_to(player.global_position)
		
	enemy.rotation = dir.angle()
	
	var target_movement_velocity = current_speed * -enemy.transform.y
	var move_lerp_factor: float = 1.0 - exp(-decay_coefficient * delta)
	var active_movement_velocity = enemy.velocity.lerp(target_movement_velocity, move_lerp_factor)
	var kb_lerp_factor: float = 1.0 - exp(-knockback_decay_coefficient * delta)
	current_knockback = current_knockback.lerp(Vector2.ZERO, kb_lerp_factor)
	
	if current_knockback.length_squared() < 1.0:
		current_knockback = Vector2.ZERO
		
	enemy.velocity = active_movement_velocity + current_knockback
	
	enemy.move_and_slide()
	
