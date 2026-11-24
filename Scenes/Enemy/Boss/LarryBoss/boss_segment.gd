extends Segment

func take_damage(damage_source: DamageSource, propogating: bool = false) -> void:
	if not propogating:
		
		Juicee.flicker(self, 0.2, Color(1.0, 1.0, 1.0, 0.369), 0.2)
		Juicee.flash(self)
	if behind_segment:
		behind_segment.take_damage(damage_source, true)
		return
	health_component.take_damage(damage_source)
	EventSystem.enemy_hit.emit(self, damage_source)
	
	
	if damage_source.source_node:
		var knockback_amount: float = damage_source.knockback * enemy_stats.knockback_resistance
		movement_component.current_knockback = knockback_amount * damage_source.source_node.global_position.direction_to(global_position)



func die() -> void:
	if dead:
		return
	dead = true
	if ahead_segment:
		ahead_segment.behind_segment = null
	if behind_segment:
		behind_segment.ahead_segment = null
	segment_destroyed.emit()
	
	#var collectable := load("res://Game/Collectables/collectable.tscn")
	#var test = collectable.instantiate()
	#test.position = position
	#Juicee.preset_explosion(self)
	await get_tree().process_frame
	collision_layer = 0
	collision_mask = 0
	EventSystem.enemy_died.emit(self)
	ObjectPool.spawn(ObjectPool.explosion_scene, global_position)
	
	# TODO Add enemy death SFX
	Pickups.spawn(Enums.CurrencyType.GEAR, global_position, enemy_stats.drop)
	queue_free()
