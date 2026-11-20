extends Node
class_name EnemyHealthComponent

@export var max_health: float
@onready var damage_numbers : damage_number_manager  
var current_health: float
var enemy: Enemy

func _ready() -> void:
	damage_numbers = get_tree().get_first_node_in_group("damage_number") # Reference this however you feel is best, the system works though I know there is probably a better way to call/access this method/script

func setup(_enemy: Enemy) -> void: 

	enemy = _enemy
	max_health = enemy.enemy_stats.max_health
	current_health = enemy.enemy_stats.max_health


func take_damage(source: DamageSource) -> void: 
	if source.shift_color != enemy.enemy_stats.shift_color and source.shift_color != DamageSource.ShiftColor.NONE:
		return
	# Increasing player energy from the enemy script lol....
	# TODO probably refactor this into the energy component but we ball.
	if (source.damage_type == DamageSource.DamageSourceType.PLAYER):
		EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.PlayerRam)
		
		Juicee.impact_ring(enemy)
		var player: Player = source.source_node 
		var player_stats: PlayerStats = player.get_current_stats()
		player.energy_component.increase_energy(player_stats.energy_increase)
	
	ObjectPool.spawn(ObjectPool.bullet_impact_scene, enemy.global_position)

	current_health = clampf(current_health - source.damage,0 , enemy.enemy_stats.max_health)
	damage_numbers.display_val(source.damage, enemy.global_position)
	if(current_health <= 0):
		enemy.die() #Does all the shindiggery it needs to in the 
		
	
