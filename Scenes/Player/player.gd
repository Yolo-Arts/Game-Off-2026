class_name Player extends CharacterBody2D

@export var _default_stats: PlayerStats
@onready var item_manager: ItemManager = $ItemManager
@onready var movement_component: PlayerMovementComponent = $MovementComponent
@onready var health_component: PlayerHealthComponent = $HealthComponent
@onready var hitbox: PlayerHitbox = $Hitbox

var can_steer: bool = true
var can_control_speed: bool = true
var can_shift: bool = true
var shift_color: DamageSource.ShiftColor = DamageSource.ShiftColor.BLUE


func _ready() -> void:
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.HUD)
	EventSystem.player_hit.connect(_on_player_hit)
	item_manager.setup(_default_stats)
	movement_component.setup(self)
	hitbox.setup(self, true)
	health_component.setup(self)
	

func _on_player_hit(damage_source: DamageSource) -> void:
	health_component.take_damage(damage_source)

func get_current_stats() -> PlayerStats:
	return item_manager.current_stats

func get_default_stats() -> PlayerStats:
	return _default_stats

func shift_active_color() -> void:
	match shift_color:
		DamageSource.ShiftColor.BLUE:
			shift_color = DamageSource.ShiftColor.RED
		DamageSource.ShiftColor.RED:
			shift_color = DamageSource.ShiftColor.BLUE
		_:
			shift_color = DamageSource.ShiftColor.BLUE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shift") and can_shift:
		shift_active_color()
		EventSystem.player_shifted.emit(shift_color)

func can_ram() -> bool:
	return movement_component.speed >= get_current_stats().minimum_ram_speed
