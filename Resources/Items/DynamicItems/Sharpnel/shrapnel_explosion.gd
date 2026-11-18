extends ItemEffect

@export var sharpnel_amount_range: Vector2i = Vector2i(8, 12)
@export var damage_multiplier: float = 0.5
@export var speed_range: Vector2 = Vector2(800, 1500)
@export var sharpnel_scene: PackedScene
func _initialize() -> void:
	EventSystem.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Node2D) -> void:
	var stats: PlayerStats = player.get_current_stats()
	var damage: float = stats.shot_damage * damage_multiplier
	var sharpnel_amount: int = randi_range(sharpnel_amount_range.x, sharpnel_amount_range.y)
	for i in range(sharpnel_amount):

		var sharpnel: Sharpnel = sharpnel_scene.instantiate() as Sharpnel
		if not sharpnel:
			push_error("INVALID SHARPNEL")
			return
		
		sharpnel.setup(damage, randf_range(speed_range.x, speed_range.y))
		sharpnel.global_position = enemy.global_position

		add_child(sharpnel)
