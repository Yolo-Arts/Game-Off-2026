class_name StageInfo extends Resource

@export var stage_id: StringName
@export var stage_name: String
@export var formations: Array[Formation] = [] 
@export var current_wave: int = 1 # Might add this into the spawner
@export var stage_boss: Variant
@export var spawn_interval: float = 2.0
