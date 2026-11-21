extends Node
class_name EnemyMovementComponent

@export var decay_coefficient: float = 1.2
@export var knockback_decay_coefficient: float = 10.0
var current_knockback: Vector2
var dir: Vector2
var enemy :Enemy
var rotates_visual: bool
var current_speed: float

func setup(_enemy: Enemy, rotates: bool = true) -> void: 
	enemy = _enemy
	rotates_visual = rotates
	
	
	
func _process(delta: float) -> void:
	if enemy == null:
		return
	var player: Node2D = get_tree().get_first_node_in_group("player")

	if player:
		dir = enemy.global_position.direction_to(player.global_position)
		if rotates_visual:
			enemy.look_at(player.global_position)
			enemy.rotate(PI / 2)
	elif rotates_visual:
		dir = -enemy.transform.y
	
	var target_movement_velocity: Vector2 = current_speed * dir
	var move_lerp_factor: float = 1.0 - exp(-decay_coefficient * delta)
	var active_movement_velocity: Vector2 = enemy.velocity.lerp(target_movement_velocity, move_lerp_factor)
	var kb_lerp_factor: float = 1.0 - exp(-knockback_decay_coefficient * delta)
	current_knockback = current_knockback.lerp(Vector2.ZERO, kb_lerp_factor)

	if current_knockback.length_squared() < 1.0:
		current_knockback = Vector2.ZERO
		
	enemy.velocity = active_movement_velocity + current_knockback
	enemy.move_and_slide()
	
