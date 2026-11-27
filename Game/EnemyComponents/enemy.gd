class_name Enemy extends CharacterBody2D

@onready var health_component: EnemyHealthComponent = $HealthComponent
@onready var movement_component: EnemyMovementComponent = $MovementComponent
@export var rotates_visual: bool = true
@export var enemy_stats: EnemyStats
@onready var hitbox: EnemyHitbox = $Hitbox
const GOLD_GRADIENT_MAP = preload("uid://bp8l8awsqscht")
var effect_timer: float = 0.0
@onready var enemy_sprite = %EnemySprite
var can_set_enemy_shift_speed: bool = true
var dead: bool = false

const FUEL_PICKUP = preload("uid://ce8424hmrm8l7")
const ENERGY_PICKUP = preload("uid://p73pjvontcjs")

func _ready() -> void:
	add_to_group("enemies")
	health_component.setup(self)
	movement_component.setup(self, rotates_visual)
	hitbox.setup(self, enemy_stats)
	enemy_sprite.material = enemy_sprite.material.duplicate()
	
	if enemy_stats.shift_color == DamageSource.ShiftColor.RED:
		enemy_sprite.material.set_shader_parameter("lerper", 1.0)
	elif enemy_stats.shift_color == DamageSource.ShiftColor.BLUE:
		enemy_sprite.material.set_shader_parameter("lerper", 0.0)
	elif enemy_stats.shift_color == DamageSource.ShiftColor.NONE or enemy_stats.shift_color == DamageSource.ShiftColor.GOLD:
		enemy_sprite.material = GOLD_GRADIENT_MAP
		enemy_sprite.material.set_shader_parameter("lerper", 0.0)
	
	
	EventSystem.player_shifted.connect(update_dimension_speed)
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player:
		update_dimension_speed(player.shift_color)

func update_dimension_speed(color: DamageSource.ShiftColor) -> void:
	if not can_set_enemy_shift_speed:
		return
	if color == enemy_stats.shift_color or color == DamageSource.ShiftColor.NONE:
		movement_component.current_speed = enemy_stats.speed
	else:
		movement_component.current_speed = enemy_stats.opposite_speed
	
func _process(delta: float) -> void:
	effect_timer = max(0.0, effect_timer - delta)

func take_damage(damage_source: DamageSource, propogating: bool = false) -> void:
	health_component.take_damage(damage_source)
	EventSystem.enemy_hit.emit(self, damage_source)
	if not propogating:
	
		Juicee.flicker(self, 0.2, Color(1.0, 1.0, 1.0, 0.369), 0.2)
		Juicee.flash(self)
			
	
	if damage_source.source_node:
		var knockback_amount: float = damage_source.knockback * enemy_stats.knockback_resistance
		movement_component.current_knockback = knockback_amount * damage_source.source_node.global_position.direction_to(global_position)

func die() -> void:
	if dead:
		return
	dead = true
	#var collectable := load("res://Game/Collectables/collectable.tscn")
	#var test = collectable.instantiate()
	#test.position = position
	#Juicee.preset_explosion(self)
	await get_tree().process_frame
	collision_layer = 0
	collision_mask = 0
	EventSystem.enemy_died.emit(self)
	ObjectPool.spawn(ObjectPool.explosion_scene, global_position)
	
	# TODO Add enemy death SFX
	Pickups.spawn(Enums.CurrencyType.GEAR, global_position, enemy_stats.drop)
	
	# separate to currency pickups
	spawn_pickup()
	
	queue_free()

func spawn_pickup():
	var random = randf_range(0,1)
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	var spawn_chance = player.get_current_stats().pickup_spawn_chance
	
	if random > spawn_chance:
		return
	
	var coin_flip = randi_range(0,1)
	
	if coin_flip == 0:
		spawn_fuel(self.position)
		return
	elif coin_flip == 1:
		spawn_energy(self.position)
		return

func spawn_fuel(pos: Vector2):
	var instance = FUEL_PICKUP.instantiate()
	get_tree().get_current_scene().call_deferred("add_child", instance)
	instance.global_position = pos
	
func spawn_energy(pos: Vector2):
	var instance = ENERGY_PICKUP.instantiate()
	get_tree().get_current_scene().call_deferred("add_child", instance)
	instance.global_position = pos
	
