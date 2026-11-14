extends Node
class_name EnemyHealthComponent

@export var max_health: float
@onready var damage_numbers : damage_number_manager  
var current_health: float
var invincibility_sources: Dictionary[StringName, bool] = {}
var body: Enemy

func _ready() -> void:
	damage_numbers = get_tree().get_first_node_in_group("damage_number") # Reference this however you feel is best, the system works though I know there is probably a better way to call/access this method/script

func setup(_enemy: Enemy) -> void: 
	body = _enemy
	max_health = body.enemy_stats.enemy_health
	current_health = max_health
	

func take_damage(damage: float) -> void: 
	current_health = clampf(current_health - damage, 0 , max_health)
	damage_numbers.display_val(damage, body.global_position)
	if(current_health <= 0):
		get_parent().queue_free() 
	
