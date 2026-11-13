extends Node
class_name EnemyHealthComponent

var current_health: float
var enemy: Enemy

func setup(_enemy: Enemy) -> void: 

	enemy = _enemy
	current_health = enemy.enemy_stats.max_health


func take_damage(source: DamageSource) -> void: 
	if source.shift_color != enemy.enemy_stats.shift_color:
		return
	current_health = clampf(current_health - source.damage,0 , enemy.enemy_stats.max_health)

	if(current_health <= 0):
		get_parent().die() #Does all the shindiggery it needs to in the 
		
	
