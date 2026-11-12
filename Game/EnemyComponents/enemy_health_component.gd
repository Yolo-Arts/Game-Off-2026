extends Node
class_name EnemyHealthComponent

@export var max_health: float
var current_health: float
var invincibility_sources: Dictionary[StringName, bool] = {}
var body: Enemy

func setup(_enemy: Enemy) -> void: 
	body = _enemy
	max_health = body.enemy_stats.enemy_health


func take_damage(damage: float) -> void: 
	current_health = clampf(current_health - damage,0 , max_health)
	if(current_health <= 0):
		get_parent().queue_free() #Does all the shindiggery it needs to in the 
	
