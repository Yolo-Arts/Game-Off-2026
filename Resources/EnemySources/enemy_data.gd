class_name EnemyData extends Resource

@export var enemy_id: StringName
@export var enemy_name: String
@export var enemy_scene: PackedScene
@export var base_enemy_stats: EnemyStats = EnemyStats.new()
@export var spawn_weight: float = 1.0
@export var is_enemy: bool = true

enum EnemyType {COLOR, NONE}
@export var enemy_type: EnemyType
