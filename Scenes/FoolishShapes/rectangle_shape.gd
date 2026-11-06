@tool
class_name RectangleShape
extends Node2D

@export var hook_to_parent: bool = false:
	set(value):
		hook_to_parent = value
		_hook_to_parent()
		queue_redraw()

@export_custom(PROPERTY_HINT_LINK, "size") var size: Vector2 = Vector2.ZERO:
	set(value):
		size = value
		queue_redraw()

@export var anchor_ratio: Vector2 = Vector2.ZERO:
	set(value):
		anchor_ratio = value
		queue_redraw()

@export var edge_width: float = 1.0:
	set(value):
		edge_width = value
		queue_redraw()

@export var edge_color: Color = Color.WHITE:
	set(value):
		edge_color = value
		queue_redraw()

@export var outline_color: Color = Color.BLACK:
	set(value):
		outline_color = value
		queue_redraw()

@export var fill_color: Color = Color.BLACK:
	set(value):
		fill_color = value
		queue_redraw()

@export var inside_margin: float = 0.0
@export var outside_margin: float = 4.0

var _parent: Control


func _enter_tree() -> void :
	_hook_to_parent()


func _exit_tree() -> void :
	if _parent != null && _parent.minimum_size_changed.is_connected(queue_redraw):
		_parent.minimum_size_changed.disconnect(queue_redraw)


func _hook_to_parent() -> void :
	if !hook_to_parent: return

	_parent = get_parent() as Control
	if _parent != null && !_parent.minimum_size_changed.is_connected(queue_redraw):
		_parent.minimum_size_changed.connect(queue_redraw)

	call_deferred("_set_position_to_zero")
	queue_redraw()


func _set_position_to_zero() -> void :
	position = Vector2.ZERO


func _draw() -> void :
	if hook_to_parent:
		draw_rect(Rect2(Vector2.ZERO, _parent.size), fill_color, true, -1.0, true)
		draw_rect(Rect2(Vector2.ZERO, _parent.size), outline_color, false, edge_width + 7.0, true)
		draw_rect(Rect2(Vector2.ZERO, _parent.size), edge_color, false, edge_width, true)
		return

	if size.x == 0 || size.y == 0: return
	draw_rect(Rect2(Vector2( - size.x * anchor_ratio.x, - size.y * anchor_ratio.y), Vector2(size.x, size.y)), fill_color, true, -1.0, true)
	draw_rect(Rect2(Vector2( - size.x * anchor_ratio.x, - size.y * anchor_ratio.y), Vector2(size.x, size.y)), outline_color, false, edge_width + 7.0, true)
	draw_rect(Rect2(Vector2( - size.x * anchor_ratio.x, - size.y * anchor_ratio.y), Vector2(size.x, size.y)), edge_color, false, edge_width, true)
