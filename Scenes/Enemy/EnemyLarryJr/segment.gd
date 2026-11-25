class_name Segment extends Enemy

signal segment_destroyed
@export var player_orbit_radius: float = 300.0
var ahead_segment: Segment
var behind_segment: Segment
enum SegmentLocation {HEAD, MIDDLE, TAIL, NONE}
var segment_type: SegmentLocation
var started: bool = false
var current_speed: float
var orbit_direction: int = 1

var do_circle: bool = true

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
	elif enemy_stats.shift_color == DamageSource.ShiftColor.NONE:
		enemy_sprite.material = GOLD_GRADIENT_MAP
		enemy_sprite.material.set_shader_parameter("lerper", 0.0)
	
	EventSystem.player_shifted.connect(update_dimension_speed)
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player:
		update_dimension_speed(player.shift_color)

	

func _physics_process(delta: float) -> void:
	pass
	
func set_anim() -> void:
	match segment_type:
		SegmentLocation.HEAD:
			%EnemySprite.play(&"head")
		SegmentLocation.MIDDLE:
			%EnemySprite.play(&"middle")
		SegmentLocation.TAIL:
			%EnemySprite.play(&"tail")
		_:
			%EnemySprite.play(&"tail")

func setup_segment(init: bool = false) -> void:
	if behind_segment and ahead_segment:
		segment_type = SegmentLocation.MIDDLE
		collision_mask = 0
	elif not behind_segment and ahead_segment:
		collision_mask = 0
		segment_type = SegmentLocation.TAIL
	elif behind_segment and not ahead_segment:
		segment_type = SegmentLocation.HEAD
		collision_layer = 4
		collision_mask = 5
	else:
		segment_type = SegmentLocation.NONE
		die()
	if init:
		if ahead_segment:
			ahead_segment.segment_destroyed.connect(setup_segment)
		if behind_segment:
			behind_segment.segment_destroyed.connect(setup_segment)
	set_anim()
	orbit_direction = [-1, 1].pick_random()
	started = true
func die() -> void:
	if dead:
		return
	dead = true
	if ahead_segment:
		ahead_segment.behind_segment = null
	if behind_segment:
		behind_segment.ahead_segment = null
	segment_destroyed.emit()
	
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
	queue_free()
