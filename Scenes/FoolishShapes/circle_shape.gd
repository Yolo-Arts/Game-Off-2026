@tool
class_name CircleShape
extends Node2D


@export var radius: float = 0.0:
	set(value):
		radius = value
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


func _draw() -> void :
	if radius <= 0 || edge_width <= 0: return
	draw_circle(Vector2.ZERO, radius, fill_color, true, -1.0, true)
	draw_circle(Vector2.ZERO, radius, outline_color, false, edge_width + 7.0, true)
	draw_circle(Vector2.ZERO, radius, edge_color, false, edge_width, true)
