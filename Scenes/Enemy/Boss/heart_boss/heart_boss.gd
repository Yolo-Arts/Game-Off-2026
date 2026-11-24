class_name HeartBoss extends Boss

@export_group("Heartbeat Attack")
@export var projectile_scene: PackedScene
@export var projectile_data: ProjectileData
@export var projectile_count: int = 24
@export var spawn_radius: float = 32.0
@export var min_projectile_speed: float = 160.0
@export var max_projectile_speed: float = 260.0
# lower is faster
@export var max_beat_interval: float = 2.2  # how fast it attacks when high health
@export var min_beat_interval: float = 0.55 # how fast it attacks when low health

@export_group("Color Shifting")
@export var max_color_shift_interval: float = 6.0 
@export var min_color_shift_interval: float = 2.0 
@export var color_shift_delay: float = 1.0 
@export var shift_shake_force: float = 6.0

@export_group("Heartbeat Visuals")
@export var beat_shake_force: float = 3.0

@onready var state_machine: StateMachine = %StateMachine
@onready var scale_pivot: Node2D = %ScalePivot
@onready var animation_shake: ShakyNode2D = $AnimationShake
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_shifting_color: bool = false
var _bullet_folder: Node
var tween: Tween
var shift_tween: Tween
var shift_material: ShaderMaterial
var player: Player

func _ready() -> void:
	enemy_stats = enemy_stats.duplicate()
	super._ready()
	
	shift_material = enemy_sprite.material as ShaderMaterial
	_bullet_folder = get_tree().get_first_node_in_group("bullet_folder")
	state_machine.initialize(self, &"normal")
	player = get_tree().get_first_node_in_group("player")

func get_health_ratio() -> float:
	return clampf(health_component.current_health / health_component.max_health, 0.0, 1.0)

func get_current_beat_interval() -> float:
	return lerpf(min_beat_interval, max_beat_interval, get_health_ratio())

func trigger_heartbeat() -> void:
	if dead:
		return
	
	_play_heartbeat_visuals()
	_fire_radial_spray()
	movement_component.pulse_beat()
	
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.HeartBeat)

func _play_heartbeat_visuals() -> void:
	animation_shake.shake(beat_shake_force)
	
	if tween and tween.is_valid():
		tween.kill()
	
	var speed_scale: float = clampf(1.5 / maxf(get_current_beat_interval(), 0.2), 1.0, 2.0)
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.set_speed_scale(speed_scale)
	tween.tween_property(scale_pivot, "scale", Vector2(1.24, 0.80), 0.07)
	tween.tween_property(scale_pivot, "scale", Vector2(0.88, 1.18), 0.09)
	tween.tween_property(scale_pivot, "scale", Vector2.ONE, 0.14)

func _fire_radial_spray() -> void:
	for i: int in range(projectile_count):
		var random_angle: float = randf_range(0.0, TAU)
		var direction: Vector2 = Vector2.from_angle(random_angle)
		
		var projectile: BulletProjectile = projectile_scene.instantiate() as BulletProjectile
		var data: ProjectileData = projectile_data.duplicate() as ProjectileData
		
		data.enemy = true
		data.direction = direction
		data.shift_color = enemy_stats.shift_color
		data.damage = enemy_stats.damage
		data.knockback = enemy_stats.knockback
		
		var base_speed: float = randf_range(min_projectile_speed, max_projectile_speed)
		data.speed = base_speed * randf_range(0.95, 1.05)
		
		projectile.global_position = global_position + direction * spawn_radius
		projectile.setup(data)
		_bullet_folder.add_child(projectile)

func start_color_shift() -> void:
	if is_shifting_color or dead:
		return
	
	is_shifting_color = true
	
	var target_color: DamageSource.ShiftColor = DamageSource.ShiftColor.BLUE \
		if enemy_stats.shift_color == DamageSource.ShiftColor.RED \
		else DamageSource.ShiftColor.RED
	var target_lerper: float = 1.0 if target_color == DamageSource.ShiftColor.RED else 0.0
	
	animation_shake.shake(shift_shake_force)
	
	# SFX: Add color shift SFX here for heart boss
	
	if shift_tween and shift_tween.is_valid():
		shift_tween.kill()
	shift_tween = create_tween()
	shift_tween.tween_method(
		func(val: float) -> void: shift_material.set_shader_parameter("lerper", val),
		shift_material.get_shader_parameter("lerper"),
		target_lerper,
		color_shift_delay
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(color_shift_delay).timeout
	
	if dead or not is_inside_tree():
		return
	
	enemy_stats.shift_color = target_color
	shift_material.set_shader_parameter("lerper", target_lerper)
	
	if player:
		update_dimension_speed(player.shift_color)
	
	is_shifting_color = false

func get_current_shift_interval() -> float:
	return lerpf(min_color_shift_interval, max_color_shift_interval, get_health_ratio())

func take_damage(damage_source: DamageSource) -> void:
	super(damage_source)
	EventSystem.update_boss_healthbar_component.emit()

func die() -> void:
	Globals.beat_boss = true
	SkillTreeUpgrades.complete_active_scene_item()
	#EventSystem.STA_change_stage.emit(StageConfig.Keys.UpgradeView)
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.GameOverScreen, "boss_fight")
	
	Currencies.cheat_add_specific_currency(Enums.CurrencyType.HEART, 1)
	Currencies.cheat_add_specific_currency(Enums.CurrencyType.STAR, 10)
	Currencies.cheat_add_specific_currency(Enums.CurrencyType.GEAR, 100)
	
	super.die()
