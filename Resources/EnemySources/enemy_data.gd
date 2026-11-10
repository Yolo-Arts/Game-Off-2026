class_name EnemyData extends Resource

@export var enemy_id: StringName
@export var enemy_name: String
@export var enemy_scene: PackedScene
@export var base_enemy_stats: EnemyStats = EnemyStats.new()
@export var spawn_distance_from_player: float = 100.0:
	set(value):
		spawn_distance_from_player = max(0.0, value)
@export var enemy_size: float = 64.0:
	set(value):
		enemy_size = max(0.0, value)
@export var spawn_weight: float = 1.0:
	set(value):
		spawn_weight = max(0.0, value)
		
@export var is_enemy: bool = true

enum EnemyType {COLOR, NONE}
@export var enemy_type: EnemyType
