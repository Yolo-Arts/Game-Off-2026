extends Node

const ENEMY_REGISTRY: EnemyRegistry = preload("res://Resources/enemy_registry.tres")
var current_enemy_registry: EnemyRegistry = ENEMY_REGISTRY.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

func get_enemy_data(id: StringName) -> EnemyData:
	return current_enemy_registry.enemies.get(id, null)

func get_enemies_in_group(group: StringName) -> Array[EnemyData]:
	var enemies: Array[EnemyData] = []
	for key in current_enemy_registry.enemies.keys():
		if current_enemy_registry.enemies[key].enemy_group_id == group:
			enemies.append(current_enemy_registry.enemies[key])
	return enemies

func get_all_enemies() -> Array[EnemyData]:
	return current_enemy_registry.enemies.values()

func reset_enemies() -> void:
	current_enemy_registry = ENEMY_REGISTRY.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
