extends ActionItem
class_name EnemyDropActionItem

@export_enum("projectile_enemy", "gold_enemy", "segment")
var enemy_id: String
@export var drop_increase: int = 1

func _init(id: String = "", amount: int = 1) -> void:
	enemy_id = id
	drop_increase = amount

func execute() -> void:
	if enemy_id.is_empty():
		push_error("EnemyDropActionItem: enemy_id is not set.")
		return

	var enemy_data: EnemyData = EnemySources.get_enemy_data(StringName(enemy_id))
	if not enemy_data:
		push_error("EnemyDropActionItem: No enemy found with ID '%s'." % enemy_id)
		return

	if not enemy_data.base_enemy_stats:
		push_error("EnemyDropActionItem: Enemy '%s' has no base_enemy_stats assigned." % enemy_id)
		return

	enemy_data.base_enemy_stats.drop = max(0, enemy_data.base_enemy_stats.drop + drop_increase)
