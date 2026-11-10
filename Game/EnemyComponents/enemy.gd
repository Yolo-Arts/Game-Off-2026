class_name Enemy extends CharacterBody2D

@onready var health_component: EnemyHealthComponent = $HealthComponent
@onready var movement_component: EnemyMovementComponent = $MovementComponent
@export var enemy_stats: EnemyStats
@onready var hitbox: EnemyHitbox = $Hitbox

func _ready() -> void:
	health_component.setup(self)
	movement_component.setup(self)
	hitbox.setup(self, enemy_stats)
	if enemy_stats.shift_color == DamageSource.ShiftColor.RED:
		$Sprite2D.modulate = Color(1, 0, 0)
	
	EventSystem.player_shifted.connect(update_dimension_speed)
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player:
		update_dimension_speed(player.shift_color)

func update_dimension_speed(color: DamageSource.ShiftColor) -> void:
	if color == enemy_stats.shift_color or color == DamageSource.ShiftColor.NONE:
		movement_component.current_speed = enemy_stats.speed
	else:
		movement_component.current_speed = enemy_stats.opposite_speed
	
func _process(delta: float) -> void:
	pass
	
func _exit_tree() -> void:
	
	var collectable := load("res://Game/Collectables/collectable.tscn")
	var test = collectable.instantiate()
	test.position = position
	
