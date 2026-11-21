extends BulletProjectile

func break_projectile(same_color: bool = true) -> void:
	if same_color:
		var stats = player.get_current_stats()
		player.energy_component.increase_energy(stats.ram_bullet_energy_increase)
		player.health_component.heal(stats.ram_bullet_fuel_increase)
	
	# TODO make better projectile particles.
	ObjectPool.spawn(ObjectPool.bullet_impact_scene, global_position)
	queue_free()
