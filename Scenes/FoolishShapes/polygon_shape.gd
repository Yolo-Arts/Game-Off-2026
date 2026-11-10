@tool
class_name PolygonShape
extends Node2D


@export var draw_mode: PolygonDrawMode = PolygonDrawMode.AUTOMATIC_POINTS:
	set(value):
		draw_mode = value
		queue_redraw()

@export var custom_points: Array[Vector2]:
	set(value):
		custom_points = value
		queue_redraw()

@export var radius: float = 0.0:
	set(value):
		radius = value
		queue_redraw()

@export var sides: int = 3:
	set(value):
		sides = value
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

enum PolygonDrawMode{
	AUTOMATIC_POINTS = 0, 
	CUSTOM_POINTS = 1, 
}


func _draw() -> void :
	if radius <= 0 || edge_width <= 0: return

	var points: PackedVector2Array
	match draw_mode:
		PolygonDrawMode.AUTOMATIC_POINTS:
			for i in sides:
				points.append(radius * Vector2.UP.rotated(i * TAU / sides))
			points.append(radius * Vector2.UP)

		PolygonDrawMode.CUSTOM_POINTS:
			points = custom_points

	draw_colored_polygon(points, fill_color)
	draw_polyline(points, outline_color, edge_width + 7.0, true)
	draw_polyline(points, edge_color, edge_width, true)
