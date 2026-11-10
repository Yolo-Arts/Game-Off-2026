class_name Player extends CharacterBody2D

@export var _default_stats: PlayerStats
@onready var item_manager: ItemManager = $ItemManager
@onready var movement_component: PlayerMovementComponent = $MovementComponent
@onready var health_component: PlayerHealthComponent = $HealthComponent

var can_steer: bool = true
var can_control_speed: bool = true

func _init() -> void:
	EventSystem.player_hit.connect(_on_player_hit)

func _ready() -> void:
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.HUD)
	item_manager.setup(_default_stats)
	movement_component.setup(self)
	health_component.setup(self)

func _on_player_hit(damage: float, source: Node = null) -> void:
	health_component.take_damage(damage, source)

func get_current_stats() -> PlayerStats:
	return item_manager.current_stats

func get_default_stats() -> PlayerStats:
	return _default_stats
