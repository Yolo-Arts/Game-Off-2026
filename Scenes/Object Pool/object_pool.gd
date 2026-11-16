extends Node2D

@export var explosion_scene: PackedScene = preload("uid://c1tcihsglvw81")
@export var explosion_amount: int = 100

var explosions_index: int = 0
var explosions: Array = []

func _ready() -> void:
	create_explosions()

func create_explosions() -> void:
	for i in explosion_amount:
		var explosion_inst = explosion_scene.instantiate()
		add_child(explosion_inst)
		explosion_inst.deactivate()
		explosions.append(explosion_inst)

func spawn_explosion(pos: Vector2) -> void:
	if explosions.is_empty():
		return

	var current_explosion = explosions[explosions_index]
	current_explosion.global_position = pos
	current_explosion.activate()


	explosions_index += 1
	if explosions_index >= explosion_amount:
		explosions_index = 0

func deactivate_all() -> void:
	explosions_index = 0
	for explosion_inst in explosions:
		explosion_inst.deactivate()
