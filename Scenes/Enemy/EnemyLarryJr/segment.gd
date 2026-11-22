class_name Segment extends Enemy

signal segment_destroyed
@export var player_orbit_radius: float = 300.0
var ahead_segment: Segment
var behind_segment: Segment
enum SegmentLocation {HEAD, MIDDLE, TAIL, NONE}
var segment_type: SegmentLocation
var started: bool = false
var current_speed: float
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
			%EnemySprite.play(&"middle")

func setup_segment(init: bool = false) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
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
	started = true
func die() -> void:
	segment_destroyed.emit()
	super.die()
