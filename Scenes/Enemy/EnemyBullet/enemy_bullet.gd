extends BulletProjectile

func break_projectile(same_color: bool = true) -> void:
	if same_color:
		player.energy_component.increase_energy(player.get_current_stats().ram_bullet_energy_increase)
	
	# TODO make better projectile particles.
	ObjectPool.spawn(ObjectPool.bullet_impact_scene, global_position)
	queue_free()
