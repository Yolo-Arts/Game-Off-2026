class_name PlayerState extends BaseState

var player: Player

func set_handled_node(_handled_node: Node):
	player = _handled_node as Player
	assert(player != null, "NULL PLAYER")
	_on_owner_set()
