extends ProjectileEnemy

func die() -> void:
	SkillTreeUpgrades.complete_active_scene_item()
	EventSystem.STA_change_stage.emit(StageConfig.Keys.UpgradeView)
	
	for entry in ring_projectiles:
		var proj = entry["projectile"]
		if is_instance_valid(proj):
			proj.queue_free()
	ring_projectiles.clear()
	
	super.die()
