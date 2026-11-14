class_name Player extends CharacterBody2D

@export var _default_stats: PlayerStats
@onready var item_manager: ItemManager = $ItemManager
@onready var movement_component: PlayerMovementComponent = $MovementComponent
@onready var health_component: PlayerHealthComponent = $HealthComponent
@onready var energy_component: PlayerEnergyComponent = $EnergyComponent
@onready var hitbox: PlayerHitbox = $Hitbox
@onready var state_machine: StateMachine = $StateMachine
@onready var shoot_component: PlayerShootComponent = $ShootComponent

@onready var sprite = %Sprite2D
@onready var left_engine_particles = %LeftEngineParticles
@onready var right_engine_particles = %RightEngineParticles

var can_steer: bool = true
var can_control_speed: bool = true
var can_shift: bool = true
var can_reduce_health: bool = true
var can_shoot: bool = true
var shift_color: DamageSource.ShiftColor = DamageSource.ShiftColor.NONE


func _ready() -> void:
	#EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.HUD)
	EventSystem.player_hit.connect(_on_player_hit)
	
	item_manager.setup(_default_stats)
	movement_component.setup(self)
	hitbox.setup(self, true)
	health_component.setup(self)
	energy_component.setup(self)
	state_machine.initialize(self, &"normal")
	shoot_component.setup(self)
	
	EventSystem.player_shifted.emit(shift_color)
	shift_active_color()

func _process(delta: float) -> void:
	reduce_health(delta)


func _on_player_hit(damage_source: DamageSource) -> void:
	if not health_component.take_damage(damage_source): return
	
	if damage_source.damage_type != DamageSource.DamageSourceType.AUTO_DAMAGE:
		TweenManager.camera.shake(0.25, 20, 15)
		if damage_source.source_node != null:
			movement_component.current_knockback = damage_source.knockback * (damage_source.source_node.global_position.direction_to(global_position))
			

func get_current_stats() -> PlayerStats:
	return item_manager.current_stats

func get_default_stats() -> PlayerStats:
	return _default_stats

func shift_active_color() -> void:
	match shift_color:
		DamageSource.ShiftColor.BLUE:
			shift_color = DamageSource.ShiftColor.RED
			sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
			left_engine_particles.color = Color(1.0, 0.0, 0.0, 1.0)
			right_engine_particles.color = Color(1.0, 0.0, 0.0, 1.0)
		DamageSource.ShiftColor.RED:
			sprite.modulate = Color(0.169, 0.416, 1.0, 1.0)
			left_engine_particles.color = Color(0.169, 0.416, 1.0, 1.0)
			right_engine_particles.color = Color(0.169, 0.416, 1.0, 1.0)
			shift_color = DamageSource.ShiftColor.BLUE
		DamageSource.ShiftColor.NONE:
			left_engine_particles.color = Color(0.169, 0.416, 1.0, 1.0)
			right_engine_particles.color = Color(0.169, 0.416, 1.0, 1.0)
			sprite.modulate = Color(0.169, 0.416, 1.0, 1.0)
			shift_color = DamageSource.ShiftColor.BLUE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shift") and can_shift:
		shift_active_color()
		EventSystem.player_shifted.emit(shift_color)
	
	#if event.is_action_pressed("Ram") and can_ram():
	#	ram()
	#	energy_component.reduce_energy(get_current_stats().energy_ram_cost)

func can_ram() -> bool:
	return velocity.length() >= get_current_stats().minimum_ram_speed

func reduce_health(delta: float) -> void:
	if not can_reduce_health: return
	EventSystem.player_hit.emit(DamageSource.new(get_current_stats().health_usage_per_second * delta, 0.0, DamageSource.DamageSourceType.AUTO_DAMAGE, DamageSource.ShiftColor.NONE, null))
func shoot():
	pass
