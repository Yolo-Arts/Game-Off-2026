class_name GoldEnemyAction extends ActionItem

func execute() -> void:
	var gold_enemy: EnemyData = EnemySources.get_enemy_data("gold_enemy")
	if not gold_enemy:
		push_error("No gold_enemy")
		return
	gold_enemy.unlocked = true
	
