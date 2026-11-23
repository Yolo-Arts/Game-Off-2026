class_name ProjectileEnemy extends Enemy

@export var projectile_scene: PackedScene
@export var fire_interval: float = 2.0
@export var projectile_speed: float = 250.0
@export var projectile_count: int = 8
@export var projectile_data: ProjectileData

@export_group("Ring Formation")
@export var radius: float = 128.0
@export var spawn_delay: float = 0.08
@export var time_before_shoot: float = 0.25

@onready var shoot_timer: Timer = $ShootTimer
@onready var animation_player = $AnimationPlayer

var angle_between_shots: float = 45.0
var ring_projectiles: Array[Dictionary] = []
var is_forming_ring: bool = false

func _ready() -> void:
	super._ready()
	
	angle_between_shots = 360.0 / projectile_count
	
	shoot_timer.one_shot = true
	shoot_timer.wait_time = fire_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _physics_process(_delta: float) -> void:
	# cool tech to iterate backwards (thanks godot docs)
	for i in range(ring_projectiles.size() - 1, -1, -1):
		var entry: Dictionary = ring_projectiles[i]
		var proj = entry["projectile"]
		if is_instance_valid(proj):
			proj.global_position = global_position + entry["offset"]
		else:
			ring_projectiles.remove_at(i)

func _on_shoot_timer_timeout() -> void:
	if not is_forming_ring:
		shoot_radial()

func shoot_radial() -> void:
	if projectile_scene == null or projectile_data == null:
		return
	animation_player.play("attack")
	is_forming_ring = true
	ring_projectiles.clear()

	for i in range(projectile_count):
		if not is_inside_tree() or is_queued_for_deletion():
			return

		var angle_rad := deg_to_rad(i * angle_between_shots)
		var direction := Vector2.from_angle(angle_rad)
		var offset := direction * radius
		
		var projectile := projectile_scene.instantiate() as BulletProjectile
		var data := projectile_data.duplicate() as ProjectileData
		
		data.enemy = true
		data.direction = direction
		data.shift_color = enemy_stats.shift_color
		
		# damage and knockback is handled from the EnemyStats. 
		# IT IS NOT HANDLED FROM ProjectileData
		data.damage = enemy_stats.damage
		data.knockback = enemy_stats.knockback
		
		projectile.is_charging = true
		projectile.global_position = global_position + offset
		projectile.setup(data)
		get_tree().add_child(projectile)
		
		ring_projectiles.append({
			"projectile": projectile,
			"offset": offset
		})
	
		if spawn_delay > 0.0:
			await get_tree().create_timer(spawn_delay).timeout
	
	if not is_inside_tree() or is_queued_for_deletion():
		return
	
	if time_before_shoot > 0.0:
		await get_tree().create_timer(time_before_shoot).timeout
		if not is_inside_tree() or is_queued_for_deletion():
			return
	
	for entry in ring_projectiles:
		var proj = entry["projectile"]
		if is_instance_valid(proj):
			proj.launch()
	
	ring_projectiles.clear()
	is_forming_ring = false
	shoot_timer.start(fire_interval)

func die() -> void:
	for entry in ring_projectiles:
		var proj = entry["projectile"]
		if is_instance_valid(proj):
			proj.queue_free()
	ring_projectiles.clear()
	super.die()
