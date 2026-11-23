class_name PlayerShootComponent extends Node

@export var bullet_scene: PackedScene
@export var enabled: bool =  true
@onready var turret_positions = %TurretPositions
var turrets
var player: Player
var shoot_cooldown: float = 0.0
var unlocked_turrets: int = 1
@export var spread_angle_degrees: float = 15.0

var stats
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
