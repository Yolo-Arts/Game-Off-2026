class_name ExplosionComponent extends Area2D

@export var radius_size : float
@export var explosion_damage : float
var body: Enemy

func _enter_tree() -> void:
	scale = Vector2(radius_size,radius_size)

# Cannot test/fix due to enemy collision issue 
func explode() -> void: 
	for target : Node2D in get_overlapping_bodies():
		if(target.is_in_group("Enemies")):
			var enemy = target as Enemy 
			enemy.health_component.take_damage(explosion_damage) #probably will be changed to enemies with the same colour
		else: if(target.is_in_group("Player")): 
			var player = target as Player
			if(body.enemy_stats.shift_color == player.shift_color): 
				# var damage_source := DamageSource.new(explosion_damage, body.enemy_stats.enemy_damage_type, body.enemy_stats.shift_color, body)
				EventSystem.player_hit.emit(damage_source)
				
		
			

func _exit_tree() -> void:
	explode()
	
