class_name BulletProjectile extends Area2D

const GOLD_GRADIENT_MAP = preload("uid://bp8l8awsqscht")

@export var projectile_stats: ProjectileData
@onready var sprite: Sprite2D = $Sprite2D

var _timer_started: bool = false
var is_charging: bool = false
var player: Player

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if projectile_stats != null:
		_apply_stats()
	

func setup(stats: ProjectileData) -> void:
	projectile_stats = stats.duplicate()
	if is_inside_tree():
		_apply_stats()

func _apply_stats() -> void:
	scale = projectile_stats.scale
	projectile_stats.direction = projectile_stats.direction.normalized()
	global_rotation = projectile_stats.direction.angle()
	
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(4, true) # projectiles
	set_collision_mask_value(1, true)  # environments

	if projectile_stats.enemy:
		set_collision_mask_value(2, true) # player
		#player = get_tree().get_first_node_in_group("player") as Player
	else:
		# look for enemies and other bullets.
		set_collision_mask_value(3, true) # enemy
		set_collision_mask_value(4, true) 
	_apply_shift_shader()
	
	if not is_charging:
		_start_lifetime_timer()
	
	player = get_tree().get_first_node_in_group("player") as Player

func launch() -> void:
	is_charging = false
	_start_lifetime_timer()

func _start_lifetime_timer() -> void:
	if _timer_started or projectile_stats == null:
		return
	_timer_started = true
	var wait: float = projectile_stats.life_time_seconds if not projectile_stats.use_range else projectile_stats.convert_range_to_life_time()
	get_tree().create_timer(wait).timeout.connect(queue_free)

func _apply_shift_shader() -> void:
	if sprite == null or sprite.material == null:
		return
	
	sprite.material = sprite.material.duplicate()
	
	match projectile_stats.shift_color:
		DamageSource.ShiftColor.RED:
			sprite.material.set_shader_parameter("lerper", 1.0)
		DamageSource.ShiftColor.BLUE:
			sprite.material.set_shader_parameter("lerper", 0.0)
		DamageSource.ShiftColor.NONE:
			sprite.material = GOLD_GRADIENT_MAP
			sprite.material.set_shader_parameter("lerper", 0.0)

func _physics_process(delta: float) -> void:
	if projectile_stats == null or is_charging:
		return
	global_position += projectile_stats.direction * projectile_stats.speed * delta

func _on_area_entered(area: Area2D) -> void:
	if projectile_stats == null:
		return
		
	if not projectile_stats.enemy and area is BulletProjectile:
		var other_bullet := area as BulletProjectile
		if other_bullet.is_queued_for_deletion():
			return
		if other_bullet.projectile_stats != null and other_bullet.projectile_stats.enemy:
			other_bullet.break_projectile()
			
			# TODO add piercing to player bullet so that their shots pierce through enemy projectiles.
			break_projectile() 
			return
	
	if projectile_stats.enemy and area.is_in_group("player_hurtbox"):
		
		if player and (player.shift_color == projectile_stats.shift_color) and (projectile_stats.shift_color != DamageSource.ShiftColor.NONE):
			break_projectile()
			return
		
		var damage_source := DamageSource.new(
			projectile_stats.damage,
			projectile_stats.knockback,
			DamageSource.DamageSourceType.PROJECTILE,
			projectile_stats.shift_color,
			self
		)
		EventSystem.player_hit.emit(damage_source)
		
		break_projectile(false)

func _on_body_entered(body: Node2D) -> void:
	if projectile_stats == null:
		return
	
	# coz the bullet collides with player for some reason :pensive:
	if body.is_in_group("player"):
		return

	if projectile_stats.enemy and body.is_in_group("enemies"):
		return

	if not projectile_stats.enemy and body.has_method("take_damage"):
		if body.enemy_stats.shift_color == player.shift_color:
			var damage_source := DamageSource.new(
				projectile_stats.damage,
				projectile_stats.knockback,
				#DamageSource.DamageSourceType.PLAYER_PROJECTILE,
				DamageSource.DamageSourceType.PLAYER_PROJECTILE,
				projectile_stats.shift_color,
				self
			)
			body.take_damage(damage_source)
	
	break_projectile()

func break_projectile(_same_color: bool = true) -> void:
	# TODO make better projectile particles.
	ObjectPool.spawn(ObjectPool.bullet_impact_scene, global_position)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not is_charging:
		queue_free()
