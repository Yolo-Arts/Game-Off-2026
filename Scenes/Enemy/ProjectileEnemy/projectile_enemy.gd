class_name ProjectileEnemy extends Enemy

@export var projectile_scene: PackedScene
@export var projectile_data: ProjectileData

@export var fire_interval: float = 2.0
@export var projectile_speed: float = 250.0

@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $Muzzle

var target_player: Player

func _ready() -> void:
	super._ready()
	
	target_player = get_tree().get_first_node_in_group("player") as Player
	shoot_timer.wait_time = fire_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _on_shoot_timer_timeout() -> void:
	if not is_instance_valid(target_player):
		target_player = get_tree().get_first_node_in_group("player") as Player
		if not target_player:
			return
			
	shoot_at(target_player.global_position)


func shoot_at(target_pos: Vector2) -> void:
	var projectile := projectile_scene.instantiate() as BulletProjectile
	var data := projectile_data.duplicate() as ProjectileData
	data.enemy = true
	data.direction = muzzle.global_position.direction_to(target_pos)
	data.shift_color = enemy_stats.shift_color
	
	# damage and knockback is handled from the EnemyStats. 
	# IT IS NOT HANDLED FROM ProjectileData
	data.damage = enemy_stats.damage
	data.knockback = enemy_stats.knockback
	
	projectile.global_position = muzzle.global_position
	projectile.setup(data)
	get_tree().current_scene.add_child(projectile)
