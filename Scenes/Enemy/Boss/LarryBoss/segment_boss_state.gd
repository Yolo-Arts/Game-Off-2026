class_name SegmentBossState extends BaseState

var segment: BossSegment

func set_handled_node(_handled_node: Node):
	segment = _handled_node as BossSegment
	assert(segment != null, "NULL BOSS SEGMENT")
	_on_owner_set()
