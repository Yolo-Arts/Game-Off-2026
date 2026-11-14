extends ItemEffect

@export var base_chance: float = 1.0/5.0
@export var additive_per_luck: float = 1.0/10.0
@export var fireball_scene: PackedScene
func setup(_player: Player) -> void:
	super.setup(_player)
	EventSystem.enemy_hit.connect(_on_enemy_hit)

func _on_enemy_hit(enemy: Node2D, source: DamageSource) -> void:
	if source.damage_type != DamageSource.DamageSourceType.PROJECTILE:
		return
	if enemy == null or not enemy.has_method("take_damage"):
		return
	var calculated_chance: float = clamp(additive_per_luck * player.get_current_stats().luck + base_chance, 0.0, 1.0)
	var chance: float = randf()
	if chance < calculated_chance:
		var fire_ball: ColorRect = fireball_scene.instantiate()
		fire_ball.global_position = enemy.global_position
		add_child(fire_ball)
		enemy.take_damage(DamageSource.new(500, 0.0, DamageSource.DamageSourceType.OTHER, DamageSource.ShiftColor.NONE))
		await get_tree().create_timer(4.0).timeout
		fire_ball.queue_free()
