class_name EnemySpawner extends Node2D

@export var stage_data: StageInfo
@export var world_bounds: Rect2
@export var spawn_angle_increment: float = PI/16
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@export var enemy_spawn_timer: Timer

# TODO Add a wave and formation system

func _ready() -> void:
	enemy_spawn_timer.wait_time = stage_data.spawn_interval
	enemy_spawn_timer.timeout.connect(spawn_next_formation)
	#enemy_spawn_timer.start()
	
	
func _process(delta: float) -> void:
	#Debugging purposes
	if(Input.is_key_pressed(KEY_M)): 
		enemy_spawn_timer.start()
	
## Returns a random [EnemyData] from weighted from [Array][[EnemyData]]
func pick_enemy(enemies: Array[EnemyData]) -> EnemyData:
	var weights: PackedFloat32Array = PackedFloat32Array()
	
	for enemy in enemies:
		weights.append(enemy.spawn_weight)
	
	var random_index: int = rng.rand_weighted(weights)
	return enemies[random_index]

func is_radius_empty(enemy_position: Vector2, radius: float) -> bool:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0.0, enemy_position)
	var result: Array[Dictionary] = space_state.intersect_shape(query, 1)
	return result.is_empty()

func spawn_random_enemy() -> bool:
	var random_enemy: EnemyData = pick_enemy(stage_data.enemies)
	return attempt_spawn_enemy(random_enemy)
	
	
func spawn_next_formation() -> void: 
	if(stage_data.current_wave - 1 >= stage_data.formations.size()):
		return 
	var form = stage_data.formations[stage_data.current_wave - 1]
	for num in form.count: 
		attempt_spawn_enemy(form.enemy)
	stage_data.current_wave += 1
	
	
func attempt_spawn_enemy(enemy: EnemyData) -> bool:
	var initial_spawn_angle: float = spawn_angle_increment * randi_range(0, int(2 * PI / spawn_angle_increment))
	var spawn_angle = initial_spawn_angle
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return false
	var player_pos: Vector2 = player.global_position
	while spawn_angle < 2 * PI + initial_spawn_angle:
		var spawn_pos = player_pos + enemy.spawn_distance_from_player * Vector2(sin(spawn_angle), cos(spawn_angle))
		if is_radius_empty(spawn_pos, enemy.enemy_size):
			spawn_enemy(enemy, spawn_pos)
			return true
		spawn_angle += spawn_angle_increment
	
	return false
	

func spawn_enemy(enemy_data: EnemyData, enemy_position: Vector2) -> void:
	var enemy: Node2D = enemy_data.enemy_scene.instantiate()
	
	
	print(" ")
	print(enemy_data.enemy_name)
	print(enemy_data.base_enemy_stats.is_asteroid)
	
	
	enemy.global_position = enemy_position
	if enemy_data.is_enemy:
		enemy = enemy as Enemy
		if enemy == null:
			push_error("Enemy stated as enemy, but is not -> ", enemy_data.enemy_id, " ", enemy_data.enemy_name)
			return
		enemy.enemy_stats = enemy_data.base_enemy_stats.duplicate()
		if enemy_data.enemy_type == EnemyData.EnemyType.COLOR:
			enemy.enemy_stats.shift_color = [DamageSource.ShiftColor.RED, DamageSource.ShiftColor.BLUE].pick_random()
			
	
	add_child(enemy)
	
