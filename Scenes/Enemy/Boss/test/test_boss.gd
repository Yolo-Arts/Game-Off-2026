extends ProjectileEnemy

func die() -> void:
	Globals.beat_boss = true
	SkillTreeUpgrades.complete_active_scene_item()
	#EventSystem.STA_change_stage.emit(StageConfig.Keys.UpgradeView)
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.GameOverScreen)
	
	for entry in ring_projectiles:
		var proj = entry["projectile"]
		if is_instance_valid(proj):
			proj.queue_free()
	ring_projectiles.clear()
	
	super.die()
