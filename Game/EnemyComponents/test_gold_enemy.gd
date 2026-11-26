extends Enemy

func _ready() -> void:
	super._ready()
	#$Node2D.modulate = Color.GOLD
	#enemy_stats.shift_color = DamageSource.ShiftColor.GOLD

func die() -> void:
	if dead:
		return
	dead = true

	await get_tree().process_frame
	collision_layer = 0
	collision_mask = 0
	EventSystem.enemy_died.emit(self)
	ObjectPool.spawn(ObjectPool.explosion_scene, global_position)
	
	# TODO Add enemy death SFX
	Pickups.spawn(Enums.CurrencyType.STAR, global_position, enemy_stats.drop)
	queue_free()
