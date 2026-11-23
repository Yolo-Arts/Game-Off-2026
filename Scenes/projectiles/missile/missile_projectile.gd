class_name MissileProjectile extends BulletProjectile

var explosion_radius: float = 180.0
var explosion_knockback: float = 400.0

var has_exploded: bool = false

func _apply_stats() -> void:
	super()
	explosion_radius = projectile_stats.explosion_radius
	explosion_knockback = projectile_stats.explosion_knockback

func _on_area_entered(area: Area2D) -> void:
	if projectile_stats == null or has_exploded:
		push_warning("No projectile stats...")
		return

	if area is BulletProjectile:
		var other_bullet: BulletProjectile = area as BulletProjectile
		if other_bullet.projectile_stats != null and other_bullet.projectile_stats.enemy:
			explode()

func _on_body_entered(body: Node2D) -> void:
	if projectile_stats == null or has_exploded:
		return
	
	if body.is_in_group("player"):
		return
	
	explode()

func explode() -> void:
	if has_exploded:
		return
	has_exploded = true

	ObjectPool.spawn(ObjectPool.MISSILE_EXPLOSION, global_position)
	TweenManager.camera.shake(0.5, 30.5, 30)
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.MissileExplosion)

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = explosion_radius

	query.shape = circle
	query.transform = Transform2D(0.0, global_position)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	# using bitwise operators :eyes: for layer 3 (enemies) and layer 4 (projectiles)
	query.collision_mask = (1 << 2) | (1 << 3)

	var hits: Array[Dictionary] = space_state.intersect_shape(query, 64)

	for hit: Dictionary in hits:
		var collider: Object = hit["collider"]

		if collider.has_method("take_damage"):
			var dmg: float = projectile_stats.damage
			var damage_source: DamageSource = DamageSource.new(
				dmg,
				explosion_knockback,
				DamageSource.DamageSourceType.PLAYER_PROJECTILE,
				DamageSource.ShiftColor.NONE,
				self
			)
			collider.take_damage(damage_source)
			
		elif collider is BulletProjectile and collider != self:
			var other_bullet: BulletProjectile = collider as BulletProjectile
			if other_bullet.projectile_stats != null and other_bullet.projectile_stats.enemy:
				other_bullet.break_projectile()
	
	# SFX add rocket SFX
	queue_free()
