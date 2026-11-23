class_name ObjectPooler extends RefCounted

var _pool: Array[Node] = []
var scene: PackedScene
var object_parent: Node
func _init(pool_size: int, _scene: PackedScene, parent: Node) -> void:
	scene = _scene
	object_parent = parent
	for i in range(pool_size):
		var obj: Node = _create_instance()
		_deactivate(obj)
		_pool.append(obj)
	
func return_object(obj: Node) -> void:
	if obj.process_mode == Node.PROCESS_MODE_DISABLED:
		return
	_deactivate(obj)
	_pool.append(obj)

func _create_instance() -> Node:
	var obj: Node = scene.instantiate()
	if obj.has_signal(&"done"):
		obj.done.connect(return_object.bind(obj), CONNECT_DEFERRED)
	object_parent.add_child(obj)
	return obj

func get_obj() -> Node:
	var obj: Node = _pool.pop_back() if _pool.size() > 0 else _create_instance()
	_activate(obj)
	return obj 

func _deactivate(obj: Node) -> void:
	obj.visible = false
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	if obj is Area2D:
		obj.monitorable = false
		obj.monitoring = false

func _activate(obj: Node) -> void:
	obj.visible = true
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	if obj is Area2D:
		obj.monitorable = true
		obj.monitoring = true
