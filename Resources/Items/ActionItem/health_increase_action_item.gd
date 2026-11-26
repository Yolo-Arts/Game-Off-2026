extends ActionItem
class_name HealthIncreaseActionItem

const ENEMY_IDS := ["projectile_enemy", "gold_enemy", "testenemy"]

@export_enum("projectile_enemy", "gold_enemy", "testenemy", "all")
var enemy_id: String
@export var increase_amount: int


func _init(id: String = "", amount: int = 1) -> void:
	enemy_id = id
	increase_amount = amount


func execute() -> void:
	if enemy_id.is_empty():
		push_error("HealthIncreaseAction: enemy_id is not set.")
		return

	if enemy_id == "all":
		for id in ENEMY_IDS:
			_apply_health_increase(id)
	else:
		_apply_health_increase(enemy_id)


func _apply_health_increase(target_id: String) -> void:
	var enemy_data: EnemyData = EnemySources.get_enemy_data(target_id)
	if not enemy_data:
		push_error("HealthIncreaseAction: No enemy found with ID '%s'." % target_id)
		return

	enemy_data.base_enemy_stats.max_health += increase_amount
