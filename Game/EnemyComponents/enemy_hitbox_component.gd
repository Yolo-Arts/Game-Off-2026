class_name EnemyHitbox extends Area2D

@export var enabled: bool = false
@export var enemy: Node2D
@export var enemy_stats: EnemyStats

func _init() -> void:
	collision_mask = 2
	add_to_group("enemy_hitbox")
	EventSystem.player_vincible.connect(apply_hit)
	area_entered.connect(apply_hit.unbind(1))
	
func setup(_enemy: Node2D, _enemy_stats: EnemyStats, _enabled: bool = true) -> void:
	enabled = _enabled
	enemy = _enemy
	enemy_stats = _enemy_stats
	
	assert(enemy_stats != null, "NULL ENEMY STATS")
	
func apply_hit() -> void:
	if not enabled: return
	if enemy_stats == null:
		push_error("NULL ENEMY STATS")
		return
	var areas: Array[Area2D] = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("player_hurtbox"):
			var damage_source := DamageSource.new(enemy_stats.damage, enemy_stats.knockback, enemy_stats.enemy_damage_type, enemy_stats.shift_color, enemy)
			EventSystem.player_hit.emit(damage_source)
			return
	
