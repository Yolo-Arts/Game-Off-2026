extends Node

const ENEMY_REGISTRY: EnemyRegistry = preload("res:///Resources/enemy_registry.tres")

func get_enemy_data(id: StringName) -> EnemyData:
	return ENEMY_REGISTRY.enemies.get(id, null)
	
func get_enemies_in_group(group: StringName) -> Array[EnemyData]:
	var enemies: Array[EnemyData] = []
	for key in ENEMY_REGISTRY.enemies.keys():
		if ENEMY_REGISTRY.enemies[key].enemy_group_id == group:
			enemies.append(ENEMY_REGISTRY.enemies[key])
	return enemies

func get_all_enemies() -> Array[EnemyData]:
	return ENEMY_REGISTRY.enemies.values()
