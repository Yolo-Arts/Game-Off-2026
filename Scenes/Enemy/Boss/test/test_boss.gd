extends ProjectileEnemy

func die() -> void:
	Globals.beat_boss = true
	SkillTreeUpgrades.complete_active_scene_item()
	#EventSystem.STA_change_stage.emit(StageConfig.Keys.UpgradeView)
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.GameOverScreen, "boss_fight")
	
	Currencies.cheat_add_specific_currency(Enums.CurrencyType.HEART, 1)
	Currencies.cheat_add_specific_currency(Enums.CurrencyType.STAR, 5)
	Currencies.cheat_add_specific_currency(Enums.CurrencyType.GEAR, 25)
	
	for entry in ring_projectiles:
		var proj = entry["projectile"]
		if is_instance_valid(proj):
			proj.queue_free()
	ring_projectiles.clear()
	
	super.die()

func take_damage(damage_source: DamageSource, propogating: bool = false) -> void:
	super(damage_source)
	EventSystem.update_boss_healthbar_component.emit()
