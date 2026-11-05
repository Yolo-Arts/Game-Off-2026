class_name Player extends CharacterBody2D

@export var _default_stats: PlayerStats
@onready var item_manager: ItemManager = $ItemManager
@onready var movement_component: PlayerMovementComponent = $MovementComponent

var can_steer: bool = true
var can_control_speed: bool = true
func _ready() -> void:
	item_manager.setup(_default_stats)
	movement_component.setup(self)

func get_current_stats() -> PlayerStats:
	return item_manager.current_stats

func get_default_stats() -> PlayerStats:
	return _default_stats
