extends Node2D

@export var explosion_scene: PackedScene = preload("uid://c1tcihsglvw81")
@export var bullet_impact_scene: PackedScene = preload("res://Scenes/Particles/BulletImpact/bullet_impact_particle.tscn")
const MISSILE_EXPLOSION = preload("uid://cjuy8dsb7jdw3")

@export var explosion_amount: int = 15
@export var bullet_impact_amount: int = 50

# Dictionary[Array, int]
var pools: Dictionary = {}

func _ready() -> void:
	add_to_group("object_pool")
	z_index = 100
	create_pool(explosion_scene, explosion_amount)
	create_pool(MISSILE_EXPLOSION, 10)
	create_pool(bullet_impact_scene, bullet_impact_amount)

func create_pool(scene: PackedScene, amount: int) -> void:
	if scene == null or amount <= 0:
		return

	var items: Array = []
	for i in amount:
		var instance := scene.instantiate()
		add_child(instance)
		instance.deactivate()
		items.append(instance)

	pools[scene] = {
		"items": items,
		"index": 0,
	}

func spawn(scene: PackedScene, pos: Vector2, default_amount: int = 15) -> Node2D:
	if scene == null:
		return null
	
	if not pools.has(scene):
		create_pool(scene, default_amount)
	
	var pool: Dictionary = pools[scene]
	var items: Array = pool["items"]
	if items.is_empty():
		return null
	
	var index: int = pool["index"]
	var instance: Node2D = items[index]
	instance.global_position = pos
	instance.activate()
	
	pool["index"] = (index + 1) % items.size()
	return instance
	
func deactivate_all() -> void:
	for pool in pools.values():
		pool["index"] = 0
		for instance in pool["items"]:
			instance.deactivate()
