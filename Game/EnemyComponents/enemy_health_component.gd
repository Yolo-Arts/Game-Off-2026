extends Node
class_name EnemyHealthComponent

@export var max_health: float
var current_health: float
var invincibility_sources: Dictionary[StringName, bool] = {}
var body: Enemy

func setup(_enemy: Enemy) -> void: 
	body = _enemy


func take_damage(damage: float) -> void: 
	print(damage) 
	current_health = clampf(current_health - damage,0 , max_health)
	if(current_health <= 0):
		get_parent().die() #Does all the shindiggery it needs to in the 
		
	
