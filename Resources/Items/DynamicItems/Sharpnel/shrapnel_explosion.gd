extends ItemEffect

#@export var shrapnel_amount_range: Vector2i = Vector2i(8, 12)
@export var damage_multiplier: float = 0.5
@export var speed_range: Vector2 = Vector2(800, 1500)
@export var shrapnel_scene: PackedScene

func _initialize() -> void:
	EventSystem.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Node2D) -> void:
	var stats: PlayerStats = player.get_current_stats()
	var damage: float = stats.shot_damage * damage_multiplier
	#var shrapnel_amount: int = randi_range(shrapnel_amount_range.x, shrapnel_amount_range.y)
	var shrapnel_amount = stats.shrapnel_count
	for i in range(shrapnel_amount):
		var shrapnel_instance: shrapnel = shrapnel_scene.instantiate() as shrapnel
		if not shrapnel:
			push_error("INVALID shrapnel")
			return
		
		shrapnel_instance.setup(damage, randf_range(speed_range.x, speed_range.y))
		shrapnel_instance.global_position = enemy.global_position

		add_child(shrapnel_instance)
