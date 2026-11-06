@tool
class_name LineShape
extends Node2D


@export var draw_mode: LineDrawMode = LineDrawMode.ANGLE_AND_LENGTH:
	set(value):
		draw_mode = value
		queue_redraw()

@export var length: float = 0.0:
	set(value):
		length = value
		queue_redraw()

@export var start_point: Vector2 = Vector2.ZERO:
	set(value):
		start_point = value
		queue_redraw()

@export var end_point: Vector2 = Vector2.ZERO:
	set(value):
		end_point = value
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

@export var inside_margin: float = 0.0
@export var outside_margin: float = 4.0

enum LineDrawMode{
	ANGLE_AND_LENGTH = 0, 
	START_AND_END_POINT = 1, 
}


func _draw() -> void :
	match draw_mode:
		LineDrawMode.ANGLE_AND_LENGTH:
			if length == 0.0: return
			draw_line(Vector2.ZERO, length * Vector2.RIGHT, outline_color, edge_width + 7.0, true)
			draw_line(Vector2.ZERO, length * Vector2.RIGHT, edge_color, edge_width, true)

		LineDrawMode.START_AND_END_POINT:
			if start_point == end_point: return
			draw_line(start_point, end_point, outline_color, edge_width + 7.0, true)
			draw_line(start_point, end_point, edge_color, edge_width, true)
