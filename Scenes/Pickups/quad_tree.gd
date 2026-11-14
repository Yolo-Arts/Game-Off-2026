class_name QuadTree
extends RefCounted

const CAPACITY := 16
const MAX_DEPTH := 12

var _bounds: Rect2
var _depth: int
var _points: Array[Vector2] = []
var _children: Array[QuadTree] = []


func _init(bounds: Rect2, depth: int = 0) -> void:
	_bounds = bounds
	_depth = depth


func insert(point: Vector2) -> bool:
	if not _bounds.has_point(point):
		return false

	if _children.is_empty():
		if _points.size() < CAPACITY or _depth >= MAX_DEPTH:
			_points.append(point)
			return true
		_subdivide()
	
	return _children[_child_index(point)].insert(point)


func remove(point: Vector2) -> bool:
	if not _bounds.has_point(point):
		return false

	if _children.is_empty():
		var index := _points.find(point)
		if index == -1:
			return false
		_points.remove_at(index)
		return true

	var removed := _children[_child_index(point)].remove(point)
	if removed:
		_try_merge()
	return removed


func find_all_in_radius(center: Vector2, radius: float) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var query_rect := Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2.0)
	_collect_in_radius(center, radius * radius, query_rect, result)
	return result


func _collect_in_radius(center: Vector2, radius_squared: float, query_rect: Rect2, result: Array[Vector2]) -> void:
	if not _bounds.intersects(query_rect):
		return

	if _children.is_empty():
		for point in _points:
			if point.distance_squared_to(center) <= radius_squared:
				result.append(point)
		return

	for child in _children:
		child._collect_in_radius(center, radius_squared, query_rect, result)


func _child_index(point: Vector2) -> int:
	var center := _bounds.get_center()
	var index := 0
	if point.x >= center.x:
		index |= 1
	if point.y >= center.y:
		index |= 2
	return index


func _subdivide() -> void:
	var half := _bounds.size * 0.5
	for i in 4:
		var offset := Vector2(half.x * (i & 1), half.y * ((i >> 1) & 1))
		_children.append(QuadTree.new(Rect2(_bounds.position + offset, half), _depth + 1))

	var old_points := _points.duplicate()
	_points.clear()
	for point in old_points:
		_children[_child_index(point)].insert(point)

func _try_merge() -> void:
	var total := 0
	for child in _children:
		if not child._children.is_empty():
			return
		total += child._points.size()

	if total > CAPACITY:
		return

	for child in _children:
		_points.append_array(child._points)
	_children.clear()
