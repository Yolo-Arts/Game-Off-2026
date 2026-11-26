class_name LarrySrSr extends Boss

var head: BossSegment
var larry: Array[BossSegment]

@export var segment_scene: PackedScene
@export var boss_size: int = 100
@export var distance_between: float = 64
var segments_left: int = 100
func _ready() -> void:
	larry = spawn_larry()
	segments_left = larry.size()
	print("LARRRY ", segments_left)
	head = larry[0]
	for segment in larry:
		segment.segment_destroyed.connect(_on_segment_destroyed)
	head.state_machine.initialize(head, &"roam")
	
func _on_segment_destroyed() -> void:
	print("AAAAAA")
	segments_left -= 1
	EventSystem.update_boss_healthbar_component.emit()
	match segments_left:
		75:
			head.current_phase = BossSegment.BossPhase.ARENA
		50:
			head.current_phase = BossSegment.BossPhase.FINAL

func spawn_larry() -> Array[BossSegment]:
	var segments: Array[BossSegment]
	var number_of_segments: int = boss_size
	var player: Player = get_tree().get_first_node_in_group(&"player") as Player
	if not player:
		push_error("NO PLAYER OFNEWROG")
	for i in range(number_of_segments):
		var next_segment: Segment = segment_scene.instantiate() as BossSegment
		if not next_segment:
			print("WRONG SEGMENT")
		next_segment.global_position = global_position + (player.global_position.direction_to(global_position) * distance_between * i)
		next_segment.enemy_stats = enemy_stats.duplicate()
		
		segments.append(next_segment)
		add_child(next_segment)
	for i in range(segments.size()):
		var segment: Segment = segments[i]
		if i != 0:
			segment.ahead_segment = segments[i - 1]
		if i != segments.size() - 1:
			segment.behind_segment = segments[i + 1]
		segment.setup_segment(true)
	
	for i in range(segments.size()):
		for j in range(i + 1, segments.size()):
			segments[i].add_collision_exception_with(segments[j])
	return segments
	


func update_dimension_speed(color: DamageSource.ShiftColor) -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func take_damage(damage_source: DamageSource, propogating: bool = false) -> void:
	pass
	
func die() -> void:
	pass
