extends ActionItem
class_name HealthIncreaseActionItem

@export var enemy_id: StringName
@export var increase_amount: int

func _init(id: StringName = &"", amount: int = 1) -> void:
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
