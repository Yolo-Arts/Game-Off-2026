extends ActionItem
class_name HealthIncreaseActionItem

@export_enum("projectile_enemy", "gold_enemy")
var enemy_id: String
@export var increase_amount: int

func _init(id: String = "", amount: int = 1) -> void:
	enemy_id = id
	increase_amount += amount


func execute() -> void:
	if enemy_id.is_empty():
		push_error("HealthIncreaseAction: enemy_id is not set.")
		return

	var enemy_data: EnemyData = EnemySources.get_enemy_data(enemy_id)
	if not enemy_data:
		push_error("HealthIncreaseAction: No enemy found with ID '%s'." % enemy_id)
		return

	enemy_data.base_enemy_stats.max_health += increase_amount
