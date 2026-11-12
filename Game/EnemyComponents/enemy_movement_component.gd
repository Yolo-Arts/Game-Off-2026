extends Node
class_name EnemyMovementComponent

var steer: float = 1.0
var current_speed: float
var body:Enemy
var is_asteroid : bool
var dir : Vector2

func setup(_enemy: Enemy) -> void: 
	body = _enemy
	is_asteroid = body.enemy_stats.is_asteroid
	if(is_asteroid): 
		var player: Node2D = get_tree().get_first_node_in_group("player")
		dir = (player.position - body.position).normalized() 
	

		
		
func _process(delta: float) -> void:
	var player : Node2D = get_tree().get_first_node_in_group("player")
	if(!is_asteroid):
		dir = (player.position - body.position).normalized() 
		body.rotation = dir.angle()
		

	else: 
		body.rotation += 2.25 * delta
		if(body.position.distance_squared_to(player.position) > 1000000): #completely abritrary number rn
			# need to find a good distance to realign
			dir = (player.position - body.position).normalized()
		
	
	body.velocity = dir * current_speed
	body.move_and_slide()
	
	
	
	
