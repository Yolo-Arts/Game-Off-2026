class_name PlayerShootComponent extends Node

@export var bullet_scene: PackedScene
@export var enabled: bool =  true
var player: Player

func setup(_player: Player) -> void:
	player = _player
	
	
func _unhandled_input(event: InputEvent) -> void:
	if not player or not enabled:
		return
	if event.is_action_pressed("shoot") and player.can_shoot:
		shoot(bullet_scene)
		
func shoot(scene: PackedScene) -> void:
	if player.energy_component.current_energy < player.get_current_stats().shot_cost:
		return
	var bullet: BulletProjectile = scene.instantiate() as BulletProjectile
	if bullet:
		bullet.projectile_stats = make_projectile_data(player.get_current_stats(), -player.transform.y)
		bullet.global_position = player.global_position + 32 * -player.transform.y
		get_tree().current_scene.add_child(bullet)
		player.energy_component.reduce_energy(player.get_current_stats().shot_cost)

		

func make_projectile_data(stats: PlayerStats, direction: Vector2) -> ProjectileData:
	var projectile_data := ProjectileData.new()
	projectile_data.damage = stats.shot_damage
	projectile_data.direction = direction
	projectile_data.knockback = stats.shot_knockback
	projectile_data.range_pixels = stats.shot_range
	projectile_data.scale = stats.shot_scale
	projectile_data.speed = stats.shot_speed
	return projectile_data
