class_name PlayerShootComponent extends Node

@export var bullet_scene: PackedScene
@export var missile_scene: PackedScene
@export var enabled: bool =  true
@onready var turret_positions = %TurretPositions
var turrets
var player: Player
@onready var missile_component: MissileComponent = %MissileComponent

var shoot_cooldown: float = 0.0
var unlocked_turrets: int = 1
@export var spread_angle_degrees: float = 15.0

var stats: PlayerStats
func setup(_player: Player) -> void:
	player = _player
	turrets = turret_positions.get_children() 
	check_stats()

func check_stats() -> void:
	stats = player.get_current_stats() 
	unlocked_turrets = min(stats.unlocked_turrets, 3)

func _process(delta: float) -> void:
	shoot_cooldown -= delta
	
func _physics_process(delta: float) -> void:
	if not player or not enabled:
		return
	if Input.is_action_pressed("shoot") and player.can_shoot and shoot_cooldown <= 0.0:
		shoot(bullet_scene)
	
	if Input.is_action_just_pressed("shoot_missile") and stats.unlocked_missiles and missile_component.can_fire_missiles():
		shoot_missile(missile_scene)
		print("Missile Component remaining rockets: ", missile_component.missile_count)
	
	if OS.is_debug_build() and Input.is_key_pressed(KEY_E):
		player.energy_component.increase_energy(100.0)

func shoot(scene: PackedScene) -> void:
	if player.energy_component.current_energy < player.get_current_stats().shot_cost:
		return
	
	player.energy_component.reduce_energy(player.get_current_stats().shot_cost)
	
	var forward_dir := -player.transform.y.normalized()
	var spread_rad := deg_to_rad(spread_angle_degrees)
	
	for i in range(unlocked_turrets):
		var bullet: BulletProjectile = scene.instantiate() as BulletProjectile
		if bullet:
			EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.PlayerShoot)
			
			var shot_dir := forward_dir
			match i:
				1:
					shot_dir = forward_dir.rotated(-spread_rad) 
				2:
					shot_dir = forward_dir.rotated(spread_rad) 
			
			bullet.projectile_stats = make_projectile_data(player.get_current_stats(), shot_dir)
			bullet.global_position = turrets[i].global_position
			get_tree().current_scene.add_child(bullet)
			
	shoot_cooldown = 1.0 / player.get_current_stats().shots_per_second
	player.movement_component.current_knockback += player.get_current_stats().recoil * player.transform.y

func shoot_missile(scene: PackedScene) -> void:
	if scene == null:
		push_warning("Missile scene is not assigned on PlayerShootComponent.")
		return

	var missile := scene.instantiate() as MissileProjectile
	if missile == null:
		return

	missile_component.consume_missile()
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.PlayerShoot)

	var current_stats := player.get_current_stats()
	var forward_dir := -player.transform.y.normalized()
	var data := make_projectile_data(current_stats, forward_dir)
	data.explosion_radius = stats.missile_explosion_radius
	data.explosion_knockback = stats.missile_explosion_knockback
	data.damage = stats.missile_damage
	data.speed = stats.missile_speed
	data.shift_color = DamageSource.ShiftColor.NONE
	
	missile.global_position = turrets[0].global_position if turrets.size() > 0 else player.global_position
	missile.setup(data)
	get_tree().current_scene.add_child(missile)

	player.movement_component.current_knockback += current_stats.recoil * player.transform.y

func make_projectile_data(stats: PlayerStats, direction: Vector2) -> ProjectileData:
	var projectile_data := ProjectileData.new()
	projectile_data.damage = stats.get_computed_damage(true)
	projectile_data.direction = direction
	projectile_data.knockback = stats.shot_knockback
	projectile_data.range_pixels = stats.shot_range
	projectile_data.scale = stats.shot_scale
	projectile_data.speed = stats.shot_speed
	projectile_data.shift_color = player.shift_color
	return projectile_data
