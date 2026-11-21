extends ActionItem
class_name ProjectileEnemyAction

func execute() -> void:
	var projectile_enemy: EnemyData = EnemySources.get_enemy_data("projectile_enemy")
	if not projectile_enemy:
		push_error("No projectile_enemy")
		return
	projectile_enemy.unlocked = true
