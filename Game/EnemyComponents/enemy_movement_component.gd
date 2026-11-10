extends Node
class_name EnemyMovementComponent

var steer: float = 1.0
var current_speed: float
var body:Enemy

func setup(_enemy: Enemy) -> void: 
	body = _enemy
	

func _process(delta: float) -> void:
	var player : Node2D = get_tree().get_first_node_in_group("player")
	
	var dir = (player.position - body.position).normalized() 
	
	
	body.rotation = dir.angle()
	body.velocity = dir * current_speed
	body.move_and_slide()
	
	
	
	
