class_name SegmentMaker extends Node2D

@export var segment_scene: PackedScene
@export var segment_range: Vector2i = Vector2i(6, 10)
@export var distance_between: float = 64
@export var enemy_stats: EnemyStats

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var segments: Array[Segment]
	var number_of_segments: int = randi_range(segment_range.x, segment_range.y)
	var player: Player = get_tree().get_first_node_in_group(&"player") as Player
	if not player:
		queue_free()
		return
	for i in range(number_of_segments):
		var next_segment: Segment = segment_scene.instantiate() as Segment
		if not next_segment:
			queue_free()
			return
		next_segment.global_position = global_position + (player.global_position.direction_to(global_position) * distance_between * i)
		next_segment.enemy_stats = enemy_stats.duplicate()
		
		segments.append(next_segment)
		get_parent().add_child(next_segment)
		next_segment.force_update_transform()
	for i in range(segments.size()):
		var segment: Segment = segments[i]
		if i != 0:
			segment.ahead_segment = segments[i - 1]
		if i != segments.size() - 1:
			segment.behind_segment = segments[i + 1]
		segment.setup_segment(true)
	
	if segments[0] is BossSegment:
		for i in range(segments.size()):
			for j in range(i + 1, segments.size()):
				segments[i].add_collision_exception_with(segments[j])
		var head: BossSegment = segments[0] as BossSegment
		head.state_machine.initialize(head, &"roam")
	queue_free()
