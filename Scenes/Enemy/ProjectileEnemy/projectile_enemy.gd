class_name ProjectileEnemy extends Enemy

@export var projectile_scene: PackedScene
@export var fire_interval: float = 2.0
@export var projectile_speed: float = 250.0
@export var projectile_count: int = 8
@export var projectile_data: ProjectileData

@onready var shoot_timer: Timer = $ShootTimer

var angle_between_shots: float = 45.0

func _ready() -> void:
	super._ready()
	
	angle_between_shots = 360.0 / projectile_count
	
	shoot_timer.wait_time = fire_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _on_shoot_timer_timeout() -> void:
	shoot_radial()

func shoot_radial() -> void:
	if projectile_scene == null or projectile_data == null:
		return

	for i in range(projectile_count):
		var angle_rad := deg_to_rad(i * angle_between_shots)
		var direction := Vector2.from_angle(angle_rad)
		
		var projectile := projectile_scene.instantiate() as BulletProjectile
		var data := projectile_data.duplicate() as ProjectileData
		
		data.enemy = true
		data.direction = direction
		data.shift_color = enemy_stats.shift_color
		
		# damage and knockback is handled from the EnemyStats. 
		# IT IS NOT HANDLED FROM ProjectileData
		data.damage = enemy_stats.damage
		data.knockback = enemy_stats.knockback
		
		projectile.global_position = global_position
		projectile.setup(data)
		get_tree().current_scene.add_child(projectile)
