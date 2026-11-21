extends BulletProjectile

func break_projectile() -> void:
	player.energy_component.increase_energy(player.get_current_stats().energy_increase)
	# TODO make better projectile particles.
	ObjectPool.spawn(ObjectPool.bullet_impact_scene, global_position)
	queue_free()
