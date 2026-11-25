class_name EnemySpawner extends Node2D

var player: Player

@export var auto_start: bool = true
@export var waves_elapsed: int = 0
@export var world_bounds: Rect2
@export var spawn_angle_increment: float = PI/16
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@export var enemy_spawn_timer: Timer

# TODO Add a wave and formation system
@export_group("Spawn Animation")
@export var spawn_animation_scene: PackedScene
@export var spawn_particles_scene: PackedScene

var pending_spawns: Array[Dictionary] = []
func _ready() -> void:
	enemy_spawn_timer.timeout.connect(spawn_next_formation)
	EventSystem.player_spawned.connect(initialize)
	EventSystem.request_spawn_enemy.connect(attempt_spawn_enemy)
	
func initialize(_player: Player) -> void:
	player = _player
	enemy_spawn_timer.wait_time = player.get_current_stats().time_per_wave
	if auto_start:
		enemy_spawn_timer.start()
	waves_elapsed = 0

func _process(delta: float) -> void:
	#Debugging purposes
	if(Input.is_key_pressed(KEY_M) and OS.is_debug_build()):
		enemy_spawn_timer.start()

## Returns a random [EnemyData] from weighted from [Array][[EnemyData]]
func pick_enemy(enemies: Array[EnemyData]) -> EnemyData:
	var weights: PackedFloat32Array = PackedFloat32Array()
	for enemy in enemies:
		if not enemy.unlocked:
			weights.append(0.0)
			continue
		weights.append(enemy.spawn_weight)
	var random_index: int = rng.rand_weighted(weights)
	return enemies[random_index]

func is_radius_empty(enemy_position: Vector2, radius: float) -> bool:
	for pending in pending_spawns:
		var min_dist: float = radius + pending["radius"]
		if enemy_position.distance_squared_to(pending["position"]) < min_dist * min_dist:
			return false

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0.0, enemy_position)
	var result: Array[Dictionary] = space_state.intersect_shape(query, 1)
	return result.is_empty()

func get_random_enemy() -> EnemyData:
	return pick_enemy(EnemySources.get_all_enemies())

func spawn_random_enemy() -> bool:
	var random_enemy: EnemyData = get_random_enemy()
	return attempt_spawn_enemy(random_enemy)

func create_formation(amount: int) -> Array[EnemyData]:
	var enemies: Array[EnemyData]
	for i in range(amount):
		enemies.append(get_random_enemy())
	return enemies

func spawn_next_formation() -> void:
	if player.is_dead:
		return
	var stats: PlayerStats = player.get_current_stats()
	var number_of_enemies: int = max(1 ,randi_range(stats.enemies_per_wave.x, stats.enemies_per_wave.y))
	var enemies_to_spawn = create_formation(number_of_enemies)
	var time_next_wave: float = player.get_current_stats().time_per_wave
	for enemy in enemies_to_spawn:
		attempt_spawn_enemy(enemy)
		time_next_wave += enemy.difficulty_time_increase
	
	enemy_spawn_timer.start(time_next_wave)
	waves_elapsed += 1

func attempt_spawn_enemy(enemy: EnemyData, origin_node: Node2D = player) -> bool:
	var initial_spawn_angle: float = spawn_angle_increment * randi_range(0, int(2 * PI / spawn_angle_increment))
	var spawn_angle = initial_spawn_angle
	if origin_node == null:
		return false
	var origin_pos: Vector2 = origin_node.global_position
	while spawn_angle < 2 * PI + initial_spawn_angle:
		var spawn_pos = origin_pos + enemy.spawn_distance_from_player * Vector2(sin(spawn_angle), cos(spawn_angle))
		if is_radius_empty(spawn_pos, enemy.enemy_size):
			start_spawn_sequence(enemy, spawn_pos)
			return true
		spawn_angle += spawn_angle_increment

	return false

# Spawn animation stuff starts below:
func start_spawn_sequence(enemy_data: EnemyData, spawn_pos: Vector2) -> void:
	var chosen_color: DamageSource.ShiftColor = enemy_data.base_enemy_stats.shift_color
	if enemy_data.enemy_type == EnemyData.EnemyType.COLOR:
		chosen_color = [DamageSource.ShiftColor.RED, DamageSource.ShiftColor.BLUE].pick_random()
	else:
		chosen_color = DamageSource.ShiftColor.NONE
	if spawn_animation_scene == null or enemy_data.spawn_animation_data == null:
		finalize_spawn_enemy(enemy_data, spawn_pos, 0.0, chosen_color)
		return

	var reservation := { "position": spawn_pos, "radius": enemy_data.enemy_size }
	pending_spawns.append(reservation)

	var anim := spawn_animation_scene.instantiate() as EnemySpawnAnimation
	add_child(anim)
	anim.global_position = spawn_pos

	var spawn_color: Color
	match chosen_color:
		DamageSource.ShiftColor.BLUE:
			spawn_color = MyColors.ENEMY_BLUE
		DamageSource.ShiftColor.RED:
			spawn_color = MyColors.RED
		_:
			spawn_color = Color.WHITE 

	anim.animate(enemy_data.spawn_animation_data, 1.0, spawn_color)

	if anim.particles:
		anim.particles.reparent(self)
		anim.particles.finished.connect(anim.particles.queue_free)

	anim.finished.connect(func():
		pending_spawns.erase(reservation)
		anim.queue_free()
		finalize_spawn_enemy(enemy_data, spawn_pos, anim.spawn_angle if anim.rotate_spawn else 0.0, chosen_color)
	)

func finalize_spawn_enemy(enemy_data: EnemyData, enemy_position: Vector2, initial_rotation: float = 0.0, override_color: Variant = null) -> void:
	var enemy_scene_to_spawn: Node2D = enemy_data.enemy_scene.instantiate()
	enemy_scene_to_spawn.global_position = enemy_position
	if initial_rotation != 0.0:
		enemy_scene_to_spawn.rotation = initial_rotation

	if enemy_data.is_enemy:
		var enemy = enemy_scene_to_spawn as Enemy
		if enemy == null and not "enemy_stats" in enemy_scene_to_spawn:
			push_error("Enemy stated as enemy, but is not -> ", enemy_data.enemy_id, " ", enemy_data.enemy_name)
		else:
			enemy = enemy_scene_to_spawn
		enemy.enemy_stats = enemy_data.base_enemy_stats.duplicate()
		if override_color != null:
			enemy.enemy_stats.shift_color = override_color
		elif enemy_data.enemy_type == EnemyData.EnemyType.COLOR:
			enemy.enemy_stats.shift_color = [DamageSource.ShiftColor.RED, DamageSource.ShiftColor.BLUE].pick_random()

		add_child(enemy)
	else:
		add_child(enemy_scene_to_spawn)

	if spawn_particles_scene:
		var particles := spawn_particles_scene.instantiate() as CPUParticles2D
		add_child(particles)
		particles.z_index = 4096
		particles.global_position = enemy_position
		particles.emitting = true
		particles.finished.connect(particles.queue_free)
