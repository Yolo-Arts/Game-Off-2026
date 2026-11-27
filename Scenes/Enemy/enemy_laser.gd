extends Area2D

@export var laser_size: float = 32.0
var current_speed: float
var move_dir: Vector2
var damage_source: DamageSource
var enemy_stats: EnemyStats
@onready var line_2d: Line2D = $Line2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func update_dimension_speed(color: DamageSource.ShiftColor) -> void:
	if color == enemy_stats.shift_color or color == DamageSource.ShiftColor.NONE:
		current_speed = enemy_stats.speed
	else:
		current_speed = enemy_stats.opposite_speed

func _ready() -> void:
	line_2d.width = laser_size
	

	if collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size.y = laser_size

	var player: Player = get_tree().get_first_node_in_group(&"player") as Player
	if not player:
		queue_free()
		return
	if enemy_stats.shift_color == DamageSource.ShiftColor.BLUE:
		line_2d.default_color = Color.BLUE
	elif enemy_stats.shift_color == DamageSource.ShiftColor.RED:
		line_2d.default_color = Color.RED

	damage_source = DamageSource.new(enemy_stats.damage, 0, DamageSource.DamageSourceType.ENEMY, enemy_stats.shift_color, self)


	move_dir = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP].pick_random()

	global_position = player.global_position - move_dir * 2000.0


	rotation = move_dir.angle() + PI / 2.0
	update_dimension_speed(player.shift_color)
	EventSystem.player_shifted.connect(update_dimension_speed)

func _physics_process(delta: float) -> void:
	global_position += move_dir * current_speed * delta



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(&"player_hurtbox"):
		EventSystem.player_hit.emit(damage_source)
