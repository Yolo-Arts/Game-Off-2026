extends Node

@onready var packed_rectangle_shape: PackedScene = preload("uid://dcq6mijbwgbfk")
@onready var packed_polygon_shape: PackedScene = preload("uid://cpttyhyn0dsuw")
@onready var packed_circle_shape: PackedScene = preload("uid://cb5xkulwx5sx5")
@onready var packed_line_shape: PackedScene = preload("uid://2vp7ipwx1mw5")


func instantiate_rectangle_shape() -> RectangleShape:
	var new_rectangle_shape = packed_rectangle_shape.instantiate() as RectangleShape
	return new_rectangle_shape


func instantiate_polygon_shape() -> PolygonShape:
	var new_polygon_shape = packed_polygon_shape.instantiate() as PolygonShape
	return new_polygon_shape


func instantiate_circle_shape() -> CircleShape:
	var new_circle_shape = packed_circle_shape.instantiate() as CircleShape
	return new_circle_shape


func instantiate_line_shape() -> LineShape:
	var new_line_shape = packed_line_shape.instantiate() as LineShape
	return new_line_shape
