extends ActionItem
class_name SpawnRateActionItem

@export_enum("projectile_enemy", "gold_enemy")
var enemy_id: String
@export var spawn_rate_increase: float = 0.05

func _init(id: String = "", amount: float = 0.05) -> void:
	enemy_id = id
	spawn_rate_increase = amount

func execute() -> void:
	if enemy_id.is_empty():
		push_error("SpawnRateActionItem: enemy_id is not set.")
		return

	var enemy_data: EnemyData = EnemySources.get_enemy_data(StringName(enemy_id))
	if not enemy_data:
		push_error("SpawnRateActionItem: No enemy found with ID '%s'." % enemy_id)
		return

	enemy_data.spawn_weight += spawn_rate_increase
