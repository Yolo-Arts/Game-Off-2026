class_name BulletProjectile extends Area2D

@export var projectile_stats: ProjectileData



func _ready() -> void:
	if projectile_stats == null:
		return
	global_rotation = projectile_stats.direction.angle()
	var wait: float = projectile_stats.life_time_seconds if !projectile_stats.use_range else projectile_stats.convert_range_to_life_time()
	await get_tree().create_timer(wait).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if projectile_stats == null:
		return
	global_position += projectile_stats.direction * projectile_stats.speed * delta
	
	






func _on_body_entered(body: Node2D) -> void:
	var damage: DamageSource = DamageSource.new(projectile_stats.damage, projectile_stats.knockback,
			 DamageSource.DamageSourceType.PROJECTILE, DamageSource.ShiftColor.NONE, self)
	if projectile_stats.enemy:
		if body.is_in_group("player"):
			EventSystem.player_hit.emit(damage)
	elif body.has_method("take_damage"):
		body.take_damage(damage)
