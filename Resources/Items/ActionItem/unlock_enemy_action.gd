extends ActionItem
class_name UnlockEnemyAction

@export var enemy_id: StringName

func _init(id: StringName = &"") -> void:
	enemy_id = id

func execute() -> void:
	if enemy_id.is_empty():
		push_error("UnlockEnemyAction: enemy_id is not set.")
		return

	var enemy_data: EnemyData = EnemySources.get_enemy_data(enemy_id)
	if not enemy_data:
		push_error("UnlockEnemyAction: No enemy found with ID '%s'." % enemy_id)
		return

	enemy_data.unlocked = true
